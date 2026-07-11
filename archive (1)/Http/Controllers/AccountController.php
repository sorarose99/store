<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Services\FileUploadService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;
class AccountController extends Controller
{
    /**
     * عرض حساب العميل
     */
    public function myAccount()
    {
        $user = Auth::user();
        $total_orders = $user->orders()->count();
        $pending_orders = $user->orders()->where('status', 'pending')->count();
        $processing_orders = $user->orders()->where('status', 'processing')->count();
        $completed_orders = $user->orders()->where('status', 'completed')->count();
        $wishlist_count = $user->wishlist()->count();

        $orders = Order::select([
            'id',
            'order_number',
            'total',
            'status',
            'created_at',
            'user_id'
        ])
            ->where('user_id', $user->id)
            ->latest('created_at')
            ->take(10)
            ->get();
        return view('account.my_account', compact('orders', 'user', 'total_orders', 'pending_orders', 'processing_orders', 'completed_orders', 'wishlist_count'));
    }

    /**
     * عرض صفحة الملف الشخصي
     */
    public function profile()
    {
        $user = Auth::user();
        return view('account.profile', compact('user'));
    }

    /**
     * تحديث الملف الشخصي
     */
    public function updateProfile(Request $request)
    {
        $user = Auth::user();

        $validated = $request->validate([
            'first_name' => ['required', 'string', 'max:255'],
            'last_name'  => ['required', 'string', 'max:255'],
            'gender'     => ['nullable', 'in:male,female'],
            'birth_date' => ['nullable', 'date'],
            'avatar'     => ['nullable', 'image', 'max:2048'], // 2MB
        ]);

        // تحديث الصورة
        if ($request->hasFile('avatar')) {
            $path = FileUploadService::upload(
                $request->file('avatar'),
                'uploads/users_avatar',
                ['jpg', 'jpeg', 'png', 'webp'],
                $user->avatar
            );

            $validated['avatar'] = $path;
        }
        $user->update($validated);

        return redirect()->route('account.profile')->with('success', __('messages.profile_updated_successfully'));
    }

    /**
     * عرض صفحة تغيير كلمة المرور
     */
    public function showChangePasswordForm()
    {
        $user = Auth::user();
        if ($user->role !== 'client') {
            return redirect()->back()->with('success', __('messages.only_clients_can_change_password'));
        }

        return view('account.change-password', compact('user'));
    }

    /**
     * تغيير كلمة المرور
     */
    public function changePassword(Request $request)
    {
        $user = Auth::user();

        if ($user->role !== 'client') {
            return redirect()->back()->with('success', __('messages.only_clients_can_change_password'));
        }

        $request->validate([
            'current_password' => ['required'],
            'password' => [
                'required',
                'confirmed',
                Password::min(8),
            ],
        ]);

        // التحقق من كلمة المرور الحالية
        if (!Hash::check($request->current_password, $user->password)) {
            return back()->withErrors([
                'current_password' => __('messages.current_password_incorrect')
            ]);
        }

        // تحديث كلمة المرور
        $user->update([
            'password' => Hash::make($request->password),
        ]);

        return redirect()
            ->back()
            ->with('success', __('messages.password_changed_successfully'));
    }

    /**
     * Delete the user's account.
     */
    public function destroy(Request $request)
    {

        $request->validate([
            'password' => ['required', 'current_password'],
        ]);

        $user = $request->user();

        Auth::logout(); // تسجيل خروج

        $user->delete(); // حذف الحساب

        $request->session()->invalidate(); // انهاء الجلسة
        $request->session()->regenerateToken();
        
        return response()->json([
            'success' => true,
            'message' => __('messages.account_deleted_successfully')
        ]);
    }

    /**
     * عرض صفحة اعدادات الاشعارات للمستخدم
     */
    public function notifications()
    {
        return view('account.notifications');
    }
}
