<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Color;
use App\Models\Product;
use App\Models\Size;
use App\Models\Tag;
use App\Services\FileUploadService;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Maatwebsite\Excel\Facades\Excel;

class ProductExcelController extends Controller
{
    public function __construct()
    {
        $this->middleware('check.permission:view_products')->only(['index', 'show']);
        $this->middleware('check.permission:create_products')->only(['create', 'store']);
        $this->middleware('check.permission:edit_products')->only(['edit', 'update']);
        $this->middleware('check.permission:delete_products')->only(['destroy']);
    }

    // =========================
    // Import Excel
    // =========================
    public function importFromExcel(Request $request)
    {
        $request->validate([
            'file' => 'required|file|mimes:xlsx,xls,csv', // تم إضافة csv لدعم كافة الصيغ المرفوعة
        ]);

        set_time_limit(0);

        $rows = Excel::toArray([], $request->file('file'))[0];
        unset($rows[0]);

        $chunks = array_chunk($rows, 3);
        $importCount = 0;

        foreach ($chunks as $chunkIndex => $chunk) {

            foreach ($chunk as $row) {

                try {

                    if (empty($row[1])) {
                        continue;
                    }

                    DB::beginTransaction();

                    $product = $this->createProductFromRow($row);

                    DB::commit();
                    $importCount++;
                } catch (\Exception $e) {

                    DB::rollBack();

                    Log::error('Import Error: '.$e->getMessage(), [
                        'row' => $row ?? null,
                    ]);

                    continue;
                }
            }

            usleep(500000); // راحة للسيرفر
        }

        if ($request->ajax() || $request->wantsJson()) {
            return response()->json([
                'success' => true,
                'message' => "تم استيراد {$importCount} منتج بنجاح",
                'imported_count' => $importCount,
            ]);
        }
    }

    // =========================
    // Create Product (LIKE STORE)
    // =========================
    private function createProductFromRow($row)
    {
        // لمنع تكرار اضافة نفس المنتج
        $existingProduct = Product::where('name_en', $row[1])->where('description_en', $row[3])->first();

        if ($existingProduct) {
            return $existingProduct; // تجاهل الإضافة
        }

        //  slug unique
        $slug = Str::slug($row[1]);
        $originalSlug = $slug;
        $counter = 1;

        while (Product::where('slug', $slug)->exists()) {
            $slug = $originalSlug.'-'.$counter++;
        }

        // =========================
        // CREATE PRODUCT
        // =========================
        $product = Product::create([
            'name_ar' => $row[0],
            'name_en' => $row[1],
            'description_ar' => $row[2] ?? null,
            'description_en' => $row[3] ?? null,
            'price' => $row[4] ?? 0,
            'weight' => $row[5] ?? 0,
            'slug' => $slug,
            'requires_shipping' => $row[10] == 'نعم' ? 1 : 0,
        ]);

        // =========================
        // 1- Categories
        // =========================
        $categoryNames = $this->splitAndClean($row[8]);
        $categoryIds = [];

        if (! empty($categoryNames)) {
            // التصنيف الأساسي
            $parentName = trim($categoryNames[0]);

            $parentCategory = Category::firstOrCreate(
                [
                    'name' => $parentName,
                    'parent_id' => null,
                ],
                [
                    'show_in_home' => 1,
                ]
            );

            // التصنيفات الفرعية
            if (count($categoryNames) > 1) {
                foreach (array_slice($categoryNames, 1) as $childName) {
                    $childName = trim($childName);

                    if (! $childName) {
                        continue;
                    }

                    $childCategory = Category::firstOrCreate(
                        [
                            'name' => $childName,
                            'parent_id' => $parentCategory->id,
                        ],
                        [
                            'show_in_home' => 0,
                        ]
                    );

                    // ربط المنتج فقط بالتصنيف الفرعي
                    $categoryIds[] = $childCategory->id;
                }
            }
        }

        $product->categories()->sync($categoryIds);

        // =========================
        // 2- Tags
        // =========================
        $tagNames = $this->splitAndClean($row[9]);
        $tagIds = [];

        foreach ($tagNames as $name) {
            if (! $name) {
                continue;
            }

            $tag = Tag::firstOrCreate([
                'name' => $name,
            ]);

            $tagIds[] = $tag->id;
        }

        $product->tags()->sync($tagIds);

        // =========================
        // 3- Sizes
        // =========================
        $sizeNames = $this->splitAndClean($row[7]);
        $sizeIds = [];

        foreach ($sizeNames as $name) {
            if (! $name) {
                continue;
            }

            $size = Size::firstOrCreate([
                'name' => $name,
            ]);

            $sizeIds[] = $size->id;
        }

        $product->sizes()->sync($sizeIds);

        // =========================
        // 4- Colors
        // =========================
        $colorIds = [];

        if (! empty($row[6])) {
            $colorNames = $this->splitAndClean($row[6]);

            foreach ($colorNames as $colorName) {
                if (! $colorName) {
                    continue;
                }

                $color = Color::firstOrCreate(
                    ['name' => $colorName],
                );

                $colorIds[] = $color->id;
            }
        }

        // =========================
        // Images from URLs Direct
        // =========================
        if (! empty($row[11])) {
            $imageUrls = $this->splitAndClean($row[11]);
            if (! empty($imageUrls)) {
                $this->attachImagesFromUrls($product, $imageUrls, $colorIds);
            }
        }

        return $product;
    }

    // =========================
    // Attach Images From Direct URLs
    // =========================
    private function attachImagesFromUrls($product, array $urls, $colorIds = [])
    {
        $sortOrder = 0;

        foreach ($urls as $url) {
            try {
                // التحقق من صحة الرابط
                if (!filter_var($url, FILTER_VALIDATE_URL)) {
                    continue;
                }

                $response = Http::timeout(15)
                    ->retry(2, 200)
                    ->get($url);

                if (! $response || ! $response->successful() || empty($response->body())) {
                    continue;
                }

                // استخراج اسم الملف الأصلي من الرابط لإعطائه للملف المؤقت
                $filename = basename(parse_url($url, PHP_URL_PATH));
                if (empty($filename) || !str_contains($filename, '.')) {
                    $filename = 'image_' . uniqid() . '.jpg';
                }

                $tempPath = storage_path('app/temp_' . uniqid() . '_' . $filename);
                $path = null;

                file_put_contents($tempPath, $response->body());

                $uploadedFile = new UploadedFile(
                    $tempPath,
                    $filename,
                    null,
                    null,
                    true
                );

                $path = FileUploadService::upload(
                    $uploadedFile,
                    'uploads/product_images',
                    ['jpg', 'jpeg', 'png', 'webp']
                );

                if (file_exists($tempPath)) {
                    unlink($tempPath);
                }

                if (! $path) {
                    continue;
                }

                $isPrimary = ($sortOrder === 0);

                $product->images()->create([
                    'color_id' => $colorIds[$sortOrder] ?? null,
                    'path' => $path,
                    'is_primary' => $isPrimary,
                    'sort_order' => $sortOrder++,
                ]);

            } catch (\Exception $e) {
                Log::warning('Image URL download error: '.$e->getMessage());
                if (isset($tempPath) && file_exists($tempPath)) {
                    unlink($tempPath);
                }
                continue;
            }
        }
    }

    /**
     * تقسيم النص على الفواصل (عربية أو إنجليزية) وتنظيفه بالكامل
     */
    private function splitAndClean($string)
    {
        if (empty($string)) {
            return [];
        }

        $string = strval($string);

        // 1. استبدال الفاصلة العربية بإنجليزية
        $string = str_replace('،', ',', $string);

        // 2. استبدال السطور الجديدة و <br> بفواصل
        $string = preg_replace('/\n+|<br\s*\/?>/i', ',', $string);

        // 3. إزالة المسافات حول الفواصل
        $string = preg_replace('/\s*,\s*/', ',', $string);

        // 4. إزالة الفواصل المتكررة
        $string = preg_replace('/,+/', ',', $string);

        // 5. إزالة الفواصل من البداية والنهاية
        $string = trim($string, ',');

        // 6. تقسيم على الفاصلة الإنجليزية
        $items = explode(',', $string);

        // 7. تنظيف كل عنصر
        $items = array_map('trim', $items);

        // 8. إزالة العناصر الفارغة والتكرار
        $items = array_filter($items, function ($item) {
            return ! empty($item);
        });

        $items = array_unique($items);

        // 9. إعادة ترتيب المفاتيح
        return array_values($items);
    }
}