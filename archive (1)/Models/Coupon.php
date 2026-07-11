<?php

namespace App\Models;

use App\Traits\SanitizesInput;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Coupon extends Model
{
    use HasFactory, SanitizesInput;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'code',
        'type',
        'value',
        'min_order',
        'max_discount',
        'starts_at',
        'expires_at',
        'usage_limit',
        'usage_count',
        'usage_limit_per_user',
        'description',
        'status',
    ];
    protected $sanitize = [
        'code',
        'description'
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'value' => 'decimal:2',
        'min_order' => 'decimal:2',
        'max_discount' => 'decimal:2',
        'usage_count' => 'integer',
        'usage_limit' => 'integer',
        'usage_limit_per_user' => 'integer',
        'starts_at' => 'datetime',
        'expires_at' => 'datetime',
    ];

    /**
     * العلاقات
     */

    // المستخدمين الذين استخدموا الكوبون
    public function users()
    {
        return $this->belongsToMany(User::class, 'coupon_usages')
            ->withPivot('order_id')
            ->withTimestamps();
    }

    // الطلبات التي استخدمت الكوبون
    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    /**
     * الدوال المساعدة
     */

    // التحقق من صحة الكوبون
    public function isValid()
    {
        // التحقق من النشاط
        if ($this->status === 'inactive') {
            return false;
        }

        // التحقق من تاريخ البدء
        if ($this->starts_at && $this->starts_at->isFuture()) {
            return false;
        }

        // التحقق من تاريخ الانتهاء
        if ($this->expires_at && $this->expires_at->isPast()) {
            return false;
        }

        // التحقق من حد الاستخدام
        if ($this->usage_limit && $this->usage_count >= $this->usage_limit) {
            return false;
        }

        return true;
    }

    // التحقق من إمكانية استخدام المستخدم
    public function canUserUse($userId)
    {
        if (!$this->usage_limit_per_user) {
            return true;
        }

        $usageCount = $this->users()
            ->where('user_id', $userId)
            ->count();

        return $usageCount < $this->usage_limit_per_user;
    }

    // حساب قيمة الخصم
    public function calculateDiscount($subtotal)
    {
        if ($this->min_order && $subtotal < $this->min_order) {
            return 0;
        }

        $discount = $this->type === 'fixed'
            ? $this->value
            : ($subtotal * $this->value / 100);

        if ($this->max_discount && $discount > $this->max_discount) {
            $discount = $this->max_discount;
        }

        return $discount;
    }

}
