<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\FirebaseController;

//user auth
require __DIR__.'/auth.php';

//user interface
require __DIR__.'/user_interface.php';

Route::post('/auth/firebase-sync', [App\Http\Controllers\Api\FirebaseController::class, 'syncUser']);



//send request from app into laravel
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/api-save-fcm-token', [FirebaseController::class, 'saveFcmToken']);
});
/*

https://kdx-sa.com/api/api-auth/login
Accept : application/json
Authorization : Bearer 18|v0J0lAru0jqhgCUQbLmfGgmXVYibqOATGhdhzF4V0ee59f19
*/