<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Color;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ColorController extends Controller
{
    public function __construct()
    {
        $this->middleware('check.permission:view_colors')->only(['index', 'show']);
        $this->middleware('check.permission:create_colors')->only(['create', 'store']);
        $this->middleware('check.permission:edit_colors')->only(['edit', 'update']);
        $this->middleware('check.permission:delete_colors')->only(['destroy']);
    }

    /**
     * عرض قائمة الالوان
     */
    public function index(Request $request)
    {
        $colors = Color::query()
            ->when($request->search, function ($q) use ($request) {
                $q->where('name', 'like', '%'.$request->search.'%');
            })
            ->latest()
            ->paginate(15)
            ->withQueryString();

        return view('admin.colors.index', compact('colors'));
    }

    /**
     * عرض نموذج إضافة لون
     */
    public function create()
    {
        return view('admin.colors.create');
    }

    public function show($uuid) {}

    /**
     * حفظ لون جديد
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $color = new Color;
        $color->name = $validated['name'];
        $color->save();

        return redirect()->route('admin.colors.index')->with('success', 'تم إضافة اللون بنجاح');
    }

    /**
     * عرض نموذج تعديل اللون
     */
    public function edit($id)
    {
        $color = Color::where('id', $id)->firstOrFail();

        return view('admin.colors.edit', compact('color'));
    }

    /**
     * تحديث اللون
     */
    public function update(Request $request, $id)
    {
        $color = Color::where('id', $id)->firstOrFail();

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'status' => 'boolean',
        ]);

        $color->name = $validated['name'];
        $color->status = $request->has('status') === true ? 'active' : 'inactive';

        $color->save();

        return redirect()->route('admin.colors.index')->with('success', 'تم تحديث اللون بنجاح');
    }

    /**
     * حذف اللون
     */
    public function destroy($id)
    {
        $color = Color::where('id', $id)->firstOrFail();

        $color->delete();

        if (request()->ajax()) {
            return response()->json([
                'success' => true,
                'message' => 'تم حذف اللون بنجاح',
            ]);
        }

        return redirect()->route('admin.colors.index')->with('success', 'تم حذف اللون بنجاح');
    }

    /**
     * تفريغ جدول Colors فقط
     */
    public function truncateColors()
    {
        try {

            DB::statement('SET FOREIGN_KEY_CHECKS=0;');

            DB::table('colors')->truncate();

            DB::statement('SET FOREIGN_KEY_CHECKS=1;');

            return response()->json([
                'success' => true,
                'message' => 'تم حذف كل الالوان بنجاح',
            ]);

        } catch (\Exception $e) {

            DB::statement('SET FOREIGN_KEY_CHECKS=1;');

            return response()->json([
                'success' => false,
                'message' => 'فشل حذف الالوان: '.$e->getMessage(),
            ]);

        }
    }

    // البحث عن لون وعرضه بصفحة اضافة منتج او تعديله
    public function addAjax(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $name = trim(strip_tags($request->name));

        // تحقق إذا موجود مسبقاً
        $color = Color::where('name', $name)->first();
        if (! $color) {
            $color = Color::create([
                'name' => $name,
            ]);
        }

        // توحيد البيانات
        return response()->json([
            'id' => $color->id,
            'name' => $color->name,
        ]);
    }

    // البحث عن لون وعرضه بصفحة اضافة منتج او تعديله
    public function search(Request $request)
    {
        $query = trim(strip_tags($request->q));

        $colors = Color::where('name', 'like', "%$query%")
            ->latest()
            ->limit(10)
            ->get(['id', 'name']);

        return response()->json($colors);
    }
}
