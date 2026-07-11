<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Artisan;

class CacheController extends Controller
{
    public function clear()
    {
        // مسح كل الكاشات
        Artisan::call('cache:clear');
        Artisan::call('config:clear');
        Artisan::call('route:clear');
        Artisan::call('view:clear');

        return response()->json([
            'success' => true,
            'message' => '✅ All caches cleared successfully!'
        ]);
    }
}
