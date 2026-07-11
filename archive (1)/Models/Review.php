<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'product_id',
        'order_id',
        'rating',
        'comment',
        'status',
        'admin_reply',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'rating' => 'integer',
    ];

    /**
     * العلاقات
     */

    // المستخدم
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // المنتج
    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    // الطلب
    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}