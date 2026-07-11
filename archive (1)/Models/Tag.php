<?php

namespace App\Models;

use App\Traits\SanitizesInput;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Tag extends Model
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
        'count',
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
        'count' => 'integer',
    ];

    /**
     * العلاقات
     */

    // المنتجات
    public function products()
    {
        return $this->belongsToMany(Product::class, 'product_tags')
            ->withTimestamps();
    }

    /**
     * الدوال المساعدة
     */

    // إنشاء slug تلقائي مع معالجة التكرار
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($tag) {
            $slug = Str::slug($tag->name);
            $originalSlug = $slug;
            $counter = 1;

            // حلقة تكرار تضمن أن يكون الـ slug فريداً دائماً في جدول الـ tags
            while (static::where('slug', $slug)->exists()) {
                $slug = $originalSlug.'-'.$counter++;
            }

            $tag->slug = $slug;
        });

        static::updating(function ($tag) {
            $slug = Str::slug($tag->name);
            $originalSlug = $slug;
            $counter = 1;

            // حلقة تكرار تضمن أن يكون الـ slug فريداً مع استثناء السجل الحالي أثناء التحديث
            while (static::where('slug', $slug)->where('id', '!=', $tag->id)->exists()) {
                $slug = $originalSlug.'-'.$counter++;
            }

            $tag->slug = $slug;
        });

        // تحديث عدد الاستخدامات عند الحذف
        static::deleting(function ($tag) {
            $tag->products()->detach();
        });
    }

    // تحديث عدد الاستخدامات
    public function updateCount()
    {
        $this->count = $this->products()->count();
        $this->saveQuietly();
    }

    // الحصول على الكلمات الدلالية الأكثر استخداماً
    public static function getPopularTags($limit = 10)
    {
        return self::where('status', 'active')
            ->orderBy('count', 'desc')
            ->limit($limit)
            ->get();
    }

    // البحث عن الكلمات الدلالية المشابهة
    public static function searchSimilar($term, $limit = 5)
    {
        return self::where('status', 'active')
            ->where('name', 'LIKE', "%{$term}%")
            ->orderBy('count', 'desc')
            ->limit($limit)
            ->get();
    }

    // إنشاء كلمات دلالية من نص
    public static function createFromText($text, $userId = null)
    {
        // استخراج الكلمات المفتاحية من النص
        $words = str_word_count($text, 1, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-');
        $words = array_unique($words);
        $words = array_slice($words, 0, 10); // حد أقصى 10 كلمات

        $tags = [];

        foreach ($words as $word) {
            if (strlen($word) > 2) { // تجاهل الكلمات القصيرة
                $tag = self::firstOrCreate(
                    ['name' => $word],
                    ['status' => 'active']
                );
                $tags[] = $tag->id;
            }
        }

        return $tags;
    }

    // دمج كلمات دلالية
    public function mergeInto($targetTagId)
    {
        $targetTag = self::findOrFail($targetTagId);

        // نقل جميع المنتجات إلى الكلمة المستهدفة
        foreach ($this->products as $product) {
            $product->tags()->syncWithoutDetaching([$targetTagId]);
        }

        // حذف الكلمة الحالية
        $this->delete();

        // تحديث عدد الاستخدامات
        $targetTag->updateCount();
    }

    // نطاقات الاستعلام
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopePopular($query)
    {
        return $query->orderBy('count', 'desc');
    }

    public function scopeRecent($query)
    {
        return $query->orderBy('created_at', 'desc');
    }

    public function scopeByName($query, $name)
    {
        return $query->where('name', 'LIKE', "%{$name}%");
    }

    public function scopeWithProductCount($query)
    {
        return $query->withCount('products');
    }
}
