<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Permission;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{

    public function __construct()
    {
        $this->middleware('check.permission:view_users')->only(['index', 'show']);
        $this->middleware('check.permission:create_users')->only(['create', 'store']);
        $this->middleware('check.permission:edit_users')->only(['edit', 'update']);
        $this->middleware('check.permission:delete_users')->only(['destroy']);
    }

    /**
     * عرض قائمة المستخدمين
     */
    public function index(Request $request)
    {
        $users = User::whereIn('role', ['admin', 'employee'])
            ->select('id', 'uuid', 'role', 'first_name', 'last_name', 'email', 'status', 'last_login_at')
            ->latest()
            ->paginate(15);

        $permissions = Permission::all(['id', 'name']);
        return view('admin.users.index', compact('users', 'permissions'));
    }

    /**
     * عرض نموذج إضافة مستخدم
     */
    public function create()
    {
        $permissions = Permission::latest()->get();

        return view('admin.users.create', compact('permissions'));
    }

    public function show($uuid) {}

    /**
     * حفظ مستخدم جديد
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'first_name'    => 'required|string|max:255',
            'last_name'     => 'required|string|max:255',
            'email'         => 'required|email|unique:users',
            'password'      => 'required|min:8|confirmed',
            'role'          => 'required|in:admin,employee',
            'permissions'   => 'nullable|array',
            'permissions.*' => 'exists:permissions,id'
        ]);

        $user = new User();
        $user->first_name           = $validated['first_name'];
        $user->last_name            = $validated['last_name'];
        $user->email                = $validated['email'];
        $user->role                 = $validated['role'];
        $user->password             = Hash::make($validated['password']);
        $user->terms_accepted_at    = now();
        $user->verified_at    = now();

        $user->save();

        // تعيين صلاحيات خاصة (اختياري)
        $user->permissions()->sync($validated['permissions'] ?? []);

        return redirect()->route('admin.users.index')->with('success', 'تم إضافة المستخدم بنجاح');
    }

    /**
     * عرض نموذج تعديل المستخدم
     */
    public function edit($uuid)
    {
        $user = User::where('uuid', $uuid)->firstOrFail();
        $permissions = Permission::latest()->get();

        return view('admin.users.edit', compact('user', 'permissions'));
    }

    /**
     * تحديث المستخدم
     */
    public function update(Request $request, $uuid)
    {
        $user = User::where('uuid', $uuid)->firstOrFail();

        $validated = $request->validate([
            'first_name'    => 'required|string|max:255',
            'last_name'     => 'required|string|max:255',
            'email'         => 'required|email|unique:users,email,' . $user->id,
            'password'      => 'nullable|min:8|confirmed',
            'role'          => 'required|in:admin,employee',
            'permissions'   => 'nullable|array',
            'permissions.*' => 'exists:permissions,id',
            'status'        => 'required|in:active,inactive',
        ]);

        $user->first_name = $validated['first_name'];
        $user->last_name  = $validated['last_name'];
        $user->email      = $validated['email'];
        $user->status     = $validated['status'];
        $user->role       = $validated['role'];

        // تحديث كلمة المرور فقط إذا تم إدخالها
        if (!empty($validated['password'])) {
            $user->password = Hash::make($validated['password']);
        }

        $user->save();

        // تحديث الصلاحيات
        $user->permissions()->sync($validated['permissions'] ?? []);

        return redirect()->route('admin.users.index')->with('success', 'تم تحديث المستخدم بنجاح');
    }
    /**
     * حذف المستخدم
     */
    public function destroy($uuid)
    {
        $user = User::where('uuid', $uuid)->firstOrFail();

        // حماية المدير الرئيسي
        if ($user->role === 'admin') {
            if (request()->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يمكن حذف مدير الموقع'
                ], 422);
            }
            return back()->with('error', 'لا يمكن حذف مدير الموقع');
        }

        $user->delete();

        if (request()->ajax()) {
            return response()->json([
                'success' => true,
                'message' => 'تم حذف المستخدم بنجاح'
            ]);
        }

        return redirect()->route('admin.users.index')->with('success', 'تم حذف المستخدم بنجاح');
    }
}
