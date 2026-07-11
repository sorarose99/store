<?php

namespace App\Http\Controllers;

use App\Mail\NewOrderAdminMail;
use App\Mail\OrderPaidMail;
use App\Models\Notification;
use App\Models\Order;
use App\Models\PaymentGateway;
use App\Models\PaymentTransaction;
use App\Services\CartService;
use App\Services\PayTabsService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class PayTabsController extends Controller
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
        $gateway = PaymentGateway::where('name', 'paytabs')
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

        $paytabs = new PayTabsService($gateway);

        $response = $paytabs->createPayment([
            'order_number' => $order->order_number,
            'amount' => $order->total,
            'currency' => $gateway->currency,
            'name' => $order->user->name,
            'email' => $order->user->email,
            'phone' => $order->user->phone ?? '000000000',

            'address' => $order->shipping_address,
            'country' => $order->shipping_country,
            'city' => $order->shipping_city,
            'state' => $order->shipping_city,
            'zip' => $order->shipping_postal_code,
        ]);

        if (! isset($response['redirect_url'])) {

            Log::error('PayTabs create payment failed', [
                'response' => $response,
            ]);

            $order->delete();

            return back()->with(
                'error',
                __('messages.payment_creation_failed')
            );
        }

        return redirect($response['redirect_url']);

    }

    /**
     * Callback من PayTabs
     */
    public function callback(Request $request)
    {
        // Log::info('PayTabs Callback', $request->all());

        // بوابة الدفع
        $gateway = PaymentGateway::where('name', 'paytabs')
            ->where('is_active', 1)
            ->first();

        if (! $gateway) {
            return response()->json([
                'status' => false,
                'message' => 'Gateway inactive',
            ], 500);
        }

        // التحقق من وجود transaction reference
        if (! $request->filled('tran_ref')) {
            $order->delete();

            return response()->json([
                'status' => false,
                'message' => 'Missing transaction reference',
            ], 422);
        }

        // التحقق من وجود الطلب
        // Log::info('start callback', ['payload' => $request->all()]);
        $order = Order::where('order_number', $request->cart_id)->first();

        if (! $order) {
            return response()->json([
                'status' => false,
                'message' => 'Order not found',
            ], 404);
        }

        // منع التكرار
        if ($order->payment_status === 'paid') {
            return response()->json([
                'status' => true,
                'message' => 'Already processed',
            ]);
        }

        // التحقق من المبلغ
        if (
            (float) $request->cart_amount !==
            (float) $order->total
        ) {
            /*
            Log::warning('PayTabs amount mismatch', [
                'order_id' => $order->id,
                'paytabs_amount' => $request->cart_amount,
                'order_total' => $order->total,
            ]);
            */

            $order->delete();

            return response()->json([
                'status' => false,
                'message' => 'Amount mismatch',
            ], 422);
        }

        DB::beginTransaction();

        try {

            // نجاح الدفع
            if (
                isset($request->payment_result['response_status']) &&
                $request->payment_result['response_status'] === 'A'
            ) {

                // تحديث الطلب
                $order->update([
                    'payment_status' => 'paid'
                ]);

                $this->cartService->clearByUserId($order->user_id); // تفريغ السلة

                // حفظ المعاملة
                PaymentTransaction::firstOrCreate(
                    [
                        'transaction_id' => $request->tran_ref,
                    ],
                    [
                        'order_id' => $order->id,
                        'user_id' => $order->user_id,

                        'payment_method' => 'paytabs',

                        'status' => 'completed',

                        'amount' => $order->total,
                        'paid_at' => now(),

                        'payment_data' => json_encode(
                            $request->all(),
                            JSON_UNESCAPED_UNICODE
                        ),
                    ]
                );

                // تسجيل تغيير الحالة عند إنشاء الطلب
                $order->statusHistories()->create([
                    'old_status' => null,
                    'new_status' => 'pending',
                    'notes' => 'تم إنشاء الطلب',
                    'user_id' => $order->user_id,
                ]);

                Notification::create([
                    'type' => 'order',
                    'audience' => 'admin',
                    'related_id' => $order->id,
                    'title' => 'طلب جديد',
                ]);
                // إرسال رسالة للعميل بنجاح الدفع
                Mail::to($order->shipping_email ?? $order->user->email)->send(new OrderPaidMail($order));

                // إرسال رسالة للادمن بوجود طلب شراء ناجح
                Mail::to(['info@kdx-sa.com', 'support@kdx-sa.com'])->send(new NewOrderAdminMail($order));
            } else {

                $order->delete();
            }

            DB::commit();

            return response()->json([
                'status' => true,
            ]);

        } catch (\Throwable $e) {

            DB::rollBack();
            /*
            Log::error('PayTabs callback error', [
                'message' => $e->getMessage(),
                'payload' => $request->all(),
            ]);
            */

            // حماية حتى لا نحذف طلب قد يكون سُحب ماله فعلياً من العميل بسبب خطأ بريد أو إشعارات بالأسفل
            if ($order && $order->fresh()->payment_status !== 'paid') {
                $order->delete();
            }

            return response()->json([
                'status' => false,
                'message' => 'Server error',
            ], 500);
        }
    }

    /**
     * رجوع المستخدم بعد الدفع
     */
    public function return(Request $request)
    {
        // Log::info('PayTabs return', $request->all());

        // PayTabs قد يرجع cartId أو cart_id
        $orderNumber =
            $request->cartId ??
            $request->cart_id ??
            $request->order_number;

        if (! $orderNumber) {
            // Log::error('PayTabs return missing order number', ['payload' => $request->all(),]);
            return redirect()->route('home')->with('error', __('messages.payment_failed'));
        }

        $order = Order::where('order_number', $orderNumber)->first();

        if (! $order) {
            // Log::error('PayTabs return order not found', ['order_number' => $orderNumber,]);
            return redirect()->route('home')->with('error', __('messages.order_not_found'));
        }

        /**
         * مهم جداً:
         * ننتظر callback يحدث حالة الدفع
         */
        $maxAttempts = 10;

        for ($i = 0; $i < $maxAttempts; $i++) {

            $order->refresh();
            /*
            Log::info('Checking payment status from return', [
                'attempt' => $i + 1,
                'order_number' => $order->order_number,
                'payment_status' => $order->payment_status,
                'status' => $order->status,
            ]);
            */

            // نجاح الدفع
            if ($order->payment_status === 'paid') {
                return redirect()->route('orders.success', $order->order_number);
            }

            // فشل الدفع
            if ($order->payment_status === 'failed') {
                return redirect()->route('orders.failed', $order->order_number);
            }

            // انتظار ثانية
            sleep(1);
        }

        /**
         * إذا callback تأخر جداً
         * نعتبر الطلب pending
         */
        return redirect()->route('orders.show', $order->order_number);
    }
}
