<?php

namespace App\Models;

use App\Traits\SanitizesInput;
use Carbon\Carbon;
use Database\Factories\UserFactory;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Str;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable implements MustVerifyEmail
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable,SanitizesInput;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'uuid',
        'first_name',
        'last_name',
        'email',
        'register_type',
        'password',
        'phone',
        'verified_at',
        'terms_accepted_at',
        'avatar',
        'gender',
        'birth_date',
        'status',
        'role',
        'last_login_at',
        'last_login_ip',
        'blocked_reason',
        'blocked_at',
        'blocked_by',
    ];

    protected $sanitize = [
        'first_name',
        'last_name',
        'phone',
        'avatar',
        'gender',
        'birth_date',
        'blocked_reason',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'id',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'verified_at' => 'datetime',
            'password' => 'hashed',
            'last_login_at' => 'datetime',
            'blocked_at' => 'datetime',
            'birth_date' => 'date',
        ];
    }

    protected static function booted()
    {
        static::creating(function ($user) {
            $user->uuid = Str::uuid();
        });
    }

    /**
     * العلاقات
     */
    public function devices()
    {
        return $this->hasMany(UserDevice::class);
    }

    // الصلاحيات
    public function permissions()
    {
        return $this->belongsToMany(Permission::class, 'user_permissions', 'user_id', 'permission_id');
    }

    // الطلبات
    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    // عناوين الشحن
    public function addresses()
    {
        return $this->hasMany(Address::class);
    }

    // اخر عنوان للعميل
    public function latestAddress()
    {
        return $this->hasOne(Address::class)->latestOfMany();
    }

    // التقييمات
    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    // المفضلة
    public function wishlist()
    {
        return $this->hasMany(Wishlist::class);
    }

    // Define many-to-many relationship between User and Product (wishlist)
    public function wishlistProducts()
    {
        return $this->belongsToMany(Product::class, 'wishlists')->withTimestamps();
    }

    // الكوبونات المستخدمة
    public function usedCoupons()
    {
        return $this->belongsToMany(Coupon::class, 'coupon_usages')
            ->withTimestamps();
    }

    // من قام بحظر المستخدم
    public function blockedBy()
    {
        return $this->belongsTo(User::class, 'blocked_by');
    }

    // تحديد دور المستخدم وتوجيه لصفحاته
    public function hasRole($role): bool
    {
        return $this->role === $role;
    }

    // التحقق من حالة المستخدم
    public function isActive()
    {
        return $this->status === 'active';
    }

    public function isBlocked()
    {
        return $this->status === 'blocked';
    }

    // تحديث آخر ظهور
    public function updateLastLogin()
    {
        $this->last_login_at = now();
        $this->last_login_ip = request()->ip();
        $this->save();
    }

    // first and last name for user
    public function getFullNameAttribute()
    {
        return trim($this->first_name.' '.$this->last_name);
    }

    // Age for user
    public function getAgeAttribute()
    {
        return $this->birth_date
            ? Carbon::parse($this->birth_date)->age
            : null;
    }

    /* Start Client Functions */
    // العملاء فقط
    public function scopeClients($query)
    {
        return $query->where('role', 'client');
    }

    // البحث
    public function scopeSearch($query, $search)
    {
        if (! $search) {
            return $query;
        }

        return $query->where(function ($q) use ($search) {
            $q->where('first_name', 'like', "%{$search}%")
                ->orWhere('last_name', 'like', "%{$search}%")
                ->orWhereRaw("CONCAT(first_name, ' ', last_name) LIKE ?", ["%{$search}%"])
                ->orWhere('email', 'like', "%{$search}%")
                ->orWhere('phone', 'like', "%{$search}%");
        });
    }

    // الحالة
    public function scopeStatus($query, $status)
    {
        if (! $status) {
            return $query;
        }

        return match ($status) {
            'active' => $query->where('status', 'active'),

            'inactive' => $query->where('status', '!=', 'active')
                ->where(function ($q) {
                    $q->whereNull('last_login_at')
                        ->orWhere('last_login_at', '<', now()->subDays(30));
                }),

            'blocked' => $query->where('status', 'blocked'),

            default => $query
        };
    }

    // التاريخ
    public function scopeDateRange($query, $from, $to)
    {
        return $query
            ->when($from, fn ($q) => $q->whereDate('created_at', '>=', $from))
            ->when($to, fn ($q) => $q->whereDate('created_at', '<=', $to));
    }
    /* End Client Functions */

    /* Start Client Stats Functions */
    public static function customerStats()
    {
        return [
            'total' => self::clients()->count(),

            'new_this_month' => self::clients()
                ->whereMonth('created_at', now()->month)
                ->whereYear('created_at', now()->year)
                ->count(),

            'active' => self::clients()
                ->where('status', 'active')
                ->where(
                    fn ($q) => $q->whereNull('last_login_at')
                        ->orWhere('last_login_at', '>=', now()->subDays(30))
                )
                ->count(),

            'inactive' => self::clients()
                ->where('status', '!=', 'blocked')
                ->where(
                    fn ($q) => $q->whereNull('last_login_at')
                        ->orWhere('last_login_at', '<', now()->subDays(30))
                )
                ->count(),

            'blocked' => self::clients()
                ->where('status', 'blocked')
                ->count(),
        ];
    }
    /* End Client Stats Functions */
}
