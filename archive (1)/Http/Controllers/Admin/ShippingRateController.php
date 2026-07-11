<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ShippingZone;
use App\Models\ShippingRate;

class ShippingRateController extends Controller
{

    public function __construct()
    {
        $this->middleware('check.permission:view_shipping')->only(['index', 'show']);
        $this->middleware('check.permission:create_shipping')->only(['create', 'store']);
        $this->middleware('check.permission:edit_shipping')->only(['edit', 'update']);
        $this->middleware('check.permission:delete_shipping')->only(['destroy']);
    }

    /**
     * عرض أسعار الشحن
     */
    public function index()
    {
        $rates = ShippingRate::with('zone')->latest()->paginate(15);

        return view('admin.shipping.rates.index', compact('rates'));
    }

    /**
     * اضافة سعر الشحن
     */
    public function create()
    {
        $zones = ShippingZone::where('status', 'active')->limit(15)->get();

        return view('admin.shipping.rates.create', compact('zones'));
    }

    /**
     * إضافة سعر شحن
     */
    public function store(Request $request)
    {
        $request->validate([
            'zone_id'       => 'required|exists:shipping_zones,id',
            'weight_from'   => 'required|numeric|min:0',
            'weight_to'     => 'required|numeric|gte:weight_from',
            'cost'          => 'required|numeric|min:0',
            'cod'           => 'boolean',
        ]);

        $rate = new ShippingRate();
        $rate->zone_id = $request->zone_id;
        $rate->cost = $request->cost;
        $rate->weight_from = $request->weight_from;
        $rate->weight_to = $request->weight_to;
        $rate->cod = $request->has('cod');

        $rate->save();

        return redirect()->back()->with('success', 'تم إضافة سعر الشحن بنجاح');
    }

    /**
     * تعديل سعر الشحن
     */
    public function edit($id)
    {
        $rate = ShippingRate::findOrFail($id);
        $zones = ShippingZone::where('status', 'active')->limit(15)->get();

        return view('admin.shipping.rates.edit', compact('rate', 'zones'));
    }

    /**
     * تحديث سعر شحن
     */
    public function update(Request $request, $id)
    {
        $rate = ShippingRate::findOrFail($id);

        $request->validate([
            'zone_id'       => 'required|exists:shipping_zones,id',
            'weight_from'   => 'required|numeric|min:0',
            'weight_to'     => 'required|numeric|gte:weight_from',
            'cost'          => 'required|numeric|min:0',
            'cod'           => 'boolean',
        ]);

        $rate->zone_id = $request->zone_id;
        $rate->cost = $request->cost;
        $rate->weight_from = $request->weight_from;
        $rate->weight_to = $request->weight_to;
        $rate->cod = $request->has('cod');
        $rate->save();

        return redirect()->back()->with('success', 'تم تحديث سعر الشحن بنجاح');
    }

    /**
     * حذف سعر شحن
     */
    public function destroy($id)
    {
        $rate = ShippingRate::findOrFail($id);
        $rate->delete();

        if (request()->ajax()) {
            return response()->json([
                'success' => true,
                'message' => 'تم حذف سعر الشحن بنجاح'
            ]);
        }
    }
}
