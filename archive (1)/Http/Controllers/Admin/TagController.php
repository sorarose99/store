<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Tag;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class TagController extends Controller
{
    public function __construct()
    {
        $this->middleware('check.permission:view_tags')->only(['index', 'show']);
        $this->middleware('check.permission:create_tags')->only(['create', 'store']);
        $this->middleware('check.permission:edit_tags')->only(['edit', 'update']);
        $this->middleware('check.permission:delete_tags')->only(['destroy']);
    }

    /**
     * عرض قائمة الكلمات الدلالية
     */
    public function index(Request $request)
    {
        $tags = Tag::query()
            ->when($request->search, function ($q) use ($request) {
                $q->where('name', 'like', '%'.$request->search.'%');
            })
            ->withCount('products')
            ->latest()
            ->paginate(15)
            ->withQueryString();

        return view('admin.tags.index', compact('tags'));
    }

    /**
     * عرض نموذج إضافة كلمة دلالية
     */
    public function create()
    {
        return view('admin.tags.create');
    }

    /**
     * حفظ كلمة دلالية جديد
     */
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $tag = new Tag;
        $tag->name = $request->name;

        $tag->save();

        return redirect()->route('admin.tags.index')->with('success', 'تم إضافة الكلمة بنجاح');
    }

    /**
     * عرض تفاصيل الكلمة الدلالية
     */
    public function show($id)
    {
        //
    }

    /**
     * عرض نموذج تعديل كلمة دلالية
     */
    public function edit($id)
    {
        $tag = Tag::findOrFail($id);

        return view('admin.tags.edit', compact('tag'));
    }

    /**
     * تحديث الكلمة الدلالية
     */
    public function update(Request $request, $id)
    {
        $tag = Tag::findOrFail($id);

        $request->validate([
            'name' => 'required|string|max:255',
            'status' => 'boolean',
        ]);

        $tag->name = $request->name;
        $tag->status = $request->has('status') === true ? 'active' : 'inactive';

        $tag->save();

        return redirect()->route('admin.tags.index')->with('success', 'تم تحديث الكلمة الدلالية بنجاح');
    }

    /**
     * حذف الكلمة الدلالية
     */
    public function destroy($id)
    {
        $tag = Tag::findOrFail($id);

        // حذف
        $tag->delete();

        if (request()->ajax()) {
            return response()->json([
                'success' => true,
                'message' => 'تم حذف الكلمة الدلالية بنجاح',
            ]);
        }

        return redirect()->route('admin.tags.index')
            ->with('success', 'تم حذف الكلمة الدلالية بنجاح');
    }

    /**
     * تفريغ جدول tags فقط
     */
    public function truncateTags()
    {
        try {

            DB::statement('SET FOREIGN_KEY_CHECKS=0;');

            DB::table('tags')->truncate();
            DB::table('product_tags')->truncate();

            DB::statement('SET FOREIGN_KEY_CHECKS=1;');

            return response()->json([
                'success' => true,
                'message' => 'تم حذف كل الكلمات الدلالية بنجاح',
            ]);

        } catch (\Exception $e) {

            DB::statement('SET FOREIGN_KEY_CHECKS=1;');

            return response()->json([
                'success' => false,
                'message' => 'فشل حذف الكلمات الدلالية: '.$e->getMessage(),
            ]);

        }
    }

    public function addAjax(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $name = trim(strip_tags($request->name));
        $slug = Str::slug($name);

        // تحقق إذا موجود مسبقاً
        $tag = Tag::where('slug', $slug)->first();
        if (! $tag) {
            $tag = Tag::create([
                'name' => $name,
                'slug' => $slug,
            ]);
        }

        // توحيد البيانات
        return response()->json([
            'id' => $tag->id,
            'value' => $tag->name,
        ]);
    }

    // Show suggestion for tag search
    public function search(Request $request)
    {
        $query = trim(strip_tags($request->q));

        $tags = Tag::where('name', 'like', "%$query%")
            ->orderBy('count', 'desc')
            ->limit(10)
            ->get(['id', 'name as value']);

        return response()->json($tags);
    }
}
