<?php

namespace App\Services;

use App\Models\Setting;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Str;

use Intervention\Image\ImageManager;
use Intervention\Image\Drivers\Gd\Driver;

class FileUploadService
{

    public static function upload(
        UploadedFile $file,
        string $directory,
        array $allowedExtensions,
        ?string $oldPath = null,
        ?string $type = null
    ): string {

        $extension = strtolower($file->getClientOriginalExtension());

        if (!in_array($extension, $allowedExtensions)) {
            abort(403, 'نوع الملف غير مسموح');
        }

        // حذف القديم
        if ($oldPath) {
            $fullOldPath = $_SERVER['DOCUMENT_ROOT'] . '/' . $oldPath;
            if (file_exists($fullOldPath)) {
                @unlink($fullOldPath);
            }
        }

        // إنشاء مدير الصور
        $manager = new ImageManager(new Driver());

        $image = $manager->read($file);

        // اسم فريد
        $filename = Str::uuid() . '.webp';

        // المسار
        $destination = $_SERVER['DOCUMENT_ROOT'] . '/' . trim($directory, '/');
        if (!file_exists($destination)) {
            mkdir($destination, 0755, true);
        }

        // حفظ WebP فقط
        $image->toWebp(75)->save($destination . '/' . $filename);

        if ($type === 'logo') {

            // إنشاء نسخة مربعة 180x180 للأيقونة
            $icon = clone $image;

            $icon->cover(180, 180); // قص ذكي + resize

            $iconName = Str::uuid() . '_icon.webp';

            $icon->toWebp(80)->save($destination . '/' . $iconName);

            // خزّنها بالـ settings
            Setting::set('store_logo_icon', trim($directory, '/') . '/' . $iconName);
            cache()->forget("setting:store_logo_icon");
        }

        return trim($directory, '/') . '/' . $filename;
    }

    public static function delete(?string $path): void
    {
        if (!$path) return;

        $fullPath = $_SERVER['DOCUMENT_ROOT'] . '/' . $path;
        if (file_exists($fullPath)) {
            @unlink($fullPath);
        }
    }
}
