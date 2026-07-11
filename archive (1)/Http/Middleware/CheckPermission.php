<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CheckPermission
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @param  string  $permission
     * @return mixed
     */
    public function handle(Request $request, Closure $next, $permission = null)
    {
        $user = Auth::user();

        if (!$user) {
            return redirect()->route('home')->with('error', 'غير مسموح الوصول، يرجى تسجيل الدخول');
        }

        // إذا المستخدم ادمن، يسمح له بالدخول لكل شيء
        if ($user->role === 'admin') {
            return $next($request);
        }

        // إذا المستخدم موظف، يتحقق من الصلاحية
        if ($user->role === 'employee') {
            if ($permission && !$user->permissions()->where('name', $permission)->exists()) {
                return redirect()->route('home')->with('error', 'ليس لديك صلاحية الوصول لهذه الصفحة');
            }
            return $next($request);
        }

        // إذا المستخدم زبون يمنع الوصول
        return redirect()->route('home')->with('error', 'ليس لديك صلاحية الدخول لهذه المنطقة');
    }
}
