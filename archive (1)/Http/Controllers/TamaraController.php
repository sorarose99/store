<?php

namespace App\Http\Controllers;

use App\Mail\NewOrderAdminMail;
use App\Mail\OrderPaidMail;
use App\Models\Notification;
use App\Models\Order;
use App\Models\PaymentGateway;
use App\Models\PaymentTransaction;
use App\Services\CartService;
use App\Services\TamaraService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class TamaraController extends Controller
{
    public function __construct(
        protected CartService $cartService
    ) {}

    /**
     * إنشاء رابط الدفع
     */
    public function pay(Request $request)
    {
        $request->validate([
            'order_number' => 'required|string|exists:orders,order_number',
        ]);

        $order = Order::with('user')->where('order_number', $request->order_number)->firstOrFail();

        // حماية إضافية
        if ($order->user_id !== Auth::id()) {
            abort(403);
        }

        // بوابة الدفع
        $gateway = PaymentGateway::where('name', 'tamara')
            ->where('is_active', 1)
            ->first();

        if (! $gateway) {
            $order->delete();

            return back()->with(
                'error',
                __('messages.payment_gateway_inactive')
            );
        }

        // إذا الطلب مدفوع مسبقاً
        if ($order->payment_status === 'paid') {
            return redirect()->route(
                'orders.success',
                $order->order_number
            );
        }

        $tamara = new TamaraService($gateway);

        $items = [];

        foreach ($order->items as $item) {

            $items[] = [
                'name' => $item->product_name,
                'type' => 'Physical',
                'reference_id' => (string) $item->product_id,
                'sku' => $item->sku,
                'quantity' => (int) $item->quantity,

                'unit_price' => [
                    'amount' => number_format($item->price, 2, '.', ''),
                    'currency' => 'SAR',
                ],

                'total_amount' => [
                    'amount' => number_format($item->total, 2, '.', ''),
                    'currency' => 'SAR',
                ],
            ];
        }

        $fullName = trim($order->shipping_full_name);
        $nameParts = explode(' ', $fullName, 2);
        $firstName = $nameParts[0] ?? 'Customer';
        $lastName = $nameParts[1] ?? 'User';

        $response = $tamara->createCheckout([

            'order_number' => $order->order_number,

            'amount' => $order->total,

            'currency' => 'SAR',

            'country_code' => 'SA',

            'first_name' => $firstName,

            'last_name' => $lastName,

            'email' => $order->shipping_email,

            'phone' => $order->shipping_phone,

            'address' => $order->shipping_address,

            'city' => $order->shipping_city,

            'items' => $items,
        ]);

        if (! isset($response['checkout_url'])) {
            Log::error('Tamara create payment failed', [
                'response' => $response,
            ]);
            $order->delete();

            return back()->with(
                'error',
                __('messages.payment_creation_failed')
            );
        }

        return redirect($response['checkout_url']);

    }

    /**
     * webhook من Tamara
     */
    public function webhook(Request $request)
    {
        // 1. جلب بيانات بوابة الدفع من قاعدة البيانات
        $gateway = PaymentGateway::where('name', 'tamara')->where('is_active', 1)->first();
        if (! $gateway) {
            Log::error('Tamara Webhook Failed: Gateway inactive or not found.');

            return response()->json(['success' => false, 'message' => 'Gateway inactive'], 422);
        }

        // 2. استخراج التوكن المتوقع بشكل مرن (سواء حقل مستقل أو داخل credentials JSON)
        $notificationToken = null;
        if (! empty($gateway->notification_token)) {
            $notificationToken = $gateway->notification_token;
        } elseif (isset($gateway->credentials['notification_token'])) {
            $notificationToken = $gateway->credentials['notification_token'];
        }
        $notificationToken = trim($notificationToken ?? '');

        // 3. جلب الـ Headers وتنظيفها
        $authorizationHeader = $request->header('Authorization', '');
        $receivedToken = trim(preg_replace('/Bearer\s+/i', '', $authorizationHeader));

        // 4. جدار الأمان المزدوج (التحقق المرن)
        $isVerified = false;

        if (! empty($notificationToken) && ! empty($receivedToken)) {
            // أ. التحقق المباشر (إذا تم إرسال التوكن الصافي المطابق)
            if ($receivedToken === $notificationToken) {
                $isVerified = true;
            }
            // ب. التحقق من الـ JWT (إذا قامت تمارا بتشفير الهيدر تلقائياً)
            else {
                $tokenParts = explode('.', $receivedToken);
                if (count($tokenParts) === 3) {
                    $payloadJson = base64_decode(str_replace(['-', '_'], ['+', '/'], $tokenParts[1]));
                    $jwtPayload = json_decode($payloadJson, true);

                    if (isset($jwtPayload['iss']) && strtolower($jwtPayload['iss']) === 'tamara') {
                        $isVerified = true;
                    }
                }
            }
        }

        // إذا فشل التحقق بجميع الطرق
        if (! $isVerified) {
            Log::warning('Unauthorized Tamara webhook attempt blocked. Security validation failed.', [
                'Authorization Header' => $authorizationHeader,
            ]);

            return response()->json(['status' => false, 'message' => 'Unauthorized'], 401);
        }

        // 5. استقبال قراءة الـ Payload بناءً على التوثيق الرسمي المرفق
        $payload = $request->all();
        
        // استخراج معرف الطلب (تمارا تدعم الحقلين ونحن نأخذ المتوفر منهما)
        $orderNumber = $payload['order_reference_id'] ?? $payload['order_number'] ?? null;
        $eventType = $payload['order_status'] ?? $payload['event_type'] ?? $payload['status'] ?? '';
        $eventType = strtolower(trim($eventType));

        if (! $orderNumber) {
            return response()->json(['status' => false, 'message' => 'Order reference missing'], 422);
        }

        $shouldSendEmails = false;
        $order = null;

        // 6. بدء المعاملة في قاعدة البيانات مع قفل الحماية للعمليات المتوازية
        DB::beginTransaction();
        try {
            
            $order = Order::with('user')
                ->where('order_number', $orderNumber)
                ->lockForUpdate()
                ->first();
            
            if (! $order) {
                DB::rollBack();

                return response()->json(['status' => false, 'message' => 'Order not found'], 404);
            }

            // إذا كان الطلب معالجاً ومدفوعاً مسبقاً، اخرج بسلام (منع التكرار)
            if ($order->payment_status === 'paid') {
                DB::commit();

                return response()->json(['status' => true, 'message' => 'Already processed']);
            }

            // الحالات الناجحة المعتمدة في مستندات تمارا لتعميد الدفع
            $successEvents = ['approved', 'authorised', 'captured'];
            
            if (in_array($eventType, $successEvents)) {

                // تحديث حالة الطلب
                $order->update([
                    'payment_status' => 'paid',
                ]);

                // تفريغ سلة العميل بنجاح عملية الدفع
                $this->cartService->clearByUserId($order->user_id);

                // تسجيل عملية الدفع الرقمية بالكامل
                PaymentTransaction::firstOrCreate(
                    [
                        'transaction_id' => $payload['order_id'] ?? uniqid('tamara_'),
                    ],
                    [
                        'order_id' => $order->id,
                        'user_id' => $order->user_id,
                        'payment_method' => 'tamara',
                        'status' => 'completed',
                        'amount' => $order->total,
                        'paid_at' => now(),
                        'payment_data' => json_encode($payload, JSON_UNESCAPED_UNICODE),
                    ]
                );

                // إضافة سجل الحركة للطلب
                $order->statusHistories()->create([
                    'old_status' => null,
                    'new_status' => 'pending',
                    'notes' => 'تم إنشاء الطلب ودفع عبر تمارا',
                    'user_id' => $order->user_id,
                ]);

                // إشعار الإدارة
                Notification::create([
                    'type' => 'order',
                    'audience' => 'admin',
                    'related_id' => $order->id,
                    'title' => 'طلب جديد مدفوع بالكامل عبر تمارا',
                ]);

                $shouldSendEmails = true;

            }
            // في حال تم إلغاء الطلب أو رفضه من تمارا بموجب الـ Enums المرفقة
            elseif (in_array($eventType, ['canceled', 'declined', 'expired'])) {
                Log::warning("Tamara order status changed to negative event [{$eventType}]. Deleting pending order.", [
                    'order_number' => $orderNumber,
                ]);
                $order->delete();
            }

            DB::commit();

        } catch (\Throwable $e) {
            DB::rollBack();

            Log::error('Tamara webhook critical error processing:', [
                'message' => $e->getMessage(),
                'order_number' => $orderNumber,
            ]);

            return response()->json(['status' => false, 'error' => 'Internal server error'], 500);
        }

        // 7. إرسال الإيميلات خارج الـ Transaction لضمان سرعة الاستجابة للسيرفر
        if ($shouldSendEmails && $order) {

            try {
                Mail::to($order->shipping_email ?? $order->user->email)->send(new OrderPaidMail($order));
                Mail::to(['info@kdx-sa.com', 'support@kdx-sa.com'])->send(new NewOrderAdminMail($order));
            } catch (\Exception $mailException) {
                Log::error('Tamara Webhook Mail Sending Error:', ['message' => $mailException->getMessage()]);
            }
        }
    }

    /**
     * هذه الدالة مخصصة فقط لاستقبال المستخدم العائد من صفحة تمارة بعد الإلغاء
     */
    public function handleTamaraCancel(Request $request, $order_number)
    {
        $order = Order::where('order_number', $order_number)->firstOrFail();

        // هنا نقوم بتحديث الحالة فقط إذا كان الطلب لم يُدفع بعد
        if ($order->payment_status !== 'paid') {
            $order->delete();
        }

        // بدلاً من إرجاع JSON، نقوم بتحويل المستخدم لصفحة الطلبات مع رسالة تنبيه
        return redirect()->route('cart.checkout')->with('error', __('messages.order_cancel_success'));
    }
}
