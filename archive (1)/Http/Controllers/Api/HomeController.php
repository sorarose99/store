<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use App\Models\Category;
use App\Models\Product;

class HomeController extends Controller
{
    /**
     * عرض الصفحة الرئيسية
     */
    public function index()
    {
        $categories = Category::whereNull('parent_id')->where('show_in_home', true)->where('status', 'active')
            ->latest()
            ->limit(6)
            ->get();

        $new_products = Product::with([
            'images' => function ($q) {
                $q->select('id', 'product_id', 'path', 'is_primary')
                    ->orderBy('is_primary', 'desc');
            },
        ])
            ->select('id', 'name_ar', 'name_en', 'price', 'sale_price', 'new', 'slug')->withCount('reviews')
            ->withAvg('reviews', 'rating')
            ->where('status', 'active')
            ->where('new', true)
            ->latest()
            ->limit(8)
            ->get();

        $featured_products = Product::with([
            'images' => function ($q) {
                $q->select('id', 'product_id', 'path', 'is_primary')
                    ->orderBy('is_primary', 'desc');
            },
        ])
            ->select('id', 'name_ar', 'name_en', 'price', 'sale_price', 'featured', 'slug')->withCount('reviews')
            ->withAvg('reviews', 'rating')
            ->where('status', 'active')
            ->where('featured', true)
            ->latest()
            ->limit(8)
            ->get();

        $banners = Banner::where('position', 'home')
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
            ->get();

        return response()->json([
            'success' => true,
            'categories' => $categories,
            'new_products' => $new_products,
            'featured_products' => $featured_products,
            'banners' => $banners,
            'banner' => $banners->first(),
        ]);

    }
}
