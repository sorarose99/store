<?php

namespace App\Http\Controllers;

use App\Mail\NewOrderAdminMail;
use App\Mail\OrderPaidMail;
use App\Models\Notification;
use App\Models\Order;
use App\Models\PaymentGateway;
use App\Models\PaymentTransaction;
use App\Models\Product;
use App\Services\CartService;
use App\Services\TabbyService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class TabbyController extends Controller
{
    public function __construct(
        protected CartService $cartService
    ) {}

    /**
     * إنشاء رابط الدفع مع فحص القيود وجمع البيانات التاريخية
     */
    public function pay(Request $request)
    {
        $request->validate([
            'order_number' => 'required|string|exists:orders,order_number',
        ]);

        $order = Order::with(['user', 'items'])
            ->where('order_number', $request->order_number)
            ->firstOrFail();

        if ($order->user_id !== Auth::id()) {
            abort(403);
        }

        // 1. التحقق من حصر الخدمة للمملكة العربية السعودية فقط (حسب طلب تابي)
        $country = strtoupper($order->shipping_country ?? '');
        $phone = $order->shipping_phone ?? $order->user->phone ?? '';

        // التحقق من كود الدولة أو بداية رقم الهاتف كأمان إضافي
        if ($country !== 'SA' && ! str_starts_with($phone, '966') && ! str_starts_with($phone, '+966') && ! str_starts_with($phone, '05')) {
            $order->delete();

            return back()->with('error', __('messages.tabby_service_saudi_only'));
        }

        $gateway = PaymentGateway::where('name', 'tabby')
            ->where('is_active', 1)
            ->first();

        if (! $gateway) {
            $order->delete();

            return back()->with('error', __('messages.payment_gateway_inactive'));
        }

        $products = Product::with('categories')
            ->whereIn('id', $order->items->pluck('product_id'))
            ->get()
            ->keyBy('id');

        // 2. إعداد مصفوفة المنتجات مع الـ Category الافتراضية العالية المستوى
        $items = [];
        foreach ($order->items as $item) {
            $product = $products[$item->product_id] ?? null;
            $categoryName = optional($product?->categories->first())->name;

            $items[] = [
                'title' => $item->product_name,
                'quantity' => (int) $item->quantity,
                'unit_price' => number_format($item->price, 2, '.', ''),
                'reference_id' => (string) $item->product_id,
                'category' => $categoryName,
            ];
        }

        // 3. بناء بيانات الـ Buyer History الفردية بناءً على العميل الحالي
        $user = $order->user;
        $registeredSince = $user->created_at ? $user->created_at->toIso8601String() : now()->subMonths(3)->toIso8601String();

        // حساب عدد الطلبات الناجحة المكتملة مسبقاً (Loyalty Level)
        $loyaltyLevel = Order::where('user_id', $user->id)
            ->where('payment_status', 'paid')
            ->where('id', '!=', $order->id)
            ->count();

        // 4. بناء الـ Order History لآخر 5 إلى 10 طلبات سابقة مع عمل Mapping للحالة لقيم تابي المعتمدة
        $previousOrders = Order::where('user_id', $user->id)
            ->where('id', '!=', $order->id)
            ->latest()
            ->take(8)
            ->get();

        $orderHistory = [];
        foreach ($previousOrders as $prevOrder) {
            // دالة mapping الحالات
            $tabbyStatus = $this->mapOrderStatusToTabby($prevOrder->status);

            $orderHistory[] = [
                'purchased_at' => $prevOrder->created_at ? $prevOrder->created_at->toIso8601String() : now()->toIso8601String(),
                'amount' => number_format($prevOrder->total, 2, '.', ''),
                'currency' => $gateway->currency,
                'status' => $tabbyStatus,
                'buyer' => [
                    'phone' => $prevOrder->shipping_phone ?? $prevOrder->user->phone ?? '',
                    'email' => $prevOrder->shipping_email ?? $prevOrder->user->email ?? '',
                    'name' => $prevOrder->shipping_full_name ?? $prevOrder->user->full_name ?? '',
                ],
                'shipping_address' => [
                    'address' => $prevOrder->shipping_address ?? '',
                    'city' => $prevOrder->shipping_city ?? '',
                    'country' => $prevOrder->shipping_country ?? '',
                    'zip' => $prevOrder->shipping_postal_code ?? '',
                ],
            ];
        }

        $tabby = new TabbyService($gateway);

        $responseWrapper = $tabby->createPayment([
            'order_number' => $order->order_number,
            'amount' => $order->total,
            'currency' => $gateway->currency,
            'name' => $order->shipping_full_name ?? $user->full_name,
            'email' => $order->shipping_email ?? $user->email,
            'phone' => $phone,
            'address' => $order->shipping_address,
            'country' => $country,
            'city' => $order->shipping_city,
            'zip' => $order->shipping_postal_code,
            'items' => $items,
            'buyer_history' => [
                'registered_since' => $registeredSince,
                'loyalty_level' => $loyaltyLevel,
            ],
            'order_history' => $orderHistory,
        ]);

        if (! $responseWrapper) {
            $order->delete();

            return back()->with('error', __('messages.payment_creation_failed'));
        }

        $response = $responseWrapper->json();

        // 5. التعامل مع رفض تابي المسبق للعميل (Background Pre-Scoring Rejection) بناءً على سبب الرفض الداخلي
        if ($responseWrapper->status() === 403 || (isset($response['status']) && $response['status'] === 'rejected')) {
            $rejectionReason = $response['configuration']['products']['installments']['rejection_reason'] ?? '';

            if ($rejectionReason === 'order_amount_too_high') {
                $order->delete();

                return back()->with('error', __('messages.order_amount_exceeds_tabby_limit'));
            }

            // افتراضي للسبب 'not_available' أو أي سبب آخر
            $order->delete();

            return back()->with('error', __('messages.tabby_unable_to_approve'));
        }

        // التحقق من وجود روابط الدفع بنجاح
        $paymentUrl = $response['configuration']['available_products']['installments'][0]['web_url'] ?? null;

        if (! $paymentUrl) {
            Log::error('Tabby payment url missing', [
                'response' => $response,
                'order_number' => $order->order_number,
            ]);

            $order->delete();

            return back()->with('error', __('messages.payment_creation_failed'));
        }

        return redirect($paymentUrl);
    }

    // إضافة دالة mapping الحالات
    private function mapOrderStatusToTabby($status)
    {
        $map = [
            'pending' => 'new',
            'processing' => 'processing',
            'shipping' => 'processing',
            'completed' => 'complete',
            'cancelled' => 'canceled',
            'refunded' => 'canceled',
            'failed' => 'canceled',
        ];

        return $map[$status] ?? 'new';
    }

    /**
     * معالجة الـ Webhook القادم من تابي والقيام بالـ Capture المعتمد بالكامل للـ الأمان والتحقق المزدوج
     */
    public function webhook(Request $request)
    {
        $payload = $request->all();

        // استخدام ملف سطر مخصص لتابي لعدم تداخل السجلات
        /*
        Log::build(['driver' => 'single', 'path' => storage_path('logs/tabby_webhook.log')])
            ->info('Tabby Webhook Received', ['status' => $payload['status'] ?? '', 'id' => $payload['id'] ?? '']);
        */
        $status = strtolower($payload['status'] ?? '');
        $orderNumber = $payload['order']['reference_id'] ?? null;

        if (! $orderNumber) {
            return response()->json(['success' => false, 'message' => 'Order reference missing'], 422);
        }

        // 1. جلب بوابة الدفع أولاً قبل فتح الـ Transaction
        $gateway = PaymentGateway::where('name', 'tabby')->where('is_active', 1)->first();
        if (! $gateway) {
            return response()->json(['success' => false, 'message' => 'Gateway inactive'], 422);
        }

        // متغيرات سنحتاجها خارج الـ Transaction لإرسال الإيميلات
        $shouldSendEmails = false;
        $order = null;

        // 2. بدء العمليات الآمنة بقفل قاعدة البيانات
        DB::beginTransaction();
        try {
            // استخدام lockForUpdate() يمنع أي ويبهوك تكراري من قراءة الطلب حتى ينتهي الحالي ويعمل Commit
            $order = Order::with('user')
                ->where('order_number', $orderNumber)
                ->lockForUpdate()
                ->first();

            if (! $order) {
                DB::rollBack();

                return response()->json(['success' => false, 'message' => 'Order not found'], 404);
            }

            // إذا كان مدفوعاً مسبقاً، اخرج فوراً وأغلق القفل بأمان دون حذف
            if ($order->payment_status === 'paid') {
                DB::commit();

                return response()->json(['success' => true, 'message' => 'Already processed']);
            }

            // معالجة حالة التفويض فقط (Authorized)
            if ($status === 'authorized') {
                $tabby = new TabbyService($gateway);
                $payment = $tabby->retrievePayment($payload['id']);

                if (($payment['status'] ?? null) === 'AUTHORIZED') {
                    $capture = $tabby->capturePayment($payload['id'], $order->total);

                    if ($capture && in_array($capture['status'] ?? '', ['CLOSED', 'CAPTURED', 'COMPLETED'])) {

                        // تحديث قاعدة البيانات فوراً وسريعاً
                        $order->update([
                            'payment_status' => 'paid'
                        ]);

                        $this->cartService->clearByUserId($order->user_id);

                        PaymentTransaction::firstOrCreate(
                            ['transaction_id' => $payload['id']],
                            [
                                'order_id' => $order->id,
                                'user_id' => $order->user_id,
                                'payment_method' => 'tabby',
                                'status' => 'completed',
                                'amount' => $order->total,
                                'paid_at' => now(),
                                'payment_data' => json_encode($payload, JSON_UNESCAPED_UNICODE),
                            ]
                        );

                        $order->statusHistories()->create([
                            'old_status' => null,
                            'new_status' => 'pending',
                            'notes' => 'تم إنشاء الطلب ودفع عبر تابي',
                            'user_id' => $order->user_id,
                        ]);

                        Notification::create([
                            'type' => 'order',
                            'audience' => 'admin',
                            'related_id' => $order->id,
                            'title' => 'طلب جديد',
                        ]);

                        // علامة لرفع الأداء: سنقوم بإرسال الإيميلات خارج الـ Transaction
                        $shouldSendEmails = true;
                    } else {
                        // فشل الـ Capture من طرف تابي
                        $order->delete();
                    }
                } else {
                    // تابي أرسل حالة ويبهوك غير مطابقة للواقع عند عمل retrieve
                    $order->delete();
                }

            } elseif ($status === 'rejected' || $status === 'expired') {
                // العميل رُفض أو انتهت الجلسة
                $order->delete();
            }

            // إغلاق الـ Transaction فوراً وتحرير قفل الـ Database للطلبات التكرارية الأخرى
            DB::commit();

        } catch (\Throwable $e) {
            DB::rollBack();

            Log::error('Tabby webhook error processing', [
                'message' => $e->getMessage(),
                'order_number' => $orderNumber,
            ]);

            // الحذف يتم فقط إذا كان هناك استثناء حقيقي والطلب لم يُدفع أبداً
            if ($order && $order->fresh() && $order->fresh()->payment_status !== 'paid') {
                $order->delete();
            }

            return response()->json(['success' => false], 500);
        }

        // 3. إرسال الإيميلات والإشعارات (خارج الـ Transaction والـ Lock لسرعة الاستجابة)
        if ($shouldSendEmails && $order) {
            try {
                Mail::to($order->shipping_email ?? $order->user->email)->send(new OrderPaidMail($order));
                Mail::to(['info@kdx-sa.com', 'support@kdx-sa.com'])->send(new NewOrderAdminMail($order));
            } catch (\Exception $mailException) {
                Log::error('Tabby Webhook Mail Sending Error', ['message' => $mailException->getMessage()]);
            }
        }

        return response()->json(['success' => true]);
    }

    /**
     * معالجة رجوع المستخدم عند إلغاء الدفع المباشر وإعادة إتاحة السلة له للطلب مجدداً
     */
    public function handleTabbyCancel(Request $request, $order_number)
    {
        $order = Order::where('order_number', $order_number)->firstOrFail();

        if ($order->payment_status !== 'paid') {
            $order->delete();
        }

        // تحويله لصفحة الدفع (Checkout) مع تمكينه من المحاولة مرة أخرى بنجاح وعرض رسالة مناسبة للحدث
        return redirect()
            ->route('cart.checkout')
            ->with('error', __('messages.tabby_payment_cancelled'));
    }
}
