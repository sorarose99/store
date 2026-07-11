<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Auth;

class OrderItem extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'order_id',
        'product_id',
        'product_name',
        'sku',
        'price',
        'image',
        'quantity',
        'total',
        'options',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'price' => 'decimal:2',
        'total' => 'decimal:2',
        'quantity' => 'integer',
        'options' => 'array',
    ];

    /**
     * العلاقات
     */

    // الطلب
    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    // المنتج
    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    //هل المنتج قيم او لا من قبل العميل
    public function review()
    {
        return $this->hasOne(Review::class, 'product_id', 'product_id');
    }

    /**
     * الدوال المساعدة
     */

    // حساب الإجمالي
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($item) {
            $item->total = $item->price * $item->quantity;
        });

        static::updating(function ($item) {
            $item->total = $item->price * $item->quantity;
        });
    }
}
