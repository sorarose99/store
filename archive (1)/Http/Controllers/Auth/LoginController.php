<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    /**
     * Show Login Page
     */
    public function create()
    {
        return view('auth.login');
    }

    /**
     * Login
     */
    public function store(Request $request)
    {
        $request->validate([
            'login' => ['required', 'string'],
            'password' => ['required'],
        ]);

        /**
         * تحديد نوع تسجيل الدخول
         */
        $field = filter_var($request->login, FILTER_VALIDATE_EMAIL) ? 'email' : 'phone';

        /**
         * محاولة تسجيل الدخول
         */
        if (! Auth::attempt([$field => $request->login, 'password' => $request->password], $request->boolean('remember'))) {
            return back()->withErrors(['login' => __('auth.failed')])->withInput();
        }

        /**
         * تجديد الجلسة
         */
        $request->session()->regenerate();

        $user = $request->user();

        /**
         * تحديث آخر تسجيل دخول
         */
        $user->update([
            'last_login_at' => now(),
            'last_login_ip' => $request->ip(),
        ]);

        /**
         * Admin / Employee
         */
        if ($user->hasRole('admin') || $user->hasRole('employee')) {

            // API REQUEST
            if ($request->expectsJson()) {

                $token = $user->createToken('auth_token')->plainTextToken;

                return response()->json([
                    'message' => 'Login successful',
                    'user' => $user,
                    'access_token' => $token,
                    'token_type' => 'Bearer',
                ]);
            }

            // WEB REQUEST
            return redirect()->route('admin.dashboard');
        }

        /**
         * Client
         */
        if ($user->hasRole('client')) {
            return redirect()->route('home');
        }

        return redirect()->intended(route('home', absolute: false));
    }

    /**
     * Logout
     */
    public function destroy(Request $request)
    {
        Auth::logout();

        $request->session()->invalidate();

        $request->session()->regenerateToken();

        return redirect()->route('login');
    }
}
