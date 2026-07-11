<?php

namespace App\Http\Controllers;

use App\Models\Address;
use App\Models\Coupon;
use App\Models\PaymentGateway;
use App\Models\Product;
use App\Models\ProductImage;
use App\Models\ShippingZone;
use App\Services\CartService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CartController extends Controller
{
    public function __construct(protected CartService $cartService) {}

    public function index()
    {
        $zones = ShippingZone::where('status', 'active')->limit(15)->get();
        $cart = $this->cartService->summary();
        $selectedZone = $this->cartService->getShippingZoneId();
        $tabbyGateway = PaymentGateway::where('name', 'tabby')->where('is_active', 1)->select('credentials')->first();

        return view('cart.index', compact('zones', 'cart', 'selectedZone', 'tabbyGateway'));
    }

    /**
     * إضافة منتج إلى السلة
     */
    public function add(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'integer|min:1',
            'image_id' => 'nullable|exists:product_images,id',
        ]);

        // جلب معلومات الصورة المختارة
        $selectedImage = null;
        if ($request->image_id) {
            $selectedImage = ProductImage::find($request->image_id);
        }

        $product = Product::findOrFail($request->product_id);
        $quantity = $request->input('quantity', 1);
        $options = $request->input('options', []);

        $product_sizes = $product->sizes->map(function ($size) {
            return ['name' => $size->name];
        });

        // الحصول على السلة الحالية
        $cart = $this->cartService->get();
        // إنشاء معرف فريد يجمع بين المنتج والصورة
        $productId = $product->id;
        if ($request->image_id) {
            $productId = $product->id.'_img_'.$request->image_id;
        }

        $price = $product->sale_price ?? $product->price;

        if (isset($cart[$productId])) {
            // تحديث الكمية للمنتج الموجود
            $cart[$productId]['quantity'] += $quantity;
            $cart[$productId]['breakdown'] = [];
        } else {
            // تحديد الصورة التي ستظهر في السلة
            $imageUrl = $product->primary_image_url;
            if ($selectedImage) {
                $imageUrl = asset($selectedImage->path);
            }

            // إضافة منتج جديد
            $cart[$productId] = [
                'id' => $product->id,
                'cart_item_id' => $productId, // المعرف الفريد في السلة
                'name' => app()->getLocale() == 'ar' ? $product->name_ar : $product->name_en,
                'slug' => $product->slug,
                'sku' => $product->sku,
                'price' => $price,
                'quantity' => $quantity,
                'options' => $options,
                'image' => $imageUrl, // الصورة المختارة
                'image_id' => $request->image_id, // حفظ معرف الصورة
                'weight' => $product->weight ?? 0,
                'tax_exempt' => $product->tax_exempt ?? false,
                'requires_shipping' => $product->requires_shipping ?? false,
                'product_sizes' => $product_sizes,
                'breakdown' => [],
            ];
        }

        // حفظ السلة كاملة
        $this->cartService->save($cart);

        // التحقق من الحفظ
        $this->cartService->get();

        $summary = $this->cartService->summary();
        $result = [
            'success' => true,
            'message' => __('messages.cart_item_added'),
            'cart' => $summary,
            'total_items' => $this->cartService->countItems(),
            'total_price' => $summary['subtotal'],
        ];

        return response()->json($result);

    }

    /**
     * تحديث كمية منتج
     */
    public function update(Request $request, $cartItemId)
    {
        $request->validate([
            'quantity' => 'required|integer|min:1',
        ]);

        $cart = $this->cartService->get();

        if (! isset($cart[$cartItemId])) {
            $result = [
                'success' => false,
                'message' => __('messages.cart_item_not_found'),
            ];
        } elseif ($request->quantity <= 0) {
            $result = $this->remove($cartItemId);
        } else {
            $cart[$cartItemId]['quantity'] = $request->quantity;

            // عند تغير الكمية للمنتج امسح التوزيع لأنه صار غير صالح
            $cart[$cartItemId]['breakdown'] = [];

            $this->cartService->save($cart);

            $summary = $this->cartService->summary();

            $result = [
                'success' => true,
                'message' => __('messages.cart_quantity_updated'),
                'subtotal' => number_format($summary['subtotal'], 2),
                'tax_amount' => number_format($summary['tax_amount'], 2),
                'tax_rate' => number_format($summary['tax_rate'], 2).' %',
                'shipping_cost' => number_format($summary['shipping_cost'], 2),
                'discount' => number_format($summary['discount'], 2),
                'discount_num' => $summary['discount'],
                'total' => number_format($summary['total'], 2),
                'total_items' => $summary['total_items'],
                'item_total' => number_format(
                    $cart[$cartItemId]['price'] * $cart[$cartItemId]['quantity'],
                    2
                ),
            ];
        }

        return response()->json($result);

    }

    /**
     * حذف منتج من السلة
     */
    public function remove($cartItemId)
    {
        $cart = $this->cartService->get();

        if (! isset($cart[$cartItemId])) {
            $result = [
                'success' => false,
                'message' => __('messages.cart_item_not_found'),
            ];
        } else {
            unset($cart[$cartItemId]);

            $this->cartService->save($cart);

            $summary = $this->cartService->summary();

            $result = [
                'success' => true,
                'message' => __('messages.cart_item_removed'),
                'subtotal' => number_format($summary['subtotal'], 2),
                'tax_amount' => number_format($summary['tax_amount'], 2),
                'tax_rate' => number_format($summary['tax_rate'], 2).' %',
                'shipping_cost' => number_format($summary['shipping_cost'], 2),
                'discount' => number_format($summary['discount'], 2),
                'discount_num' => $summary['discount'],
                'total' => number_format($summary['total'], 2),
                'total_items' => $summary['total_items'],
            ];
        }

        return response()->json($result);

    }

    /**
     * تفريغ السلة بالكامل
     */
    public function clear()
    {
        $this->cartService->clear();

        $result = [
            'success' => true,
            'message' => __('messages.cart_cleared'),
            'cart' => [],
            'total_items' => 0,
            'total_price' => 0,
        ];

        return redirect()->route('cart.index')->with('success', $result['message']);
    }

    /**
     * تطبيق كود خصم
     */
    public function applyCoupon(Request $request)
    {
        $request->validate([
            'coupon_code' => 'required|string',
        ]);

        $userId = Auth::id();

        // البحث عن الكوبون في قاعدة البيانات
        $coupon = Coupon::where('code', $request->coupon_code)->first();

        if (! $coupon) {
            $result = ['success' => false, 'message' => __('messages.coupon_invalid')];
        } elseif (! $coupon->isValid()) {
            $result = ['success' => false, 'message' => __('messages.coupon_invalid_or_expired')];
        } elseif (! $coupon->canUserUse($userId)) {
            $result = ['success' => false, 'message' => __('messages.coupon_usage_exceeded')];
        } else {
            $summary = $this->cartService->summary();
            $subtotal = $summary['subtotal'];
            $discount = $coupon->calculateDiscount($subtotal);

            if ($discount <= 0) {
                $result = ['success' => false, 'message' => __('messages.coupon_not_applicable')];
            } else {
                $this->cartService->applyCoupon($coupon, $discount);

                $summary = $this->cartService->summary();

                $result = [
                    'success' => true,
                    'message' => __('messages.coupon_applied'),
                    'subtotal' => number_format($summary['subtotal'], 2),
                    'tax_rate' => number_format($summary['tax_rate'], 2).' %',
                    'shipping_cost' => number_format($summary['shipping_cost'], 2),
                    'discount' => number_format($summary['discount'], 2),
                    'discount_num' => $summary['discount'],
                    'total' => number_format($summary['total'], 2),
                    'total_items' => $summary['total_items'],
                    'coupon_code' => $coupon->code,
                    'coupon_type' => $coupon->type,
                    'coupon_value' => $coupon->value,
                ];
            }
        }

        return response()->json($result);

    }

    /**
     * إلغاء كود الخصم
     */
    public function removeCoupon(Request $request)
    {
        $this->cartService->removeCoupon();

        $summary = $this->cartService->summary();

        $result = [
            'success' => true,
            'message' => __('messages.coupon_removed'),
            'subtotal' => number_format($summary['subtotal'], 2),
            'tax_rate' => number_format($summary['tax_rate'], 2).' %',
            'shipping_cost' => number_format($summary['shipping_cost'], 2),
            'discount' => number_format($summary['discount'], 2),
            'discount_num' => $summary['discount'],
            'total' => number_format($summary['total'], 2),
            'total_items' => $summary['total_items'],
        ];

        return response()->json($result);

    }

    /**
     * عرض صفحة إتمام الطلب
     */
    public function checkout()
    {
        $cart = $this->cartService->summary();

        if (empty($cart['items'])) {
            return redirect()->route('cart.index')->with('error', __('messages.cart_empty'));
        }

        foreach ($cart['items'] as $item) {
            // حساب مجموع الكميات الموزعة
            $totalBreakdownQty = array_sum(array_column($item['breakdown'], 'qty'));

            // التحقق: إذا كان التوزيع غير موجود أو مجموع الكميات لا يساوي الكمية الإجمالية
            if (empty($item['breakdown']) || $totalBreakdownQty != $item['quantity']) {
                return redirect()->route('cart.index')->with('error', __('messages.please_distribute_sizes_before_checkout', [
                    'product' => $item['name'],
                ]));
            }
        }

        $user = Auth::user();
        $addresses = Address::where('user_id', $user->id)->orderByDesc('is_default')->limit(15)->get();
        $zones = ShippingZone::where('status', 'active')->limit(15)->get();
        $selectedZone = $this->cartService->getShippingZoneId();
        $paymentGateways = PaymentGateway::where('is_active', 1)->select('name')->get();
        $tabbyGateway = PaymentGateway::where('name', 'tabby')->where('is_active', 1)->select('credentials')->first();

        return view('cart.checkout', compact('cart', 'addresses', 'zones', 'selectedZone', 'paymentGateways', 'tabbyGateway'));
    }

    /**
     * الحصول على عداد السلة (للعرض في الهيدر)
     */
    public function getCartCount()
    {
        $count = $this->cartService->countItems();

        return response()->json(['count' => $count]);

    }

    /**
     * تنظيف السلة بعد إتمام الطلب
     */
    public function clearAfterCheckout($orderId = null, $userId = null)
    {
        $couponData = $this->cartService->getCouponData();

        if ($couponData && $userId) {
            $coupon = Coupon::find($couponData['id']);
            if ($coupon) {
                $coupon->increment('usage_count');
                if ($orderId) {
                    $coupon->users()->attach($userId, [
                        'order_id' => $orderId,
                        'used_at' => now(),
                    ]);
                }
            }
        }

        $this->cartService->clear();
    }

    /**
     * حفظ السلة وإرجاع النتيجة
     */
    protected function saveAndReturnResult(array $cart, string $message): array
    {
        $this->cartService->save($cart);
        $summary = $this->cartService->summary();

        return [
            'success' => true,
            'message' => $message,
            'cart' => $summary,
            'total_items' => $this->cartService->count(),
            'total_price' => $summary['subtotal'],
        ];
    }

    /**
     * تحديث منطقة الشحن وحساب التكلفة
     */
    public function updateShippingZone(Request $request)
    {
        $request->validate([
            'zone_id' => 'required|exists:shipping_zones,id',
        ]);

        // حفظ المنطقة المختارة
        $this->cartService->updateShippingZone($request->zone_id);

        // إعادة حساب ملخص السلة
        $summary = $this->cartService->summary();

        return response()->json([
            'success' => true,
            'tax_amount' => number_format($summary['tax_amount'], 2),
            'tax_rate' => number_format($summary['tax_rate'], 2).' %',
            'shipping_cost' => number_format($summary['shipping_cost'], 2),
            'subtotal' => number_format($summary['subtotal'], 2),
            'discount' => number_format($summary['discount'], 2),
            'discount_num' => $summary['discount'],
            'total' => number_format($summary['total'], 2),
        ]);

    }

    /**
     * حفظ توزيع قياسات والوان مع الكمية لهم لكل منتج
     */
    public function updateBreakdown(Request $request, $cartItemId)
    {
        $request->validate([
            'breakdown' => 'nullable|array',
            'breakdown.*.size_name' => 'nullable|string',
            'breakdown.*.qty' => 'nullable|integer|min:1',
        ]);

        $cart = $this->cartService->get();

        if (! isset($cart[$cartItemId])) {
            return response()->json([
                'success' => false,
                'message' => __('messages.product_not_found'),
            ]);
        }

        $totalQty = array_sum(array_column($request->breakdown, 'qty'));

        if ($totalQty > $cart[$cartItemId]['quantity']) {
            return response()->json([
                'success' => false,
                'message' => __('messages.total_distributed_exceeds_required', [
                    'totalQty' => $totalQty,
                    'requiredQty' => $cart[$cartItemId]['quantity'],
                ]),
            ]);
        }

        // التخزين
        $this->cartService->updateBreakdown($cartItemId, $request->breakdown);

        return response()->json([
            'success' => true,
            'message' => __('messages.distribution_saved'),
        ]);
    }
}
