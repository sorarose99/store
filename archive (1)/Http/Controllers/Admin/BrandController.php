<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Brand;
use App\Services\FileUploadService;

class BrandController extends Controller
{

    public function __construct()
    {
        $this->middleware('check.permission:view_brands')->only(['index', 'show']);
        $this->middleware('check.permission:create_brands')->only(['create', 'store']);
        $this->middleware('check.permission:edit_brands')->only(['edit', 'update']);
        $this->middleware('check.permission:delete_brands')->only(['destroy']);
    }

    /**
     * عرض قائمة العلامات التجارية
     */
    public function index()
    {
        $brands = Brand::withCount('products')
            ->latest()
            ->paginate(15);

        return view('admin.brands.index', compact('brands'));
    }

    /**
     * عرض نموذج إضافة علامة تجارية
     */
    public function create()
    {
        return view('admin.brands.create');
    }

    /**
     * حفظ علامة تجارية جديدة
     */
    public function store(Request $request)
    {
        $request->validate([
            'name'          => 'required|string|max:255|unique:brands',
            'description'   => 'nullable|string',
            'logo'          => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
            'website'       => 'nullable|url',
        ]);

        $brand = new Brand();
        $brand->name = $request->name;
        $brand->description = $request->description;
        $brand->website = $request->website;

        if ($request->hasFile('logo')) {
            $path = FileUploadService::upload(
                $request->file('logo'),
                'uploads/brands',
                ['jpg', 'jpeg', 'png', 'webp']
            );
            $brand->logo = $path;
        }

        $brand->save();

        return redirect()->route('admin.brands.index')->with('success', 'تم إضافة العلامة التجارية بنجاح');
    }

    /**
     * عرض تفاصيل العلامة التجارية
     */
    public function show($id)
    {

    }

    /**
     * عرض نموذج تعديل العلامة التجارية
     */
    public function edit($id)
    {
        $brand = Brand::findOrFail($id);

        return view('admin.brands.edit', compact('brand'));
    }

    /**
     * تحديث العلامة التجارية
     */
    public function update(Request $request, $id)
    {
        $brand = Brand::findOrFail($id);

        $request->validate([
            'name'          => 'required|string|max:255|unique:brands,name,' . $id,
            'description'   => 'nullable|string',
            'logo'          => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
            'website'       => 'nullable|url',
            'status'        => 'boolean',
        ]);

        $brand->name = $request->name;
        $brand->description = $request->description;
        $brand->website = $request->website;
        $brand->status = $request->has('status') === true ? 'active' : 'inactive';


        if ($request->hasFile('logo')) {
            $path = FileUploadService::upload(
                $request->file('logo'),
                'uploads/brands',
                ['jpg', 'jpeg', 'png', 'webp'],
                $brand->logo
            );
            $brand->logo = $path;
        }

        $brand->save();

        return redirect()->route('admin.brands.index')->with('success', 'تم تحديث العلامة التجارية بنجاح');
    }

    /**
     * حذف العلامة التجارية
     */
    public function destroy($id)
    {
        $brand = Brand::findOrFail($id);

        // التحقق من وجود منتجات
        if ($brand->products()->count() > 0) {
            if (request()->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يمكن حذف علامة تجارية تحتوي على منتجات'
                ], 422);
            }
        }

        // حذف الشعار
        if ($brand->logo) {
            FileUploadService::delete($brand->logo);
        }

        $brand->delete();

        if (request()->ajax()) {
            return response()->json([
                'success' => true,
                'message' => 'تم حذف العلامة التجارية بنجاح'
            ]);
        }
    }
}
