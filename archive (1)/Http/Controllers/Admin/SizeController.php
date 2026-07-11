<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Size;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;

class SizeController extends Controller
{

    public function __construct()
    {
        $this->middleware('check.permission:view_sizes')->only(['index', 'show']);
        $this->middleware('check.permission:create_sizes')->only(['create', 'store']);
        $this->middleware('check.permission:edit_sizes')->only(['edit', 'update']);
        $this->middleware('check.permission:delete_sizes')->only(['destroy']);
    }

    /**
     * عرض قائمة القياسات
     */
    public function index(Request $request)
    {
        $sizes = Size::query()
            ->when($request->search, function ($q) use ($request) {
                $q->where('name', 'like', '%'.$request->search.'%');
            })
            ->latest()
            ->paginate(15)
            ->withQueryString();

        return view('admin.sizes.index', compact('sizes'));
    }

    /**
     * عرض نموذج إضافة قياس
     */
    public function create()
    {
        return view('admin.sizes.create');
    }

    public function show($uuid) {}

    /**
     * حفظ قياس جديد
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'    => 'required|string|max:255',
        ]);

        $size = new Size();
        $size->name   = $validated['name'];
        $size->save();

        return redirect()->back()->with('success', 'تم إضافة القياس بنجاح');
    }

    /**
     * عرض نموذج تعديل القياس
     */
    public function edit($id)
    {
        $size = Size::where('id', $id)->firstOrFail();

        return view('admin.sizes.edit', compact('size'));
    }

    /**
     * تحديث القياس
     */
    public function update(Request $request, $id)
    {
        $size = Size::where('id', $id)->firstOrFail();

        $validated = $request->validate([
            'name'    => 'required|string|max:255',
            'status'  => 'boolean',
        ]);

        $size->name    = $validated['name'];
        $size->status = $request->has('status') === true ? 'active' : 'inactive';

        $size->save();

        return redirect()->back()->with('success', 'تم تحديث القياس بنجاح');
    }
    /**
     * حذف القياس
     */
    public function destroy($id)
    {
        $size = Size::where('id', $id)->firstOrFail();

        $size->delete();

        if (request()->ajax()) {
            return response()->json([
                'success' => true,
                'message' => 'تم حذف القياس بنجاح'
            ]);
        }

        return redirect()->route('admin.sizes.index')->with('success', 'تم حذف القياس بنجاح');
    }

    /**
     * تفريغ جدول Sizes فقط
     */
    public function truncateSizes()
    {
        try {

            DB::statement('SET FOREIGN_KEY_CHECKS=0;');

            DB::table('sizes')->truncate();
            DB::table('product_sizes')->truncate();

            DB::statement('SET FOREIGN_KEY_CHECKS=1;');

            return response()->json([
                'success' => true,
                'message' => 'تم حذف كل القياسات بنجاح',
            ]);

        } catch (\Exception $e) {

            DB::statement('SET FOREIGN_KEY_CHECKS=1;');

            return response()->json([
                'success' => false,
                'message' => 'فشل حذف القياسات: '.$e->getMessage(),
            ]);

        }
    }


    public function addAjax(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255'
        ]);

        $name = trim(strip_tags($request->name));
        
        // تحقق إذا موجود مسبقاً
        $size = Size::where('name', $name)->first();
        if (!$size) {
            $size = Size::create([
                'name' => $name,
            ]);
        }

        // توحيد البيانات
        return response()->json([
            'id' => $size->id,
            'value' => $size->name
        ]);
    }

    //البحث عن حجم وعرضه بصفحة اضافة منتج او تعديله
    public function search(Request $request)
    {
        $query = trim(strip_tags($request->q));

        $sizes = Size::where('name', 'like', "%$query%")
            ->latest()
            ->limit(10)
            ->get(['id', 'name as value']);

        return response()->json($sizes);
    }
}
