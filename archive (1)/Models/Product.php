<?php

namespace App\Models;

use App\Services\FileUploadService;
use App\Traits\SanitizesInput;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Product extends Model
{
    use HasFactory, SanitizesInput;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name_ar',
        'name_en',
        'slug',
        'sku',
        'description_ar',
        'description_en',
        'price',
        'sale_price',
        'brand_id',
        'weight',
        'featured',
        'requires_shipping',
        'tax_exempt',
        'new',
        'views',
        'status',
    ];

    protected $sanitize = [
        'name_ar',
        'name_en',
        'sku',
        'description_ar',
        'description_en',
        'price',
        'sale_price',
        'weight',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'price' => 'decimal:2',
        'sale_price' => 'decimal:2',
        'featured' => 'boolean',
        'requires_shipping' => 'boolean',
        'tax_exempt' => 'boolean',
        'new' => 'boolean',
        'views' => 'integer',
    ];

    /**
     * العلاقات
     */

    // العلامة التجارية
    public function brand()
    {
        return $this->belongsTo(Brand::class);
    }

    // الصور
    public function images()
    {
        return $this->hasMany(ProductImage::class);
    }

    // الصورة الرئيسية
    public function primaryImage()
    {
        return $this->hasOne(ProductImage::class)->where('is_primary', true);
    }

    // عناصر الطلبات
    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    // التقييمات
    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    // الكلمات الدلالية
    public function tags()
    {
        return $this->belongsToMany(Tag::class, 'product_tags')->withTimestamps();
    }

    // التصنيفات
    public function categories()
    {
        return $this->belongsToMany(Category::class, 'product_categories')->withTimestamps();
    }

    // الاحجام
    public function sizes()
    {
        return $this->belongsToMany(Size::class, 'product_sizes')->withTimestamps();
    }

    /**
     * الدوال المساعدة
     */

    // إنشاء slug تلقائي
    protected static function boot()
    {
        parent::boot();

        // انشاء رمز للمنتج
        static::created(function ($product) {
            if (! $product->sku) {
                $product->sku = 'PRD-'.str_pad($product->id, 5, '0', STR_PAD_LEFT);
                $product->saveQuietly();
            }
        });

        // حذف صور منتج او اكثر من منتج
        static::deleting(function ($product) {
            foreach ($product->images as $image) {
                FileUploadService::delete($image->path);
            }
        });
    }

    // الحصول على السعر الحالي
    public function getCurrentPriceAttribute()
    {
        return $this->sale_price ?? $this->price;
    }

    // الحصول على الصورة الرئيسية
    public function getPrimaryImageUrlAttribute()
    {
        $primary = $this->primaryImage;

        return $primary
            ? asset($primary->path)
            : asset('img/no-image.png');
    }

    // التحقق من وجود خصم
    public function hasDiscount()
    {
        return $this->sale_price && $this->sale_price < $this->price;
    }

    // الحصول على نسبة الخصم
    public function getDiscountPercentageAttribute()
    {
        if (! $this->hasDiscount()) {
            return 0;
        }

        return round((($this->price - $this->sale_price) / $this->price) * 100);
    }

    // زيادة عدد المشاهدات
    public function incrementViews()
    {
        $this->increment('views');
    }

    // التحقق من الحالة
    public function isActive()
    {
        return $this->status === 'active';
    }

    // عدد المنتجات الكلي
    public static function totalProducts()
    {
        return cache()->remember('products_total_count', 300, function () {
            return self::count();
        });
    }

    // عدد المنتجات النشطة الكلي
    public static function totalActiveProducts()
    {
        return cache()->remember('products_active_count', 300, function () {
            return self::where('status', 'active')->count();
        });
    }

    // نطاقات الاستعلام
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeFeatured($query)
    {
        return $query->where('featured', true);
    }

    public function scopeNew($query)
    {
        return $query->where('new', true);
    }

    public function scopeSearch($query, $term)
    {
        return $query->where(function ($q) use ($term) {
            $q->where('name_ar', 'LIKE', "%{$term}%")
                ->orWhere('name_en', 'LIKE', "%{$term}%")
                ->orWhere('description_ar', 'LIKE', "%{$term}%")
                ->orWhere('sku', 'LIKE', "%{$term}%")
                ->orWhereHas('tags', function ($t) use ($term) {
                    $t->where('name', 'LIKE', "%{$term}%");
                });
        });
    }

    // Filter by Categories
    public function scopeOfCategories($query, $categories)
    {
        return $query->whereHas('categories', function ($q) use ($categories) {
            $q->where(function ($sub) use ($categories) {
                $sub->where('name', 'like', "%{$categories}%");
            });
        });
    }

    // Filter by Brands
    public function scopeOfBrands($query, $brands)
    {
        return $query->whereIn('brand_id', $brands);
    }

    // Filter by Sizes
    public function scopeOfSizes($query, $sizes)
    {
        return $query->whereHas('sizes', function ($q) use ($sizes) {
            $q->where(function ($sub) use ($sizes) {
                $sub->where('name', 'like', "%{$sizes}%");
            });
        });
    }

    // Price Filter
    public function scopePriceBetween($query, $min = null, $max = null)
    {
        if (! is_null($min)) {
            $query->whereRaw('COALESCE(sale_price, price) >= ?', [$min]);
        }

        if (! is_null($max)) {
            $query->whereRaw('COALESCE(sale_price, price) <= ?', [$max]);
        }

        return $query;
    }

    // Rating Filter
    public function scopeMinRating($query, $rating)
    {
        if ($rating === null) {
            return $query;
        }

        if ((int) $rating === 0) {
            return $query->doesntHave('reviews');
        }

        return $query->whereHas('reviews', function ($q) use ($rating) {
            $q->select('product_id')
                ->groupBy('product_id')
                ->havingRaw('AVG(rating) >= ?', [$rating]);
        });
    }
}
