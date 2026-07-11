<?php

namespace App\Http\Controllers;

use App\Models\Banner;
use App\Models\Brand;
use App\Models\Category;
use App\Models\PaymentGateway;
use App\Models\Product;
use App\Models\Review;
use App\Models\Size;
use Illuminate\Http\Request;

class ShopController extends Controller
{
    /**
     * عرض صفحة المتجر (جميع المنتجات)
     */
    public function index(Request $request)
    {
        $banner = Banner::where('position', 'products')
            ->where('status', 'active')
            ->where(function ($q) {
                $q->whereNull('start_date')
                    ->orWhereDate('start_date', '<=', now());
            })
            ->where(function ($q) {
                $q->whereNull('end_date')
                    ->orWhereDate('end_date', '>=', now());
            })
            ->latest()
            ->first();

        $brands = Brand::where('status', 'active')
            ->withCount(['products as products_count' => fn ($q) => $q->where('status', 'active')])
            ->latest()
            ->limit(6)
            ->get();

        $products = Product::with('primaryImage:id,product_id,path')
            ->active()
            ->select('id', 'name_ar', 'name_en', 'slug', 'price', 'sale_price', 'new', 'featured')->withCount('reviews')
            ->withAvg('reviews', 'rating');

        // Search
        if ($request->filled('search')) {
            $products->search($request->search);
        }

        // Categories
        if ($request->filled('category_name')) {
            $products->ofCategories($request->category_name);
        }

        // Brands
        if ($request->filled('brands')) {
            $products->ofBrands($request->brands);
        }

        // Price
        if ($request->filled('min_price') || $request->filled('max_price')) {
            $products->priceBetween($request->min_price, $request->max_price);
        }

        // Rating
        if ($request->filled('rating')) {
            $products->minRating($request->rating);
        }

        // Sizes
        if ($request->filled('size_name')) {
            $products->ofSizes($request->size_name);
        }

        // Sorting
        if ($request->filled('sort')) {
            match ($request->sort) {
                'price_asc' => $products->orderByRaw('COALESCE(sale_price, price) ASC'),
                'price_desc' => $products->orderByRaw('COALESCE(sale_price, price) DESC'),
                default => $products->latest(),
            };
        } else {
            $products->latest();
        }

        $products = $products->paginate(15)->withQueryString();

        return view('shop.index', compact('brands', 'products', 'banner'));

    }

    /**
     * عرض صفحة جميع التصنيفات
     */
    public function categories(Request $request)
    {
        $categories = Category::select('id', 'name', 'slug')
            ->whereNull('parent_id')
            ->withCount('children')
            ->where('status', 'active')
            ->orderBy('name');

        // Search
        if ($request->filled('search')) {
            $categories->where('name', 'like', '%'.$request->search.'%');
        }
        $categories = $categories->paginate(15)->withQueryString();

        $banner = Banner::where('position', 'categories')
            ->where('status', 'active')
            ->where(function ($q) {
                $q->whereNull('start_date')
                    ->orWhereDate('start_date', '<=', now());
            })
            ->where(function ($q) {
                $q->whereNull('end_date')
                    ->orWhereDate('end_date', '>=', now());
            })
            ->latest()
            ->first();

        return view('categories.index', compact('categories', 'banner'));
    }

    /**
     * عرض تصنيفات فرعية لتصنيف اساسي
     */
    public function category(Request $request, $slug)
    {
        $category = Category::where('slug', $slug)->firstOrFail();

        // بناء الاستعلام الأساسي للتصنيفات الفرعية
        $subCategoriesQuery = Category::where('parent_id', $category->id)
            ->where('status', 'active')
            ->withCount('products');

        // تطبيق البحث إذا كان موجوداً
        if ($request->filled('search')) {
            $subCategoriesQuery->where('name', 'like', '%'.$request->search.'%');
        }

        // جلب النتائج مرتبة
        $sub_categories = $subCategoriesQuery->latest()->get();

        // جلب البانر
        $banner = Banner::where('position', 'categories')
            ->where('status', 'active')
            ->where(function ($q) {
                $q->whereNull('start_date')
                    ->orWhereDate('start_date', '<=', now());
            })
            ->where(function ($q) {
                $q->whereNull('end_date')
                    ->orWhereDate('end_date', '>=', now());
            })
            ->latest()
            ->first();

        return view('shop.category', compact('category', 'sub_categories', 'banner'));
    }

    /**
     * عرض منتجات تصنيف فرعي
     */
    public function categoryProducts(Request $request, $main_category_slug, $sub_category_slug)
    {
        // جلب التصنيف الفرعي باستخدام main_category_slug
        $mainCategory = Category::where('slug', $main_category_slug)
            ->where('status', 'active')
            ->whereNull('parent_id') // التأكد من أنه تصنيف اساسي
            ->firstOrFail();

        // جلب التصنيف الفرعي باستخدام sub_category_slug
        $subCategory = Category::where('slug', $sub_category_slug)
            ->where('status', 'active')
            ->whereNotNull('parent_id') // التأكد من أنه تصنيف فرعي
            ->firstOrFail();

        // جلب البانر الخاص بالمنتجات
        $banner = Banner::where('position', 'products')
            ->where('status', 'active')
            ->where(function ($q) {
                $q->whereNull('start_date')
                    ->orWhereDate('start_date', '<=', now());
            })
            ->where(function ($q) {
                $q->whereNull('end_date')
                    ->orWhereDate('end_date', '>=', now());
            })
            ->latest()
            ->first();

        // جلب المنتجات الخاصة بالتصنيف الفرعي عبر العلاقة many-to-many
        $products = Product::with('primaryImage:id,product_id,path')
            ->whereHas('categories', function ($query) use ($subCategory) {
                $query->where('category_id', $subCategory->id);
            })
            ->active()
            ->select('id', 'name_ar', 'name_en', 'slug', 'price', 'sale_price', 'new', 'featured')
            ->withAvg('reviews', 'rating')
            ->latest()
            ->paginate(15)
            ->withQueryString();

        return view('shop.category-products', compact('mainCategory', 'subCategory', 'products', 'banner'));
    }

    /**
     * عرض تفاصيل منتج معين
     */
    public function product($slug)
    {
        $product = Product::with([
            'reviews' => function ($q) {
                $q->with('user:id,first_name,last_name,avatar')
                    ->latest()
                    ->take(5);
            },
        ])
            ->select('id', 'name_ar', 'name_en', 'slug', 'sku', 'description_ar', 'description_en', 'price', 'sale_price', 'new', 'featured', 'requires_shipping')
            ->withCount('reviews')
            ->withAvg('reviews', 'rating')
            ->where('slug', $slug)
            ->where('status', 'active')
            ->firstOrFail();

        // نحدد التصنيف الرئيسي
        $primaryCategoryId = $product->categories->first()?->id;
        // منتجات مشابهة
        $relatedProducts = collect();

        if ($primaryCategoryId) {
            $relatedProducts = Product::with('primaryImage:id,product_id,path')
                ->whereHas('categories', function ($q) use ($primaryCategoryId) {
                    $q->where('categories.id', $primaryCategoryId);
                })
                ->where('id', '!=', $product->id)
                ->select('id', 'name_ar', 'name_en', 'slug', 'price', 'sale_price', 'new', 'featured')
                ->limit(4)
                ->get();
        }

        // إذا ما وجد منتجات مشابهة
        if ($relatedProducts->isEmpty()) {
            $relatedProducts = Product::with('primaryImage:id,product_id,path')
                ->where('id', '!=', $product->id)
                ->select('id', 'name_ar', 'name_en', 'slug', 'price', 'sale_price', 'new', 'featured')
                ->inRandomOrder()
                ->limit(4)
                ->get();
        }

        $tabbyGateway = PaymentGateway::where('name', 'tabby')->where('is_active', 1)->select('credentials')->first();

        return view('shop.product', compact('product', 'relatedProducts', 'tabbyGateway'));
    }

    /**
     * عرض تقييمات منتج معين
     */
    public function reviews($slug)
    {
        $product = Product::where('slug', $slug)->firstOrFail();

        $reviews = Review::with('user:id,first_name,last_name,avatar')
            ->where('product_id', $product->id)
            ->latest()
            ->paginate(15);

        return view('shop.reviews', compact('product', 'reviews'));
    }
}
