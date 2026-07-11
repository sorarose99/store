<?php

namespace App\Models;

use App\Traits\SanitizesInput;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory, SanitizesInput;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
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
        'shipping_email',
        'shipping_country',
        'shipping_city',
        'shipping_postal_code',
        'shipping_address',
        'notes',
        'admin_notes',
        'cancellation_reason',
        'cancelled_by',
        'cancelled_at',
        'completed_at',
    ];

    protected $sanitize = [
        'order_number',
        'payment_method',
        'shipping_full_name',
        'shipping_phone',
        'shipping_email',
        'shipping_country',
        'shipping_city',
        'shipping_postal_code',
        'shipping_address',
        'notes',
        'admin_notes',
        'cancellation_reason',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'subtotal' => 'decimal:2',
        'shipping_cost' => 'decimal:2',
        'tax' => 'decimal:2',
        'discount' => 'decimal:2',
        'total' => 'decimal:2',
        'cancelled_at' => 'datetime',
        'completed_at' => 'datetime',
    ];

    /**
     * العلاقات
     */

    // المستخدم
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // عناصر الطلب
    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }


    // المدفوعات
    //بيانات حركة الدفع للطلب
    public function paymentTransaction()
    {
        return $this->hasOne(PaymentTransaction::class);
    }

    // سجل الحالات
    public function statusHistories()
    {
        return $this->hasMany(OrderStatusHistory::class);
    }

    // من قام بالإلغاء
    public function cancelledBy()
    {
        return $this->belongsTo(User::class, 'cancelled_by');
    }

    /**
     * الدوال المساعدة
     */

    // إنشاء رقم طلب تلقائي
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($order) {
            $order->order_number = 'ORD-' . now()->format('YmdHisv') . random_int(100, 999);
        });
    }

    // حساب الإجمالي
    public function calculateTotal()
    {
        $this->total = $this->subtotal + $this->shipping_cost + $this->tax - $this->discount;
        $this->save();
    }

    // تحديث حالة الدفع
    public function updatePaymentStatus($status)
    {
        $this->payment_status = $status;

        if ($status === 'paid') {
            $this->payment_date = now();
        }

        $this->save();
    }

    // التحقق من إمكانية الإلغاء
    public function canBeCancelled()
    {
        return in_array($this->status, ['pending', 'processing']);
    }

    // this needed at customer controller
    public function scopeValid($query)
    {
        return $query->where('status', '!=', 'cancelled');
    }



    /**
     * =========================
     * ORDER STATUS DISPLAY
     * =========================
     * هذه الدوال مسؤولة عن عرض حالة الطلب (للواجهة فقط)
     */

    public function getStatusLabelAttribute()
    {
        return match ($this->status) {
            'pending'    => __('user_interface.order_item_status_pending'),
            'processing' => __('user_interface.order_item_status_processing'),
            'shipped'    => __('user_interface.order_item_status_shipped'),
            'completed'  => __('user_interface.order_item_status_completed'),
            'cancelled'  => __('user_interface.order_item_status_cancelled'),
            default      => '-',
        };
    }

    public function getStatusColorAttribute()
    {
        return match ($this->status) {
            'pending'    => 'pending',
            'processing' => 'processing',
            'shipped'    => 'shipped',
            'completed'  => 'completed',
            'cancelled'  => 'cancelled',
            default      => 'secondary',
        };
    }

    public function getStatusIconAttribute()
    {
        return match ($this->status) {
            'pending'    => 'fas fa-clock',
            'processing' => 'fas fa-spinner',
            'shipped'    => 'fas fa-truck',
            'completed'  => 'fas fa-check-circle',
            'cancelled'  => 'fas fa-times-circle',
            default      => 'fas fa-question-circle',
        };
    }

    /**
     * =========================
     * ORDER PROGRESS SYSTEM
     * =========================
     * هذه الدوال تستخدم لبناء الـ Progress Bar (خطوات الطلب)
     * تظهر للمستخدم والأدمن بنفس الشكل
     */

    public const PROGRESS_STEPS = [
        'order'      => 'order',
        'payment'    => 'payment',
        'pending'    => 'pending',
        'processing' => 'processing',
        'shipped'    => 'shipped',
        'completed'  => 'completed',
    ];


    public const PROGRESS_ICONS = [
        'order'      => 'fa-check',
        'payment'    => 'fa-money-bill',
        'pending'    => 'fa-hourglass-half',
        'processing' => 'fa-spinner',
        'shipped'    => 'fa-truck',
        'completed'  => 'fa-check-circle',
    ];

    /**
     * تحديد المرحلة الحالية للطلب
     * هذه أهم دالة في الـ progress
     */
    public function getCurrentStepAttribute()
    {
        if ($this->status === 'cancelled') {
            return 'cancelled';
        }

        return match (true) {
            $this->status === 'completed'  => 'completed',
            $this->status === 'shipped'    => 'shipped',
            $this->status === 'pending'    => 'pending',
            $this->status === 'processing' => 'processing',

            // إذا تم الدفع ينتقل للمرحلة التالية
            $this->payment_status === 'paid' => 'payment',

            default => 'order',
        };
    }

    /**
     * بناء بيانات الـ Progress كاملة للعرض في الـ Blade
     */
    public function getProgressDataAttribute()
    {
        $steps = self::PROGRESS_STEPS;
        $icons = self::PROGRESS_ICONS;

        $keys = array_keys($steps);
        $currentIndex = array_search($this->current_step, $keys);

        $result = [];

        foreach ($steps as $key => $label) {
            $stepIndex = array_search($key, $keys);

            $class = 'bg-light text-muted';
            $icon = $icons[$key];

            // الخطوات المكتملة
            if ($stepIndex < $currentIndex) {
                $class = 'bg-success text-white';
                $icon = 'fa-check';
            }

            // الخطوة الحالية
            elseif ($stepIndex == $currentIndex) {
                $class = 'bg-warning text-white';
            }

            // حالة فشل الدفع
            if ($key === 'payment' && $this->payment_status === 'failed') {
                $class = 'bg-danger text-white';
                $icon = 'fa-times';
            }

            // حالة الإلغاء
            if ($this->status === 'cancelled') {
                if ($key === 'order') {
                    $class = 'bg-danger text-white';
                    $icon = 'fa-times';
                } else {
                    $class = 'bg-light text-muted';
                }
            }

            $result[] = [
                'key'   => $key,
                'label' => __('user_interface.order_item_status_' . $label),
                'icon'  => $icon,
                'class' => $class,
            ];
        }

        return $result;
    }

    /**
     * نسبة تقدم الطلب (Progress Bar %)
     */
    public function getProgressPercentageAttribute()
    {
        $totalSteps = count(self::PROGRESS_STEPS);
        $keys = array_keys(self::PROGRESS_STEPS);

        $currentIndex = array_search($this->current_step, $keys);

        return (($currentIndex + 1) / $totalSteps) * 100;
    }
}
