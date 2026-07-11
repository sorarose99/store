<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Product;
use App\Models\Brand;
use App\Models\Color;
use App\Models\ProductImage;
use App\Models\Size;
use App\Services\FileUploadService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Log;

class ProductController extends Controller
{
    public function __construct()
    {
        $this->middleware('check.permission:view_products')->only(['index', 'show']);
        $this->middleware('check.permission:create_products')->only(['create', 'store']);
        $this->middleware('check.permission:edit_products')->only(['edit', 'update']);
        $this->middleware('check.permission:delete_products')->only(['destroy']);
    }

    /**
     * عرض قائمة المنتجات
     */
    public function index(Request $request)
    {
        $query = Product::with(['categories', 'brand', 'primaryImage']);

        // البحث باسم المنتج او sku
        if ($request->filled('search')) {
            $query->search($request->search);
        }

        // الحالة
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        // السعر
        if ($request->filled('min_price')) {
            $query->where('price', '>=', $request->min_price);
        }

        if ($request->filled('max_price')) {
            $query->where('price', '<=', $request->max_price);
        }

        // Sorting
        if ($request->filled('sort')) {
            match ($request->sort) {
                'price_asc' => $query->orderByRaw('COALESCE(sale_price, price) ASC'),
                'price_desc' => $query->orderByRaw('COALESCE(sale_price, price) DESC'),
                default => $query->latest(),
            };
        } else {
            $query->latest();
        }

        // المنتجات المميزة
        if ($request->filled('featured')) {
            $query->where('featured', $request->featured);
        }

        // المنتجات الجديدة
        if ($request->filled('new')) {
            $query->where('new', $request->new);
        }

        // يحتاج شحن
        if ($request->filled('requires_shipping')) {
            $query->where('requires_shipping', $request->requires_shipping);
        }

        // معفى من الضريبة
        if ($request->filled('tax_exempt')) {
            $query->where('tax_exempt', $request->tax_exempt);
        }
        

        $products = $query->paginate(15)->withQueryString();

        $filteredCount = $products->total();

        return view('admin.products.index', compact('products', 'filteredCount'));
    }

    /**
     * عرض نموذج إضافة منتج
     */
    public function create()
    {
        $brands = Brand::withCount('products')->latest()->paginate(15);
        $sizes = Size::latest()->limit(50)->get();
        return view('admin.products.create', compact('brands', 'sizes'));
    }

    /**
     * حفظ منتج جديد
     */
    public function store(Request $request)
    {

        // التحقق من صحة البيانات
        $request->validate([
            // المعلومات الأساسية
            'name_ar' => 'required|string|max:255',
            'name_en' => 'required|string|max:255',
            'sku' => 'nullable|string|unique:products,sku',
            'brand_id' => 'nullable|exists:brands,id',
            'weight' => 'nullable|numeric|min:0',
            'description_ar' => 'nullable|string',
            'description_en' => 'nullable|string',

            // السعر والمخزون
            'price' => 'nullable|numeric|min:0',
            'sale_price' => 'nullable|numeric|min:0',

            // الحالة
            'status' => 'required|in:active,inactive',
            'featured' => 'nullable|boolean',
            'new' => 'nullable|boolean',
            'requires_shipping' => 'nullable|boolean',
            'tax_exempt' => 'nullable|boolean',

            // التصنيفات والكلمات الدلالية والاحجام
            'categories' => 'nullable|string',
            'tags' => 'nullable|string',
            'sizes' => 'nullable|string',

            // الصور
            'product_images' => 'nullable|array',
            'product_images.*' => 'nullable|json',
        ]);

        try {
            DB::beginTransaction();

            // إنشاء slug من الاسم بالانجليزية
            $slug = Str::slug($request->name_en);
            $originalSlug = $slug;
            $counter = 1;

            while (Product::where('slug', $slug)->exists()) {
                $slug = $originalSlug . '-' . $counter;
                $counter++;
            }

            // إنشاء المنتج
            $product = Product::create([
                'name_ar' => $request->name_ar,
                'name_en' => $request->name_en,
                'slug' => $slug,
                'sku' => $request->sku,
                'brand_id' => $request->brand_id,
                'weight' => $request->weight,
                'description_ar' => $request->description_ar,
                'description_en' => $request->description_en,
                'price' => $request->price,
                'sale_price' => $request->sale_price,
                'status' => $request->status,
                'featured' => $request->has('featured'),
                'new' => $request->has('new'),
                'requires_shipping' => $request->has('requires_shipping'),
                'tax_exempt' => $request->has('tax_exempt'),
                'views' => 0,
            ]);

            // ربط التصنيفات
            if ($request->has('categories')) {
                $category_ids = explode(',', $request->categories);
                $category_ids = array_map('intval', $category_ids);

                // إزالة أي قيم = 0
                $category_ids = array_filter($category_ids, fn($id) => $id > 0);

                $product->categories()->sync($category_ids);
            }

            // ربط الكلمات الدلالية
            if ($request->has('tags')) {
                $tag_ids = explode(',', $request->tags);
                $tag_ids = array_map('intval', $tag_ids);

                // إزالة أي قيم = 0
                $tag_ids = array_filter($tag_ids, fn($id) => $id > 0);

                $product->tags()->sync($tag_ids);
            }

            // ربط الأحجام (إذا كانت موجودة)
            if ($request->has('sizes')) {
                $size_ids = explode(',', $request->sizes);
                $size_ids = array_map('intval', $size_ids);
                // إزالة أي قيم = 0
                $size_ids = array_filter($size_ids, fn($id) => $id > 0);
                $product->sizes()->sync($size_ids);
            }

            // معالجة الصور
            if ($request->has('product_images')) {
                $hasPrimary = false;
                $sortOrder = 0;

                foreach ($request->product_images as $imageData) {
                    if (empty($imageData)) continue;

                    $imageInfo = json_decode($imageData, true);
                    if (!$imageInfo || !isset($imageInfo['file_name'])) continue;

                    // البحث عن الصورة المرفوعة فعلياً
                    $uploadedFile = null;
                    if ($request->hasFile('images_upload')) {
                        foreach ($request->file('images_upload') as $file) {
                            if ($file->getClientOriginalName() === $imageInfo['file_name']) {
                                $uploadedFile = $file;
                                break;
                            }
                        }
                    }

                    // إذا لم يتم العثور على الملف نتخطى
                    if (!$uploadedFile) continue;

                    // ✅ هنا التعديل فقط
                    $path = FileUploadService::upload(
                        $uploadedFile,
                        'uploads/product_images',
                        ['jpg', 'jpeg', 'png', 'webp']
                    );

                    // إذا فشل الرفع
                    if (!$path) continue;

                    $isPrimary = isset($imageInfo['is_primary']) && $imageInfo['is_primary'];

                    // التأكد من وجود صورة رئيسية واحدة فقط
                    if ($isPrimary) {
                        if ($hasPrimary) {
                            $isPrimary = false;
                        } else {
                            $hasPrimary = true;
                        }
                    }

                    $colorId = $imageInfo['color_id'] ?? null;
                    if ($colorId === "") $colorId = null;

                    $product->images()->create([
                        'path' => $path,
                        'color_id' => $colorId,
                        'is_primary' => $isPrimary,
                        'sort_order' => $sortOrder,
                    ]);

                    $sortOrder++;
                }

                // إذا لم يتم تحديد صورة رئيسية
                if (!$hasPrimary && $product->images()->exists()) {
                    $firstImage = $product->images()->first();
                    $firstImage->update(['is_primary' => true]);
                }
            }

            DB::commit();

            return redirect()->route('admin.products.index')
                ->with('success', 'تم إضافة المنتج بنجاح');
        } catch (\Exception $e) {
            DB::rollBack();

            return redirect()->back()
                ->withInput()
                ->with('error', 'حدث خطأ أثناء إضافة المنتج: ' . $e->getMessage());
        }
    }

    /**
     * عرض تفاصيل المنتج
     */
    public function show($id) {}

    /**
     * عرض نموذج تعديل منتج
     */
    public function edit($id)
    {
        $product = Product::with(['images', 'categories', 'tags', 'sizes'])->findOrFail($id);
        $brands = Brand::latest()->get();
        $colors = Color::latest()->get();

        return view('admin.products.edit', compact('product', 'brands', 'colors'));
    }

    /**
     * تحديث المنتج
     */
    public function update(Request $request, $id)
    {
        $product = Product::findOrFail($id);

        // التحقق من صحة البيانات
        $request->validate([
            // المعلومات الأساسية
            'name_ar' => 'required|string|max:255',
            'name_en' => 'required|string|max:255',
            'sku' => 'nullable|string|unique:products,sku,' . $id,
            'brand_id' => 'nullable|exists:brands,id',
            'weight' => 'nullable|numeric|min:0',
            'description_ar' => 'nullable|string',
            'description_en' => 'nullable|string',

            // السعر والمخزون
            'price' => 'nullable|numeric|min:0',
            'sale_price' => 'nullable|numeric|min:0',

            // الحالة
            'status' => 'required|in:active,inactive',
            'featured' => 'nullable|boolean',
            'new' => 'nullable|boolean',
            'requires_shipping' => 'nullable|boolean',
            'tax_exempt' => 'nullable|boolean',

            // التصنيفات والكلمات الدلالية والأحجام
            'categories' => 'nullable',
            'tags' => 'nullable',
            'sizes' => 'nullable',

            // الصور
            'deleted_images' => 'nullable|string',
            'product_images' => 'nullable|array',
            'product_images.*' => 'nullable|string',

        ]);

        try {
            DB::beginTransaction();

            // تحديث slug إذا تغير الاسم
            $slug = Str::slug($request->name_en);
            if ($slug !== $product->slug) {
                $originalSlug = $slug;
                $counter = 1;

                while (Product::where('slug', $slug)->where('id', '!=', $id)->exists()) {
                    $slug = $originalSlug . '-' . $counter;
                    $counter++;
                }
            }

            // تحديث المنتج
            $product->update([
                'name_ar' => $request->name_ar,
                'name_en' => $request->name_en,
                'slug' => $slug,
                'sku' => $request->sku,
                'brand_id' => $request->brand_id,
                'weight' => $request->weight,
                'description_ar' => $request->description_ar,
                'description_en' => $request->description_en,
                'price' => $request->price,
                'sale_price' => $request->sale_price,
                'status' => $request->status,
                'featured' => $request->has('featured'),
                'new' => $request->has('new'),
                'requires_shipping' => $request->has('requires_shipping'),
                'tax_exempt' => $request->has('tax_exempt'),
            ]);

            // حذف الصور المحددة
            if ($request->deleted_images) {
                $deletedImages = json_decode($request->deleted_images, true);

                if (is_array($deletedImages)) {
                    foreach ($deletedImages as $imageId) {
                        $image = ProductImage::find($imageId);

                        if ($image) {
                            FileUploadService::delete($image->path);
                            $image->delete();
                        }
                    }
                }
            }

            // تحديث الصور الموجودة
            if ($request->has('existing_images')) {
                // تصفير كل الصور
                ProductImage::where('product_id', $product->id)->update(['is_primary' => 0]);
                foreach ($request->existing_images as $imageId => $imageDataJson) {
                    $image = ProductImage::find($imageId);
                    if ($image) {
                        $imageData = json_decode($imageDataJson, true);
                        $image->color_id = $imageData['color_id'] ?? null;
                        $image->is_primary = !empty($imageData['is_primary']) ? 1 : 0;
                        $image->save();
                    }
                }
            }

            // معالجة الصور الجديدة
            if ($request->has('product_images')) {
                $hasPrimary = $product->images()->where('is_primary', true)->exists();
                $sortOrder = $product->images()->count();

                foreach ($request->product_images as $imageData) {
                    if (empty($imageData)) continue;

                    $imageInfo = json_decode($imageData, true);
                    if (!$imageInfo || !isset($imageInfo['file_name'])) continue;

                    // البحث عن الصورة المرفوعة فعلياً
                    $uploadedFile = null;
                    if ($request->hasFile('images_upload')) {
                        foreach ($request->file('images_upload') as $file) {
                            if ($file->getClientOriginalName() === $imageInfo['file_name']) {
                                $uploadedFile = $file;
                                break;
                            }
                        }
                    }

                    // إذا لم يتم العثور على الملف نتخطى
                    if (!$uploadedFile) continue;

                    // رفع الصورة
                    $path = FileUploadService::upload(
                        $uploadedFile,
                        'uploads/product_images',
                        ['jpg', 'jpeg', 'png', 'webp']
                    );

                    // إذا فشل الرفع
                    if (!$path) continue;

                    $isPrimary = isset($imageInfo['is_primary']) && $imageInfo['is_primary'];

                    // التأكد من وجود صورة رئيسية واحدة فقط
                    if ($isPrimary) {
                        if ($hasPrimary) {
                            $isPrimary = false;
                        } else {
                            $hasPrimary = true;
                        }
                    }

                    $colorId = $imageInfo['color_id'] ?? null;
                    if ($colorId === "") $colorId = null;

                    $product->images()->create([
                        'path' => $path,
                        'color_id' => $colorId,
                        'is_primary' => $isPrimary,
                        'sort_order' => $sortOrder,
                    ]);

                    $sortOrder++;
                }

                // إذا لم يتم تحديد صورة رئيسية جديدة ولا توجد صورة رئيسية
                if (!$hasPrimary && !$product->images()->where('is_primary', true)->exists() && $product->images()->exists()) {
                    $firstImage = $product->images()->first();
                    $firstImage->update(['is_primary' => true]);
                }
            }

            // ربط التصنيفات
            if ($request->has('categories')) {
                $category_ids = explode(',', $request->categories);
                $category_ids = array_map('intval', $category_ids);
                $category_ids = array_filter($category_ids, fn($id) => $id > 0);
                $product->categories()->sync($category_ids);
            } else {
                $product->categories()->sync([]);
            }

            // ربط الكلمات الدلالية
            if ($request->has('tags')) {
                $tag_ids = explode(',', $request->tags);
                $tag_ids = array_map('intval', $tag_ids);
                $tag_ids = array_filter($tag_ids, fn($id) => $id > 0);
                $product->tags()->sync($tag_ids);
            } else {
                $product->tags()->sync([]);
            }

            // ربط الأحجام
            if ($request->has('sizes')) {
                $size_ids = explode(',', $request->sizes);
                $size_ids = array_map('intval', $size_ids);
                $size_ids = array_filter($size_ids, fn($id) => $id > 0);
                $product->sizes()->sync($size_ids);
            } else {
                $product->sizes()->sync([]);
            }

            DB::commit();

            return redirect()->back()->with('success', 'تم تحديث المنتج بنجاح');
        } catch (\Exception $e) {
            DB::rollBack();

            Log::error('Error updating product: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);

            return redirect()->back()
                ->withInput()
                ->with('error', 'حدث خطأ أثناء تحديث المنتج: ' . $e->getMessage());
        }
    }

    /**
     * حذف المنتج
     */
    public function destroy($id) {}

    /**
     * حذف اكثر من منتج
     */
    public function bulkDelete(Request $request)
    {
        $products = Product::whereIn('id', $request->ids)->get();

        foreach ($products as $product) {
            // حذف الصور من التخزين يتم تلقائيا عبر المودل
            $product->delete();
        }

        return response()->json([
            'success' => true,
            'message' => 'تم حذف المنتجات المحددة بنجاح'
        ]);
    }
}
