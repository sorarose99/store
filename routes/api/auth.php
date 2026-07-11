<?php

use App\Http\Controllers\Api\Auth\ForgotPasswordController;
use App\Http\Controllers\Api\Auth\LoginController;
use App\Http\Controllers\Api\Auth\RegisterController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Auth Routes
|--------------------------------------------------------------------------
*/

Route::prefix('api-auth')->group(function () {

    Route::post('register/send-otp', [RegisterController::class, 'sendOtp']);
    Route::post('register', [RegisterController::class, 'store']);
    Route::post('login', [LoginController::class, 'store']);
    Route::post('forgot-password/send-otp', [ForgotPasswordController::class, 'sendResetOtp']);
    Route::post('forgot-password/reset', [ForgotPasswordController::class, 'resetPassword']);

    // Routes للمستخدم المسجل دخول فقط
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('logout', [LoginController::class, 'destroy']);
    });
});
