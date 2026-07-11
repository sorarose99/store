<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CartCoupon extends Model
{
    protected $table = 'cart_coupons';

    protected $fillable = [
        'cart_id',
        'coupon_id',
        'code',
        'type',
        'value',
        'discount',
        'applied_at',
    ];

    protected $casts = [
        'applied_at' => 'datetime',
        'discount' => 'decimal:2',
        'value' => 'decimal:2',
    ];

    public function cart(): BelongsTo
    {
        return $this->belongsTo(Cart::class);
    }

    public function coupon(): BelongsTo
    {
        return $this->belongsTo(Coupon::class);
    }
}
