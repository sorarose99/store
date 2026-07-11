<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderStatusHistory extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'order_id',
        'old_status',
        'new_status',
        'notes',
        'user_id',
    ];

    /**
     * العلاقات
     */

    // الطلب
    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    // المستخدم
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}