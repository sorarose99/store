<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ShippingZone;

class ShippingZoneController extends Controller
{

    public function __construct()
    {
        $this->middleware('check.permission:view_shipping')->only(['index', 'show']);
        $this->middleware('check.permission:create_shipping')->only(['create', 'store']);
        $this->middleware('check.permission:edit_shipping')->only(['edit', 'update']);
        $this->middleware('check.permission:delete_shipping')->only(['destroy']);
    }
    /**
     * عرض دول الشحن
     */
    public function index()
    {
        $zones = ShippingZone::latest()->paginate(15);;

        return view('admin.shipping.zones.index', compact('zones'));
    }

    /**
     * اضافة دول الشحن
     */
    public function create()
    {
        return view('admin.shipping.zones.create');
    }

    /**
     * إضافة دولة شحن
     */
    public function store(Request $request)
    {
        $request->validate([
            'country_code'      => 'required|string|max:255',
            'shipping_provider' => 'required|string|max:255',
            'default_address'   => 'nullable|string',
            'tax_rate'          => 'required|numeric|min:0|max:100',
        ]);

        $countries = config('countries');

        ShippingZone::create([
            'name' => $countries[$request->country_code],
            'country_code' => $request->country_code,
            'shipping_provider' => $request->shipping_provider,
            'default_address' => $request->default_address,
            'tax_rate' => $request->tax_rate,
        ]);

        return redirect()->back()->with('success', 'تم إضافة دولة الشحن بنجاح');
    }

    /**
     * تعديل دول الشحن
     */
    public function edit($id)
    {
        $zone = ShippingZone::findOrFail($id);

        return view('admin.shipping.zones.edit', compact('zone'));
    }

    /**
     * تحديث دولة شحن
     */
    public function update(Request $request, $id)
    {
        $zone = ShippingZone::findOrFail($id);
        $countries = config('countries');

        $request->validate([
            'country_code'      => 'required|string|max:255',
            'shipping_provider' => 'nullable|string|max:255',
            'default_address'   => 'nullable|string',
            'tax_rate'          => 'required|numeric|min:0|max:100',
            'status'            => 'boolean',
        ]);

        $zone->update([
            'name' => $countries[$request->country_code],
            'country_code' => $request->country_code,
            'shipping_provider' => $request->shipping_provider,
            'default_address' => $request->default_address,
            'tax_rate' => $request->tax_rate,
            'status' => $request->has('status') === true ? 'active' : 'inactive',
        ]);

        return redirect()->back()->with('success', 'تم تحديث دولة الشحن بنجاح');
    }


    /**
     * حذف دولة شحن
     */
    public function destroy($id)
    {
        $zone = ShippingZone::findOrFail($id);
        $zone->delete();
        if (request()->ajax()) {
            return response()->json([
                'success' => true,
                'message' => 'تم حذف دولة الشحن بنجاح'
            ]);
        }
    }
}
