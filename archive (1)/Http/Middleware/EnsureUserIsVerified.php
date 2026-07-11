<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsVerified
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        /**
         * المستخدم غير مسجل دخول
         */
        if (! $user) {
            return redirect()->route('login');
        }

        /**
         * الحساب غير مفعل
         */
        if (! $user->verified_at) {

            // API Request
            if ($request->expectsJson()) {

                return response()->json([
                    'message' => 'Your account is not verified.',
                ], 403);
            }

            return redirect()->route('login')->with('error', 'Your account is not verified.');
        }

        return $next($request);
    }
}
