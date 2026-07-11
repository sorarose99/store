<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    /**
     * Login (API)
     */
    public function store(Request $request)
    {
        $request->validate([
            'login' => ['required', 'string'],
            'password' => ['required', 'string'],
        ]);

        /**
         * تحديد نوع تسجيل الدخول
         */
        $field = filter_var($request->login, FILTER_VALIDATE_EMAIL)
            ? 'email'
            : 'phone';

        /**
         * محاولة تسجيل الدخول
         */
        if (! Auth::attempt([
            $field => $request->login,
            'password' => $request->password,
        ])) {
            return response()->json([
                'success' => false,
                'message' => __('auth.failed'),
            ], 422);
        }

        /**
         * جلب المستخدم
         */
        $user = Auth::user();

        /**
         * تحديث آخر تسجيل دخول
         */
        $user->update([
            'last_login_at' => now(),
            'last_login_ip' => $request->ip(),
        ]);

        /**
         * حذف التوكنات القديمة (اختياري - مهم للأمان)
         */
        $user->tokens()->delete();

        /**
         * إنشاء token جديد
         */
        $token = $user->createToken('auth_token')->plainTextToken;

        /**
         * Response حسب الدور
         */
        if ($user->hasRole('admin') || $user->hasRole('employee')) {
            return response()->json([
                'success' => true,
                'message' => 'Login successful (admin/employee)',
                'user' => $user,
                'access_token' => $token,
                'token_type' => 'Bearer',
                'redirect' => 'admin',
            ]);
        }

        if ($user->hasRole('client')) {
            return response()->json([
                'success' => true,
                'message' => 'Login successful',
                'user' => $user,
                'access_token' => $token,
                'token_type' => 'Bearer',
                'redirect' => 'home',
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'user' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    /**
     * Logout (API)
     */
    public function destroy(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully',
        ]);
    }
}
