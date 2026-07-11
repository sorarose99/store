<?php

use App\Http\Controllers\Admin\BannerController;
use App\Http\Controllers\Admin\BrandController;
use App\Http\Controllers\Admin\CategoryController;
use App\Http\Controllers\Admin\ColorController;
use App\Http\Controllers\Admin\ContactController;
use App\Http\Controllers\Admin\CouponController;
use App\Http\Controllers\Admin\CustomerController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\OrderController;
use App\Http\Controllers\Admin\PaymentGatewayController;
use App\Http\Controllers\Admin\ProductController;
use App\Http\Controllers\Admin\ProductExcelController;
use App\Http\Controllers\Admin\ProductExcelDirectController;
use App\Http\Controllers\Admin\SettingController;
use App\Http\Controllers\Admin\ShippingRateController;
use App\Http\Controllers\Admin\ShippingZoneController;
use App\Http\Controllers\Admin\SizeController;
use App\Http\Controllers\Admin\TagController;
use App\Http\Controllers\Admin\UserController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Admin Routes
|--------------------------------------------------------------------------
*/

Route::prefix('admin')->name('admin.')->middleware(['auth'])->group(function () {

    // Customers
    Route::get('customers', [CustomerController::class, 'index'])->name('customers.index');
    Route::get('customers/{id}', [CustomerController::class, 'show'])->name('customers.show');
    Route::get('customers/{id}/notifications/create', [CustomerController::class, 'createNotification'])->name('customers.notifications.create');
    Route::post('customers/{id}/notifications', [CustomerController::class, 'storeNotification'])->name('customers.notifications.store');
    Route::put('customers/{id}/block', [CustomerController::class, 'block'])->name('customers.block');
    Route::put('customers/{id}/unblock', [CustomerController::class, 'unblock'])->name('customers.unblock');
    Route::get('customers/{id}/orders', [CustomerController::class, 'orders'])->name('customers.orders');
    Route::delete('customers/{id}', [CustomerController::class, 'destroy'])->name('customers.destroy');
    Route::get('customers/export', [CustomerController::class, 'export'])->name('customers.export');

    // Dashboard
    Route::get('', [DashboardController::class, 'index'])->name('dashboard');

    // Products
    Route::post('products/import', [ProductExcelController::class, 'importFromExcel'])->name('products.import');
    Route::post('products/import/direct', [ProductExcelDirectController::class, 'importFromExcel'])->name('products.import.direct');
    Route::post('products/bulk-delete', [ProductController::class, 'bulkDelete'])->name('products.bulkDelete');
    Route::resource('products', ProductController::class);

    // Categories
    Route::post('categories/add', [CategoryController::class, 'addAjax'])->name('categories.add.ajax');
    Route::get('categories/search', [CategoryController::class, 'search'])->name('categories.search');
    Route::get('categories/{id}/children', [CategoryController::class, 'children'])->name('categories.children');
    Route::delete('categories/truncate', [CategoryController::class, 'truncateCategories'])->name('categories.truncate');

    Route::resource('categories', CategoryController::class);

    // Tags
    Route::post('tags/add', [TagController::class, 'addAjax'])->name('tags.add.ajax');
    Route::get('tags/search', [TagController::class, 'search'])->name('tags.search');
    Route::delete('tags/truncate', [TagController::class, 'truncateTags'])->name('tags.truncate');
    Route::resource('tags', TagController::class);

    // Orders
    Route::get('orders', [OrderController::class, 'index'])->name('orders.index');
    Route::get('orders/{id}', [OrderController::class, 'show'])->name('orders.show');
    Route::put('orders/{id}/status', [OrderController::class, 'updateStatus'])->name('orders.status');
    Route::get('orders/{id}/invoice', [OrderController::class, 'invoice'])->name('orders.invoice');

    // Coupons
    Route::post('coupons/validate', [CouponController::class, 'validate'])->name('coupons.validate');
    Route::resource('coupons', CouponController::class);

    // Payments
    Route::get('payments', [PaymentGatewayController::class, 'index'])->name('payments.index');
    Route::post('/payments/{gateway}', [PaymentGatewayController::class, 'update'])->name('payments.update');
    Route::get('payments/history', [PaymentGatewayController::class, 'history'])->name('payments.history');
    Route::post('payments/history/{id}', [PaymentGatewayController::class, 'show'])->name('payments.show');
    Route::get('payments/export', [PaymentGatewayController::class, 'export'])->name('payments.export');

    // Shipping Zones & Rates
    Route::resource('shipping-zones', ShippingZoneController::class);
    Route::resource('shipping-rates', ShippingRateController::class);

    // Banners
    Route::resource('banners', BannerController::class);

    // Users (Employees)
    Route::resource('users', UserController::class);

    // Colors
    Route::get('/colors/search', [ColorController::class, 'search'])->name('colors.search');
    Route::post('/colors/add', [ColorController::class, 'addAjax'])->name('colors.add.ajax');
    Route::delete('colors/truncate', [ColorController::class, 'truncateColors'])->name('colors.truncate');
    Route::resource('colors', ColorController::class);

    // Sizes
    Route::get('/sizes/search', [SizeController::class, 'search'])->name('sizes.search');
    Route::post('/sizes/add', [SizeController::class, 'addAjax'])->name('sizes.add.ajax');
    Route::delete('sizes/truncate', [SizeController::class, 'truncateSizes'])->name('sizes.truncate');
    Route::resource('sizes', SizeController::class);

    // Settings
    Route::get('/settings', [SettingController::class, 'index'])->name('settings.index');
    Route::post('/settings', [SettingController::class, 'update'])->name('settings.update');

    // Brands
    Route::resource('brands', BrandController::class);

    // Contact Messages
    Route::get('/contact_messages', [ContactController::class, 'index'])->name('contact.index');
    Route::get('/contact_messages/{id}/show', [ContactController::class, 'show'])->name('contact.show');
    Route::delete('/contact_messages/{id}/destroy', [ContactController::class, 'destroy'])->name('contact.destroy');
});
