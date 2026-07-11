<?php

namespace App\Models;

use App\Traits\SanitizesInput;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Brand extends Model
{
    use HasFactory, SanitizesInput;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'slug',
        'description',
        'logo',
        'website',
        'status',
    ];

    protected $sanitize = [
        'name',
        'description',
        'website'
    ];

    /**
     * العلاقات
     */

    // المنتجات
    public function products()
    {
        return $this->hasMany(Product::class);
    }

    /**
     * الدوال المساعدة
     */

    // إنشاء slug تلقائي
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($brand) {
            $brand->slug = Str::slug($brand->name);
        });

        static::updating(function ($brand) {
            $brand->slug = Str::slug($brand->name);
        });
    }

}