<?php

namespace App\Services;

use App\Models\Cart;
use App\Models\CartCoupon;
use App\Models\CartItem;
use App\Models\Coupon;
use App\Models\ShippingRate;
use App\Models\ShippingZone;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;

class CartService
{
    /* =========================
        CORE HELPERS
    ========================= */

    protected function userId(): ?int
    {
        return Auth::id();
    }

    protected function getCart(): ?Cart
    {
        $userId = $this->userId();

        if (! $userId) {
            return null;
        }

        return Cart::with(['items', 'coupon', 'shipping'])
            ->where('user_id', $userId)
            ->first();
    }

    protected function getOrCreateCart(): Cart
    {
        return Cart::firstOrCreate([
            'user_id' => $this->userId(),
        ]);
    }

    /* =========================
        BASIC
    ========================= */

    public function hasCart(): bool
    {
        return (bool) $this->getCart();
    }

    public function getCartId(): ?int
    {
        return $this->getCart()?->id;
    }

    public function get(): array
    {
        $cart = $this->getCart();

        if (! $cart) {
            return [];
        }

        $items = [];

        foreach ($cart->items as $item) {
            $items[$item->cart_item_id] = [
                'id' => $item->product_id,  // المعرف الأصلي
                'cart_item_id' => $item->cart_item_id,  // المعرف الفريد
                'name' => $item->name,
                'slug' => $item->slug,
                'sku' => $item->sku,
                'price' => (float) $item->price,
                'quantity' => $item->quantity,
                'options' => $item->options ?? [],
                'image' => $item->image,
                'image_id' => $item->image_id,
                'weight' => (float) $item->weight,
                'tax_exempt' => (bool) $item->tax_exempt,
                'requires_shipping' => (bool) $item->requires_shipping,
                'product_sizes' => $item->product_sizes ?? [],
                'breakdown' => $item->breakdown ?? [],
            ];
        }

        return $items;
    }

    public function save(array $cart): void
    {
        // إذا كانت السلة فارغة، احذفها بالكامل
        if (empty($cart)) {
            $cartModel = $this->getCart();
            if ($cartModel) {
                $cartModel->items()->delete();
                $cartModel->coupon()?->delete();
                $cartModel->shipping()?->delete();
                $cartModel->delete();
            }

            return;
        }

        $cartModel = $this->getOrCreateCart();

        $cartModel->items()->delete();

        foreach ($cart as $cartItemId => $item) {

            $productSizes = $item['product_sizes'] ?? [];

            if ($productSizes instanceof Collection) {
                $productSizes = $productSizes->toArray();
            }

            CartItem::create([
                'cart_id' => $cartModel->id,
                'cart_item_id' => $cartItemId, // المعرف الفريد (مثل: 123_img_1)
                'product_id' => $item['id'], // المعرف الأصلي للمنتج (مثل: 123)
                'name' => $item['name'],
                'slug' => $item['slug'] ?? null,
                'sku' => $item['sku'] ?? null,
                'price' => $item['price'],
                'quantity' => $item['quantity'],
                'weight' => $item['weight'] ?? 0,
                'tax_exempt' => $item['tax_exempt'] ?? false,
                'requires_shipping' => $item['requires_shipping'] ?? true,
                'image' => $item['image'] ?? null,
                'image_id' => $item['image_id'] ?? null,
                'options' => $item['options'] ?? [],
                'product_sizes' => $productSizes,
                'breakdown' => $item['breakdown'] ?? [],
            ]);
        }

        $cartModel->load('items');

        if ($cartModel->coupon) {
            $this->reapplyCoupon();
        }

        $this->updateShippingCost();
    }

    public function clear(): void
    {
        $cart = $this->getCart();

        if (! $cart) {
            return;
        }

        $cart->items()->delete();
        $cart->coupon()?->delete();
        $cart->shipping()?->delete();
        $cart->delete();
    }

    public function clearByUserId(int $userId): void
    {
        $cart = Cart::where('user_id', $userId)->first();

        if (! $cart) {
            return;
        }

        $cart->items()->delete();
        $cart->coupon()?->delete();
        $cart->shipping()?->delete();
        $cart->delete();
    }

    public function count22(): int
    {
        $cart = $this->getCart();

        return $cart?->items->sum('quantity') ?? 0;
    }

    /**
     * عدد المنتجات الفريدة في السلة (للعرض في الهيدر)
     */
    public function countItems(): int
    {
        $cart = $this->getCart();

        return $cart?->items->count() ?? 0;
    }

    /**
     * إجمالي عدد القطع (مجموع الكميات) - للحسابات الداخلية
     */
    public function countQuantities(): int
    {
        $cart = $this->getCart();

        return $cart?->items->sum('quantity') ?? 0;
    }

    // للحفاظ على التوافق مع الكود القديم
    public function count(): int
    {
        return $this->countQuantities();
    }

    /* =========================
        SUMMARY
    ========================= */

    public function summary(): array
    {
        $cart = $this->getCart();

        if (! $cart) {
            return [
                'items' => [],
                'subtotal' => 0,
                'total_items' => 0,
                'total_quantities' => 0,
                'taxable_subtotal' => 0,
                'tax_rate' => 0,
                'tax_amount' => 0,
                'shipping_cost' => 0,
                'discount' => 0,
                'total' => 0,
            ];
        }

        $items = [];

        foreach ($cart->items as $item) {
            $items[] = [
                'id' => $item->product_id,
                'cart_item_id' => $item->cart_item_id,
                'name' => $item->name,
                'sku' => $item->sku,
                'price' => (float) $item->price,
                'quantity' => $item->quantity,
                'subtotal' => $item->price * $item->quantity,
                'image' => $item->image,
                'product_sizes' => $item->product_sizes ?? [],
                'breakdown' => $item->breakdown ?? [],
            ];
        }

        $subtotal = array_sum(array_column($items, 'subtotal'));

        $shipping = $this->calculateShipping();
        $taxRate = $this->getTaxRate();
        $taxAmount = $this->calculateTaxAmount();
        $discount = $this->getCouponDiscount();

        $total = $subtotal + $shipping + $taxAmount - $discount;

        return [
            'items' => $items,
            'subtotal' => $subtotal,
            'total_items' => $this->countItems(),      // عدد المنتجات الفريدة
            'total_quantities' => $this->countQuantities(), // إجمالي القطع
            'taxable_subtotal' => $this->getTaxableSubtotal(),
            'tax_rate' => $taxRate,
            'tax_amount' => $taxAmount,
            'shipping_cost' => $shipping,
            'discount' => $discount,
            'total' => $total,
        ];
    }

    /* =========================
        COUPON
    ========================= */

    public function getCouponDiscount(): float
    {
        return (float) optional($this->getCart()?->coupon)->discount ?? 0;
    }

    public function getCouponData(): ?array
    {
        $coupon = $this->getCart()?->coupon;

        if (! $coupon) {
            return null;
        }

        return [
            'id' => $coupon->coupon_id,
            'code' => $coupon->code,
            'discount' => (float) $coupon->discount,
            'type' => $coupon->type,
            'value' => (float) $coupon->value,
            'applied_at' => $coupon->applied_at,
        ];
    }

    public function applyCoupon(Coupon $coupon, float $discount): void
    {
        $cart = $this->getOrCreateCart();

        $cart->coupon()?->delete();

        CartCoupon::create([
            'cart_id' => $cart->id,
            'coupon_id' => $coupon->id,
            'code' => $coupon->code,
            'type' => $coupon->type,
            'value' => $coupon->value,
            'discount' => $discount,
            'applied_at' => now(),
        ]);
    }

    public function removeCoupon(): void
    {
        $this->getCart()?->coupon()?->delete();
    }

    protected function reapplyCoupon(): void
    {
        $cart = $this->getCart();

        if (! $cart || ! $cart->coupon) {
            return;
        }

        $coupon = Coupon::find($cart->coupon->coupon_id);

        if (! $coupon || ! $coupon->isValid()) {
            $this->removeCoupon();

            return;
        }

        $subtotal = $this->summary()['subtotal'];

        if ($coupon->min_order_amount && $subtotal < $coupon->min_order_amount) {
            $this->removeCoupon();

            return;
        }

        $discount = $coupon->calculateDiscount($subtotal);

        if ($discount <= 0) {
            $this->removeCoupon();

            return;
        }

        $cart->coupon->update(['discount' => $discount]);
    }

    public function updateCouponDiscount(float $discount): void
    {
        $this->getCart()?->coupon?->update([
            'discount' => $discount,
        ]);
    }

    /* =========================
        SHIPPING
    ========================= */

    public function getShippingZoneId(): ?int
    {
        return $this->getCart()?->shipping?->shipping_zone_id;
    }

    public function updateShippingZone(int $zoneId): void
    {
        $cart = $this->getOrCreateCart();

        $cart->shipping()?->updateOrCreate(
            ['cart_id' => $cart->id],
            ['shipping_zone_id' => $zoneId, 'shipping_cost' => 0]
        );

        $this->updateShippingCost();
    }

    protected function updateShippingCost(): void
    {
        $cart = $this->getCart();

        if (! $cart) {
            return;
        }

        $cost = $this->calculateShippingRaw();

        $cart->shipping?->update([
            'shipping_cost' => $cost,
        ]);
    }

    public function calculateShipping(): float
    {
        return (float) $this->getCart()?->shipping?->shipping_cost ?? 0;
    }

    protected function calculateShippingRaw(): float
    {
        $zoneId = $this->getShippingZoneId();

        if (! $zoneId) {
            return 0;
        }

        $cart = $this->get();
        $weight = 0;
        $hasShippableItems = false; // مؤشر للتحقق هل السلة تحتوي على أي شيء يشحن؟

        foreach ($cart as $item) {
            // التحقق الآمن من حالة الشحن
            $requiresShipping = filter_var($item['requires_shipping'] ?? false, FILTER_VALIDATE_BOOLEAN);

            if ($requiresShipping === false) {
                continue;
            }

            // إذا وصلنا هنا، يعني أن هناك منتج واحد على الأقل يتطلب شحناً فعلياً
            $hasShippableItems = true;
            $weight += ($item['weight'] ?? 0) * $item['quantity'];
        }

        // الـجدار الحامي: إذا كانت السلة خالية تماماً من المنتجات التي تتطلب شحناً
        if (! $hasShippableItems) {
            return 0;
        }

        // الحساب من قاعدة البيانات يتم فقط إذا كان هناك منتجات قابلة للشحن بالوزن المستخرج
        $rate = ShippingRate::where('zone_id', $zoneId)
            ->where('weight_from', '<=', $weight)
            ->where('weight_to', '>=', $weight)
            ->first();

        return $rate?->cost ?? 0;
    }

    public function getTaxRate(): float
    {
        $zoneId = $this->getShippingZoneId();

        if (! $zoneId) {
            return 0;
        }

        return (float) optional(ShippingZone::find($zoneId))->tax_rate ?? 0;
    }

    public function calculateTaxAmount(): float
    {
        return round($this->getTaxableSubtotal() * ($this->getTaxRate() / 100), 2);
    }

    public function getTaxableSubtotal(): float
    {
        $cart = $this->getCart();

        if (! $cart) {
            return 0;
        }

        $total = 0;

        foreach ($cart->items as $item) {
            if (! $item->tax_exempt) {
                $total += $item->price * $item->quantity;
            }
        }

        return $total;
    }

    /* =========================
        BREAKDOWN
    ========================= */

    public function updateBreakdown(string $cartItemId, array $breakdown): void
    {
        $this->getCart()
            ?->items()
            ->where('cart_item_id', $cartItemId)
            ->update(['breakdown' => $breakdown]);
    }
}
