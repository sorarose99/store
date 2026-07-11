<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CartShipping extends Model
{
    protected $table = 'cart_shippings';

    protected $fillable = [
        'cart_id',
        'shipping_zone_id',
        'shipping_cost',
    ];

    protected $casts = [
        'shipping_cost' => 'decimal:2',
    ];

    public function cart(): BelongsTo
    {
        return $this->belongsTo(Cart::class);
    }

    public function shippingZone(): BelongsTo
    {
        return $this->belongsTo(ShippingZone::class, 'shipping_zone_id');
    }
}
