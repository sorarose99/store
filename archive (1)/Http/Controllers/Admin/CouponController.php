<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Coupon;

class CouponController extends Controller
{

    public function __construct()
    {
        $this->middleware('check.permission:view_coupons')->only(['index', 'show']);
        $this->middleware('check.permission:create_coupons')->only(['create', 'store']);
        $this->middleware('check.permission:edit_coupons')->only(['edit', 'update']);
        $this->middleware('check.permission:delete_coupons')->only(['destroy']);
    }

    /**
     * عرض قائمة الكوبونات
     */
    public function index(Request $request)
    {
        $coupons = Coupon::latest()->paginate(15);

        return view('admin.coupons.index', compact('coupons'));
    }

    /**
     * عرض نموذج إضافة كوبون
     */
    public function create()
    {
        return view('admin.coupons.create');
    }

    /**
     * حفظ كوبون جديد
     */
    public function store(Request $request)
    {
        $request->validate([
            'code' => 'required|string|unique:coupons|max:50',
            'type' => 'required|in:fixed,percentage',
            'value' => 'required|numeric|min:0',
            'min_order' => 'nullable|numeric|min:0',
            'max_discount' => 'nullable|numeric|min:0|required_if:type,percentage',
            'starts_at' => 'nullable|date',
            'expires_at' => 'nullable|date|after:starts_at',
            'usage_limit' => 'nullable|integer|min:1',
            'usage_limit_per_user' => 'nullable|integer|min:1',
            'description' => 'nullable|string',
            'status' => 'required|in:active,inactive',
        ]);

        $coupon = new Coupon();
        $coupon->code = strtoupper($request->code);
        $coupon->type = $request->type;
        $coupon->value = $request->value;
        $coupon->min_order = $request->min_order;

        if ($request->type === 'fixed') {
            $coupon->max_discount = null;
        } else {
            $coupon->max_discount = $request->max_discount;
        }

        $coupon->starts_at = $request->starts_at;
        $coupon->expires_at = $request->expires_at;
        $coupon->usage_limit = $request->usage_limit;
        $coupon->usage_limit_per_user = $request->usage_limit_per_user;
        $coupon->description = $request->description;
        $coupon->status = $request->status;
        $coupon->save();

        return redirect()->back()
            ->with('success', 'تم إضافة الكوبون بنجاح');
    }

    /**
     * عرض تفاصيل الكوبون
     */
    public function show($id) {}

    /**
     * عرض نموذج تعديل الكوبون
     */
    public function edit($id)
    {
        $coupon = Coupon::findOrFail($id);

        return view('admin.coupons.edit', compact('coupon'));
    }

    /**
     * تحديث الكوبون
     */
    public function update(Request $request, Coupon $coupon)
    {
        $request->validate([
            'code' => 'required|string|max:50|unique:coupons,code,' . $coupon->id,
            'type' => 'required|in:fixed,percentage',
            'value' => 'required|numeric|min:0',
            'min_order' => 'nullable|numeric|min:0',
            'max_discount' => 'nullable|numeric|min:0|required_if:type,percentage',
            'starts_at' => 'nullable|date',
            'expires_at' => 'nullable|date|after:starts_at',
            'usage_limit' => 'nullable|integer|min:1',
            'usage_limit_per_user' => 'nullable|integer|min:1',
            'description' => 'nullable|string',
            'status' => 'required|in:active,inactive',
        ]);

        $coupon->code = strtoupper($request->code);
        $coupon->type = $request->type;
        $coupon->value = $request->value;
        $coupon->min_order = $request->min_order;

        if ($request->type === 'fixed') {
            $coupon->max_discount = null;
        } else {
            $coupon->max_discount = $request->max_discount;
        }

        $coupon->starts_at = $request->starts_at;
        $coupon->expires_at = $request->expires_at;
        $coupon->usage_limit = $request->usage_limit;
        $coupon->usage_limit_per_user = $request->usage_limit_per_user;
        $coupon->description = $request->description;
        $coupon->status = $request->status;

        $coupon->save();

        return redirect()->back()
            ->with('success', 'تم تحديث الكوبون بنجاح');
    }

    /**
     * حذف الكوبون
     */
    public function destroy($id)
    {
        $coupon = Coupon::findOrFail($id);
        $coupon->delete();

        if (request()->ajax()) {
            return response()->json([
                'success' => true,
                'message' => 'تم حذف الكوبون بنجاح'
            ]);
        }
    }
}
