<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CartItem extends Model
{
    protected $table = 'cart_items';

    protected $fillable = [
        'cart_id',
        'cart_item_id',
        'product_id',
        'name',
        'slug',
        'sku',
        'price',
        'quantity',
        'weight',
        'tax_exempt',
        'requires_shipping',
        'image',
        'options',
        'product_sizes',
        'breakdown',
    ];

    protected $casts = [
        'options' => 'array',
        'product_sizes' => 'array',
        'breakdown' => 'array',
        'price' => 'decimal:2',
        'weight' => 'decimal:2',
        'tax_exempt' => 'boolean',
        'requires_shipping' => 'boolean',
    ];

    public function cart(): BelongsTo
    {
        return $this->belongsTo(Cart::class);
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function getSubtotalAttribute(): float
    {
        return $this->price * $this->quantity;
    }
}
