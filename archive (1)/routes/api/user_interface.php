<?php

use App\Http\Controllers\Api\AccountController;
use App\Http\Controllers\Api\AddressController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\HomeController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\ShopController;
use App\Http\Controllers\Api\WishlistController;
use App\Http\Controllers\Api\PayTabsController;
use App\Http\Controllers\SmsController;
use App\Http\Controllers\TabbyController;
use App\Http\Controllers\TamaraController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

// الصفحة الرئيسية
Route::get('/', [HomeController::class, 'index']);

// صفحات المتجر
Route::prefix('shop')->group(function () {
    Route::get('/', [ShopController::class, 'index']);
    Route::get('/category/{slug}', [ShopController::class, 'category']);
    Route::get('/category/{main_category_slug}/{sub_category_slug}/products', [ShopController::class, 'categoryProducts']);

    Route::get('/product/{slug}', [ShopController::class, 'product']);
    Route::get('/product/{slug}/reviews', [ShopController::class, 'reviews']);
});

Route::get('categories-with-subcategories', [ShopController::class, 'categoriesWithSubcategories']);


// صفحات التصنيفات
Route::prefix('categories')->name('api-categories.')->group(function () {
    Route::get('/', [ShopController::class, 'categories']);
});

// صفحات السلة والطلب
// routes/api.php

// صفحات السلة والطلب
Route::middleware(['auth:sanctum'])->prefix('cart')->group(function () {
    Route::get('/', [CartController::class, 'index']);
    Route::post('/add', [CartController::class, 'add']);
    Route::put('/update/{productId}', [CartController::class, 'update']);
    Route::delete('/remove/{productId}', [CartController::class, 'remove']);
    Route::delete('/clear', [CartController::class, 'clear']);

    Route::post('/coupon', [CartController::class, 'applyCoupon']);
    Route::delete('/coupon', [CartController::class, 'removeCoupon']);

    Route::post('/update-shipping-zone', [CartController::class, 'updateShippingZone']);
    Route::get('/checkout', [CartController::class, 'checkout'])->middleware('auth');
    Route::get('/count', [CartController::class, 'getCartCount']);
    Route::put('/breakdown/{productId}', [CartController::class, 'updateBreakdown']);
});

// delete client account
Route::prefix('account')->middleware('auth:sanctum')->group(function () {
    Route::delete('/destroy', [AccountController::class, 'destroy']);
});

// صفحات المستخدم (محمية بالمصادقة)
Route::prefix('account')->name('api-account.')->middleware(['auth:sanctum', 'verified'])->group(function () {
    // لوحة التحكم
    Route::get('/', [AccountController::class, 'myAccount'])->name('my_account');

    // الملف الشخصي
    Route::get('/profile', [AccountController::class, 'profile'])->name('profile');
    Route::put('/profile', [AccountController::class, 'updateProfile'])->name('profile.update');

    // تغيير كلمة المرور
    Route::get('/change-password', [AccountController::class, 'showChangePasswordForm'])->name('change-password');
    Route::put('/change-password', [AccountController::class, 'changePassword'])->name('password.change');

});

// صفحات عناوين الشحن للمستخدم (محمية بالمصادقة)
Route::prefix('addresses')->middleware(['auth:sanctum', 'verified'])->group(function () {
    Route::get('/', [AddressController::class, 'index']);
    Route::post('/store', [AddressController::class, 'store']);
    Route::get('/{id}/edit', [AddressController::class, 'edit']);
    Route::put('/{id}/update', [AddressController::class, 'update']);
    Route::delete('/{id}/destroy', [AddressController::class, 'destroy']);
});

// صفحات المفضلة للمستخدم (محمية بالمصادقة)
Route::prefix('wishlist')->middleware(['auth:sanctum', 'verified'])->group(function () {
    Route::get('/', [WishlistController::class, 'index']);
    Route::post('/toggle', [WishlistController::class, 'toggle']);
});

// صفحات طلبات المستخدم
Route::prefix('orders')->middleware(['auth:sanctum', 'verified'])->group(function () {
    Route::get('/', [OrderController::class, 'index']);
    Route::post('/', [OrderController::class, 'store']);
    Route::post('/reviews', [OrderController::class, 'addReview']);
    Route::get('/{order_number}', [OrderController::class, 'show']);
    Route::match(['GET', 'POST'], '/{order_number}/cancel', [OrderController::class, 'cancel']);
    Route::get('/{order_number}/invoice', [OrderController::class, 'invoice']);
});

// صفحات الدفع
Route::prefix('payments')->name('api-payments.')->middleware(['auth:sanctum', 'verified'])->group(function () {
    Route::get('/paytabs/pay/{order_number}', [PayTabsController::class, 'pay'])->name('paytabs.pay');
    
    // روتات إنشاء الدفع للبوابات الأخرى للتطبيق إذا احتجت:
    // Route::get('/tabby/pay/{order_number}', [TabbyController::class, 'pay'])->name('tabby.pay');
    // Route::get('/tamara/pay/{order_number}', [TamaraController::class, 'pay'])->name('tamara.pay');
});

//Paytabs
Route::post('payments/paytabs/callback', [PayTabsController::class, 'callback'])->name('api-payments.paytabs.callback');

// Tabby
Route::post('payments/tabby/webhook', [TabbyController::class, 'webhook'])->name('api-payments.tabby.webhook');
// Tamara
Route::post('payments/tamara/webhook', [TamaraController::class, 'webhook'])->name('api-payments.tamara.webhook');

// Infobip Notification
Route::prefix('sms')->name('api-sms.')->middleware('auth:sanctum')->group(function () {
    Route::post('/send', [SmsController::class, 'sendNotification']);
    Route::post('/otp/send', [SmsController::class, 'sendOtp']);
    Route::post('/otp/verify', [SmsController::class, 'verifyOtp']);
});
