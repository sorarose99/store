<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FirebaseController extends Controller
{
    public function saveFcmToken(Request $request)
    {
        $request->validate([
            'token' => 'required|string',
            'device_id' => 'required|string',
            'platform' => 'nullable|string',
            'device_name' => 'nullable|string',
        ]);

        $user = Auth::user();

        // المنصة الافتراضية
        $platform = $request->platform ?? 'web';

        /*
        |--------------------------------------------------------------------------
        | حفظ التوكن
        |--------------------------------------------------------------------------
        | كل جهاز/متصفح يمتلك FCM Token خاص به
        | لذلك نبحث بالتوكن نفسه حتى لا يتم استبدال أجهزة أخرى
        |--------------------------------------------------------------------------
        */

        $user->devices()->updateOrCreate(
            [
                'device_id' => $request->device_id,
                'user_id' => $user->id,
            ],
            [
                'fcm_token' => $request->token,
                'platform' => $platform,
                'device_name' => $request->device_name,
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'FCM token saved successfully',
        ]);
    }
}
