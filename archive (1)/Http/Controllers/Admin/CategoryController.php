<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class CategoryController extends Controller
{
    public function __construct()
    {
        $this->middleware('check.permission:view_categories')->only(['index', 'show']);
        $this->middleware('check.permission:create_categories')->only(['create', 'store']);
        $this->middleware('check.permission:edit_categories')->only(['edit', 'update']);
        $this->middleware('check.permission:delete_categories')->only(['destroy']);
    }

    /**
     * عرض قائمة التصنيفات
     */
    public function index(Request $request)
    {
        $categories = Category::query()
            ->whereNull('parent_id') // فقط التصنيفات الأساسية
            ->when($request->search, function ($q) use ($request) {
                $q->where('name', 'like', '%'.$request->search.'%');
            })
            ->withCount([
                'children',    // عدد التصنيفات الفرعية
            ])
            ->latest()
            ->paginate(15)
            ->withQueryString();

        return view('admin.categories.index', compact('categories'));
    }

    /**
     * عرض قائمة التصنيفات الفرعية للتصنيف الاساسي
     */
    public function children(Request $request, $id)
    {
        $parent = Category::select('id', 'name')->findOrFail($id);

        $categories = Category::query()
            ->where('parent_id', $id)
            ->when($request->search, function ($q) use ($request) {
                $q->where('name', 'like', '%'.$request->search.'%');
            })
            ->withCount('products') // عدد المنتجات لكل فرعي
            ->latest()
            ->paginate(15)
            ->withQueryString();

        return view('admin.categories.children', compact('categories', 'parent'));
    }

    /**
     * عرض نموذج إضافة تصنيف
     */
    public function create()
    {
        $categories = Category::whereNull('parent_id')
            ->orderBy('created_at', 'desc')
            ->limit(50)
            ->get();

        return view('admin.categories.create', compact('categories'));
    }

    /**
     * حفظ تصنيف جديد
     */
    public function store(Request $request)
    {
        $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('categories')
                    ->where(fn ($q) => $q->where('parent_id', $request->parent_id)),
            ],
            'parent_id' => 'nullable|exists:categories,id',
            'show_in_home' => 'boolean',
        ], [
            'name.unique' => 'هذا التصنيف موجود مسبقاً داخل نفس القسم',
        ]);

        $category = new Category;
        $category->name = $request->name;
        $category->parent_id = $request->parent_id;
        $category->show_in_home = $request->has('show_in_home');

        $category->save();

        return redirect()->back()->with('success', 'تم إضافة التصنيف بنجاح');
    }

    /**
     * عرض تفاصيل التصنيف
     */
    public function show($id)
    {
        //
    }

    /**
     * عرض نموذج تعديل تصنيف
     */
    public function edit($id)
    {
        $category = Category::findOrFail($id);

        if (is_null($category->parent_id)) {
            $categories = collect(); // فارغ
        } else {
            $categories = Category::whereNull('parent_id')
                ->where('id', '!=', $id)
                ->orderBy('created_at', 'desc')
                ->limit(50)
                ->get();
        }

        return view('admin.categories.edit', compact('category', 'categories'));
    }

    /**
     * تحديث التصنيف
     */
    public function update(Request $request, $id)
    {
        $category = Category::findOrFail($id);

        $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('categories')
                    ->where(fn ($q) => $q->where('parent_id', $request->parent_id))->ignore($id),
            ],
            'parent_id' => 'nullable|exists:categories,id|not_in:'.$id,
            'show_in_home' => 'boolean',
            'status' => 'boolean',
        ], [
            'name.unique' => 'هذا التصنيف موجود مسبقاً داخل نفس القسم',
        ]);

        $category->name = $request->name;
        $category->parent_id = $request->parent_id;
        $category->show_in_home = $request->has('show_in_home');
        $category->status = $request->has('status') === true ? 'active' : 'inactive';

        $category->save();

        return redirect()->back()->with('success', 'تم تحديث التصنيف بنجاح');
    }

    /**
     * حذف التصنيف
     */
    public function destroy($id)
    {
        $category = Category::findOrFail($id);

        // حذف
        $category->delete();

        if (request()->ajax()) {
            return response()->json([
                'success' => true,
                'message' => 'تم حذف التصنيف بنجاح',
            ]);
        }

        return redirect()->route('admin.categories.index')
            ->with('success', 'تم حذف التصنيف بنجاح');
    }

    /**
     * تفريغ جدول categories فقط
     */
    public function truncateCategories()
    {
        try {

            DB::statement('SET FOREIGN_KEY_CHECKS=0;');

            DB::table('categories')->truncate();
            DB::table('product_categories')->truncate();

            DB::statement('SET FOREIGN_KEY_CHECKS=1;');

            return response()->json([
                'success' => true,
                'message' => 'تم حذف كل التصنيفات بنجاح',
            ]);

        } catch (\Exception $e) {

            DB::statement('SET FOREIGN_KEY_CHECKS=1;');

            return response()->json([
                'success' => false,
                'message' => 'فشل حذف التصنيفات: '.$e->getMessage(),
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

        $category = Category::where('slug', $slug)->first();
        if (! $category) {
            $category = Category::create([
                'name' => $name,
                'slug' => $slug,
            ]);
        }

        return response()->json([
            'id' => $category->id,
            'value' => $category->name,
        ]);
    }

    // Show suggestion for category search
    public function search(Request $request)
    {
        $query = trim(strip_tags($request->q));

        $categories = Category::whereNotNull('parent_id')->where('name', 'like', "%$query%")
            ->limit(10)
            ->get(['id', 'name as value']);

        return response()->json($categories);
    }
}
