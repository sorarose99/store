<?php

namespace App\Models;

use App\Traits\SanitizesInput;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Category extends Model
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
        'parent_id',
        'show_in_home',
        'status',
    ];

    protected $sanitize = [
        'name',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'show_in_home' => 'boolean',
    ];

    /**
     * العلاقات
     */

    // التصنيف الأب
    public function parent()
    {
        return $this->belongsTo(Category::class, 'parent_id');
    }

    // التصنيفات الفرعية
    public function children()
    {
        return $this->hasMany(Category::class, 'parent_id');
    }

    // المنتجات
    public function products()
    {
        return $this->belongsToMany(Product::class, 'product_categories');
    }

    /**
     * الدوال المساعدة
     */

    // إنشاء slug تلقائي
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($category) {
            $category->slug = self::generateUniqueSlug(
                $category->name,
                $category->parent_id
            );
        });

        static::updating(function ($category) {
            $category->slug = self::generateUniqueSlug(
                $category->name,
                $category->parent_id,
                $category->id
            );
        });
    }

    private static function generateUniqueSlug($name, $parentId = null, $ignoreId = null)
    {
        // جلب اسم الأب إذا موجود
        $parentName = null;

        if ($parentId) {
            $parent = self::find($parentId);
            $parentName = $parent?->name;
        }

        // توليد slug
        if ($parentName) {
            $slug = Str::slug($parentName.'-'.$name);
        } else {
            $slug = Str::slug($name);
        }

        $originalSlug = $slug;
        $counter = 1;

        // التأكد من التفرد
        while (
            self::where('slug', $slug)
                ->when($ignoreId, fn ($q) => $q->where('id', '!=', $ignoreId))
                ->exists()
        ) {
            $slug = $originalSlug.'-'.$counter;
            $counter++;
        }

        return $slug;
    }
}
