<?php

use App\Http\Controllers\Auth\ForgotPasswordController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\RegisterController;
use Illuminate\Support\Facades\Route;

// guest يمنع الدخول لهذه الصفحات طالما هو مسجل دخول
Route::middleware('guest')->group(function () {
    Route::get('register', [RegisterController::class, 'create'])->name('register');
    Route::post('register', [RegisterController::class, 'store'])->name('register.store');
    Route::get('login', [LoginController::class, 'create'])->name('login');
    Route::post('login', [LoginController::class, 'store']);
    Route::get('forgot-password', [ForgotPasswordController::class, 'create'])->name('password.create');
    Route::post('forgot-password', [ForgotPasswordController::class, 'store'])->name('password.store');
    Route::post('send-otp', [RegisterController::class, 'sendOtp'])->name('send.otp');
    Route::post('send-reset-otp', [ForgotPasswordController::class, 'sendResetOtp'])->name('send.reset.otp');
});

Route::middleware('auth')->group(function () {
    Route::post('logout', [LoginController::class, 'destroy'])->name('logout');
});
