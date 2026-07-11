<?php

use App\Http\Controllers\AccountController;
use App\Http\Controllers\AddressController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\PageController;
use App\Http\Controllers\PayTabsController;
use App\Http\Controllers\ShopController;
use App\Http\Controllers\SmsController;
use App\Http\Controllers\TabbyController;
use App\Http\Controllers\TamaraController;
use App\Http\Controllers\WishlistController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

// الصفحة الرئيسية
Route::get('/', [HomeController::class, 'index'])->name('home');

// صفحات المتجر
Route::prefix('shop')->name('shop.')->group(function () {
    Route::get('/', [ShopController::class, 'index'])->name('index');
    Route::get('/category/{slug}', [ShopController::class, 'category'])->name('category');
    Route::get('/category/{main_category_slug}/{sub_category_slug}/products', [ShopController::class, 'categoryProducts'])->name('category.products');
    Route::get('/product/{slug}', [ShopController::class, 'product'])->name('product');
    Route::get('/product/{slug}/reviews', [ShopController::class, 'reviews'])->name('product.reviews');
});

// صفحات التصنيفات
Route::prefix('categories')->name('categories.')->group(function () {
    Route::get('/', [ShopController::class, 'categories'])->name('index');
});

// صفحات السلة والطلب
Route::prefix('cart')->name('cart.')->middleware('auth')->group(function () {
    Route::get('/', [CartController::class, 'index'])->name('index');
    Route::post('/add', [CartController::class, 'add'])->name('add');
    Route::put('/update/{productId}', [CartController::class, 'update'])->name('update');
    Route::delete('/remove/{productId}', [CartController::class, 'remove'])->name('remove');
    Route::delete('/clear', [CartController::class, 'clear'])->name('clear');

    Route::post('/coupon', [CartController::class, 'applyCoupon'])->name('coupon');
    Route::delete('/coupon', [CartController::class, 'removeCoupon'])->name('coupon.remove');

    Route::post('/update-shipping-zone', [CartController::class, 'updateShippingZone'])->name('update.shipping.zone');
    Route::get('/checkout', [CartController::class, 'checkout'])->name('checkout');
    Route::get('/count', [CartController::class, 'getCartCount'])->name('count');
    Route::put('/breakdown/{productId}', [CartController::class, 'updateBreakdown']);
});

// delete client account
Route::prefix('account')->name('account.')->middleware('auth')->group(function () {
    Route::delete('/destroy', [AccountController::class, 'destroy'])->name('destroy');
});

// صفحات المستخدم (محمية بالمصادقة)
Route::prefix('account')->name('account.')->middleware(['auth', 'verified'])->group(function () {
    // لوحة التحكم
    Route::get('/', [AccountController::class, 'myAccount'])->name('my_account');

    // الملف الشخصي
    Route::get('/profile', [AccountController::class, 'profile'])->name('profile');
    Route::put('/profile', [AccountController::class, 'updateProfile'])->name('profile.update');

    // تغيير كلمة المرور
    Route::get('/change-password', [AccountController::class, 'showChangePasswordForm'])->name('change-password');
    Route::put('/change-password', [AccountController::class, 'changePassword'])->name('password.change');

    // اعدادات الاشعارات
    Route::get('/notifications', [AccountController::class, 'notifications'])->name('notifications');

});

// صفحات عناوين الشحن للمستخدم (محمية بالمصادقة)
Route::prefix('addresses')->name('addresses.')->middleware(['auth', 'verified'])->group(function () {
    Route::get('/', [AddressController::class, 'index'])->name('index');
    Route::get('/create', [AddressController::class, 'create'])->name('create');
    Route::post('/store', [AddressController::class, 'store'])->name('store');
    Route::get('/{id}/edit', [AddressController::class, 'edit'])->name('edit');
    Route::put('/{id}/update', [AddressController::class, 'update'])->name('update');
    Route::delete('/{id}/destroy', [AddressController::class, 'destroy'])->name('destroy');
});

// صفحات المفضلة للمستخدم (محمية بالمصادقة)
Route::prefix('wishlist')->name('wishlist.')->group(function () {
    Route::get('/', [WishlistController::class, 'index'])->middleware(['auth', 'verified'])->name('index');
    Route::post('/toggle', [WishlistController::class, 'toggle'])->name('toggle');
});

// صفحات طلبات المستخدم
Route::prefix('orders')->name('orders.')->middleware(['auth', 'verified'])->group(function () {
    Route::get('/', [OrderController::class, 'index'])->name('index');
    Route::post('/', [OrderController::class, 'store'])->name('store');
    Route::post('/reviews', [OrderController::class, 'addReview'])->name('add.review');
    Route::get('/{order_number}', [OrderController::class, 'show'])->name('show');
    Route::get('/{order_number}/success', [OrderController::class, 'success'])->name('success');
    Route::get('/{order_number}/failed', [OrderController::class, 'failed'])->name('failed');
    Route::match(['GET', 'POST'], '/{order_number}/cancel', [OrderController::class, 'cancel'])->name('cancel');
    Route::get('/{order_number}/invoice', [OrderController::class, 'invoice'])->name('invoice');
});

// صفحات الدفع
Route::prefix('payments')->name('payments.')->group(function () {
    // PayTabs
    Route::get('/paytabs/pay/{order_number}', [PayTabsController::class, 'pay'])->middleware(['auth', 'verified'])->name('paytabs.pay');
    Route::match(['GET', 'POST'], '/paytabs/return', [PayTabsController::class, 'return'])->name('paytabs.return');

    // Tabby
    Route::get('/tabby/pay/{order_number}', [TabbyController::class, 'pay'])->middleware(['auth', 'verified'])->name('tabby.pay');
    Route::get('/tabby/{order_number}/cancel', [TabbyController::class, 'handleTabbyCancel'])->name('tabby.cancel');

    // Tamara
    Route::get('/tamara/pay/{order_number}', [TamaraController::class, 'pay'])->middleware(['auth', 'verified'])->name('tamara.pay');
    Route::get('/tamara/{order_number}/cancel', [TamaraController::class, 'handleTamaraCancel'])->name('tamara.cancel');
});

// Infobip Notification
Route::prefix('sms')->name('sms.')->middleware('auth')->group(function () {
    Route::post('/send', [SmsController::class, 'sendNotification']);
    Route::post('/otp/send', [SmsController::class, 'sendOtp']);
    Route::post('/otp/verify', [SmsController::class, 'verifyOtp']);
});

// الصفحات الثابتة
Route::prefix('pages')->name('pages.')->group(function () {
    Route::get('/about', [PageController::class, 'about'])->name('about');
    Route::get('/contact', [PageController::class, 'contact'])->name('contact');
    Route::post('/contact', [PageController::class, 'sendContact'])->name('contact.send');
    Route::get('/terms', [PageController::class, 'terms'])->name('terms');
    Route::get('/privacy', [PageController::class, 'privacy'])->name('privacy');
    Route::get('/return-policy', [PageController::class, 'returnPolicy'])->name('return-policy');
    Route::get('/feedback', [PageController::class, 'feedback'])->name('feedback');
    Route::get('/licenses', [PageController::class, 'licenses'])->name('licenses');
    Route::get('/delete-account', [PageController::class, 'deleteAccount'])->name('delete.account');
});
