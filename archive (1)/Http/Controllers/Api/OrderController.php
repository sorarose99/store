<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Address;
use App\Models\Order;
use App\Models\PaymentTransaction;
use App\Models\Review;
use App\Services\CartService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Mpdf\Config\ConfigVariables;
use Mpdf\Mpdf;

class OrderController extends Controller
{
    public function __construct(protected CartService $cartService) {}

    /**
     * عرض صفحة الطلبات
     */
    public function index(Request $request)
    {
        $query = Order::query()
            ->select([
                'id',
                'order_number',
                'total',
                'status',
                'created_at',
            ])
            ->withCount('items')
            ->where('user_id', Auth::id())
            ->latest();

        // فلترة حسب الحالة
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $orders = $query->paginate(10)->withQueryString();

        return response()->json([
            'success' => true,
            'orders' => $orders,
        ]);
    }

    /**
     * عرض تفاصيل طلب معين
     */
    public function show($order_number)
    {
        $order = Order::where('order_number', $order_number)->with([
            'items.review',
            'items' => function ($q) {
                $q->select(
                    'id',
                    'order_id',
                    'product_id',
                    'product_name',
                    'price',
                    'image',
                    'quantity',
                    'total',
                    'options'
                );
            },
            'items.product:id,name_ar,slug,requires_shipping',
        ])
            ->where('user_id', Auth::id())
            ->firstOrFail();
        $steps = Order::PROGRESS_STEPS;
        $icons = Order::PROGRESS_ICONS;

        return response()->json([
            'success' => true,
            'order' => $order,
            'steps' => $steps,
            'icons' => $icons,
        ]);
    }

    /**
     * إلغاء طلب
     */
    public function cancel($order_number)
    {
        $order = Order::where('user_id', Auth::id())
            ->where('order_number', $order_number)
            ->first();

        if (! $order) {
            return response()->json([
                'success' => false,
                'message' => __('messages.order_not_found'),
            ], 404);
        }

        // 1) التحقق من السماح
        if (! $order->canBeCancelled()) {
            return response()->json([
                'success' => false,
                'message' => __('messages.order_cancel_not_allowed'),
            ], 422);
        }

        // 2) تنفيذ الإلغاء
        DB::beginTransaction();

        try {

            $order->status = 'cancelled';
            $order->cancelled_at = now();
            $order->save();

            DB::commit();
            $message = $order->payment_status === 'paid'
                ? __('messages.order_cancel_paid_success')
                : __('messages.order_cancel_success');

            return response()->json([
                'success' => true,
                'message' => $message,
            ], 200);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => __('messages.order_cancel_error'),
            ], 500);
        }
    }

    /**
     * انشاء طلب
     */
    public function store(Request $request)
    {
        $request->validate([
            'notes' => 'nullable|string|max:255',
            'payment_gateway' => 'required|in:paytabs,tabby,tamara',
        ]);

        $cart = $this->cartService->summary();

        if (empty($cart['items'])) {
            return response()->json([
                'success' => false,
                'message' => __('messages.cart_empty'),
            ], 400);
        }

        $address = Address::where('id', $request->address_id)
            ->where('user_id', Auth::id())
            ->first();

        if (! $address) {
            return response()->json([
                'success' => false,
                'message' => __('messages.invalid_shipping_address'),
            ], 422);
        }

        DB::beginTransaction();

        try {

            $order = Order::create([
                'user_id' => Auth::id(),
                'subtotal' => $cart['subtotal'],
                'shipping_cost' => $cart['shipping_cost'],
                'tax' => $cart['tax_amount'],
                'discount' => $cart['discount'],
                'total' => $cart['total'],
                'payment_method' => $request->payment_gateway ?? 'paytabs',
                'shipping_full_name' => $address->full_name,
                'shipping_phone' => $address->phone,
                'shipping_email' => $address->email,
                'shipping_country' => $address->country,
                'shipping_city' => $address->city,
                'shipping_postal_code' => $address->postal_code,
                'shipping_address' => $address->address,
                'payment_status' => 'pending',
                'notes' => $request->notes,
            ]);

            foreach ($cart['items'] as $item) {
                $order->items()->create([
                    'product_id' => $item['id'],
                    'product_name' => $item['name'],
                    'price' => $item['price'],
                    'image' => $item['image'],
                    'sku' => $item['sku'],
                    'quantity' => $item['quantity'],
                    'total' => $item['price'] * $item['quantity'],
                    'options' => json_encode([
                        'breakdown' => $item['breakdown'] ?? [],
                    ]),
                ]);
            }

            DB::commit();

            // =========================
            // وضع تجريبي
            // =========================
            if (env('PAYMENT_MODE') === 'fake') {

                $order->update([
                    'payment_status' => 'paid',
                ]);

                PaymentTransaction::create([
                    'order_id' => $order->id,
                    'user_id' => $order->user_id,
                    'payment_method' => 'fake',
                    'status' => 'completed',
                    'amount' => $order->total,
                    'transaction_id' => 'TEST-'.uniqid(),
                    'paid_at' => now(),
                    'response' => json_encode(['message' => 'Fake payment success']),
                ]);

                // تسجيل تغيير الحالة عند نجاح الدفع
                $order->statusHistories()->create([
                    'old_status' => 'pending',
                    'new_status' => 'pending',
                    'notes' => 'تم تأكيد الدفع',
                    'user_id' => $order->user_id,
                ]);

                // تفريغ السلة
                $this->cartService->clear();

                return response()->json([
                    'success' => true,
                    'message' => 'تم إنشاء الطلب بنجاح',
                    'order_number' => $order->order_number,
                ]);
            }

            // =========================
            // الدفع الحقيقي
            // =========================
            $routes = [
                'tamara' => 'payments.tamara.pay',
                'tabby' => 'payments.tabby.pay',
                'paytabs' => 'api-payments.paytabs.pay', // <-- Points to the new API controller!
            ];

            $route = $routes[$request->payment_gateway];

            return response()->json([
                'success' => true,
                'type' => 'redirect',
                'payment_url' => route($route, [
                    'order_number' => $order->order_number,
                ]),
            ]);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => __('messages.order_create_error'),
            ], 500);
        }
    }

    // اضافة تقييم من قبل العميل بصفحة تفاصيل الطلب
    public function addReview(Request $request)
    {
        $request->validate([
            'order_id' => 'required|exists:orders,id',
            'product_id' => 'required|exists:products,id',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:500',
        ]);

        // منع احد من التقييم لطلب عميل اخر
        $order = Order::findOrFail($request->order_id);
        if ($order->user_id !== Auth::id()) {
            abort(403);
        }

        // التأكد أن المنتج داخل الطلب
        $productExistsInOrder = $order->items()
            ->where('product_id', $request->product_id)
            ->exists();

        if (! $productExistsInOrder) {
            return response()->json([
                'success' => false,
                'message' => __('messages.product_not_found_in_order'),
            ], 422);
        }

        // التحقق من أن المستخدم لم يقيم هذا المنتج من قبل لهذا الطلب
        $existingReview = Review::where('user_id', Auth::id())
            ->where('order_id', $request->order_id)
            ->where('product_id', $request->product_id)
            ->exists();

        if ($existingReview) {
            return response()->json([
                'success' => false,
                'message' => __('messages.order_review_already_exists'),
            ], 422);
        }

        Review::create([
            'user_id' => Auth::id(),
            'order_id' => $request->order_id,
            'product_id' => $request->product_id,
            'rating' => $request->rating,
            'comment' => $request->comment,
            'status' => 'approved',
        ]);

        return response()->json([
            'success' => true,
            'message' => __('messages.order_review_success'),
        ], 201);
    }

    /**
     * طباعة فاتورة الطلب
     */
    public function invoice($order_number)
    {
        // جلب الطلب مع التأكد أنه يعود للمستخدم الحالي
        $order = Order::select(
            'id',
            'order_number',
            'user_id',
            'subtotal',
            'shipping_cost',
            'tax',
            'discount',
            'total',
            'payment_method',
            'payment_status',
            'status',
            'shipping_full_name',
            'shipping_phone',
            'shipping_country',
            'shipping_city',
            'shipping_address',
            'created_at'
        )
            ->where('order_number', $order_number)
            ->where('user_id', Auth::id())
            ->with([
                'paymentTransaction:order_id,transaction_id',

                'user:id,first_name,last_name,email,phone',

                'items:id,order_id,product_name,sku,price,image,quantity,total',
            ])
            ->firstOrFail();

        // اسم ومسار الملف
        $fileName = 'order-'.$order->order_number.'.pdf';
        $filePath = 'invoices/'.$fileName;

        // إنشاء الملف فقط إذا غير موجود
        if (! Storage::disk('public')->exists($filePath)) {

            $locale = app()->getLocale();
            $fontPath = public_path('fonts');

            $config = [
                'mode' => 'utf-8',
                'format' => 'A4',
                'orientation' => 'P',
                'default_font' => $locale === 'ar' ? 'cairo' : 'dejavusans',
                'default_font_size' => 11,
                'autoScriptToLang' => true,
                'autoLangToFont' => true,
            ];

            // إعداد الخطوط
            $config['fontDir'] = array_merge(
                (new ConfigVariables)->getDefaults()['fontDir'],
                [$fontPath]
            );

            $config['fontdata'] = [
                'cairo' => [
                    'R' => 'Cairo-Regular.ttf',
                    'B' => 'Cairo-Bold.ttf',
                ],
            ];

            $mpdf = new Mpdf($config);

            // اتجاه اللغة
            $mpdf->SetDirectionality($locale === 'ar' ? 'rtl' : 'ltr');

            // توليد HTML
            $html = view('admin.orders.invoice', compact('order'))->render();

            $mpdf->WriteHTML($html);

            // حفظ الملف في storage
            Storage::disk('public')->put($filePath, $mpdf->Output('', 'S'));
        }

        return response()->json([
            'success' => true,
            'url' => Storage::disk('public')->url($filePath),
        ]);
    }
}
