<?php

use App\Http\Controllers\Api\FirebaseController;
use App\Http\Controllers\CacheController;
use Illuminate\Support\Facades\Route;

//Change Between AR-EN Languages
Route::get('lang/{locale}', function ($locale) {
    if (! in_array($locale, ['ar', 'en'])) {
        abort(400);
    }

    return redirect()->back()->withCookie(cookie('locale', $locale, 60 * 24 * 30)); // 30 يوم
})->name('lang.switch');


require __DIR__.'/auth.php';

require __DIR__.'/user_interface.php';
require __DIR__.'/admin_interface.php';


//send request from app into laravel
Route::middleware('auth')->group(function () {
    Route::post('/save-fcm-token', [FirebaseController::class, 'saveFcmToken']);
});

Route::get('/clear-cache', [CacheController::class, 'clear'])->name('clear.cache');
