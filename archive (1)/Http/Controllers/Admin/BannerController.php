<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Banner;
use App\Services\FileUploadService;

class BannerController extends Controller
{
    public function __construct()
    {
        $this->middleware('check.permission:view_banners')->only(['index', 'show']);
        $this->middleware('check.permission:create_banners')->only(['create', 'store']);
        $this->middleware('check.permission:edit_banners')->only(['edit', 'update']);
        $this->middleware('check.permission:delete_banners')->only(['destroy']);
    }
    
    /**
     * عرض البنرات
     */
    public function index()
    {
        $banners = Banner::latest()->paginate(15);

        return view('admin.banners.index', compact('banners'));
    }

    /**
     * عرض نموذج إضافة البانر
     */
    public function create()
    {
        return view('admin.banners.create');
    }

    /**
     * إضافة بانر
     */
    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'subtitle' => 'nullable|string|max:255',
            'image' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:5120',
            'link' => 'nullable|url',
            'position' => 'required|in:home,products,categories',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'status' => 'nullable|in:active,inactive',
        ]);

        $banner = new Banner();

        $banner->title = $request->title;
        $banner->subtitle = $request->subtitle;
        $banner->link = $request->link;
        $banner->position = $request->position;
        $banner->start_date = $request->start_date;
        $banner->end_date = $request->end_date;
        $banner->status = $request->status ?? 'active';

        if ($request->hasFile('image')) {
            $path = FileUploadService::upload(
                $request->file('image'),
                'uploads/banners',
                ['jpg', 'jpeg', 'png', 'webp']
            );

            $banner->image = $path;
        }

        $banner->save();

        return redirect()->back()->with('success', 'تم إضافة البانر بنجاح');
    }

    /**
     * عرض نموذج تعديل البنر
     */
    public function edit($id)
    {
        $banner = Banner::findOrFail($id);

        return view('admin.banners.edit', compact('banner'));
    }
    /**
     * تحديث بانر
     */
    public function update(Request $request, Banner $banner)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'subtitle' => 'nullable|string|max:255',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:5120',
            'link' => 'nullable|url',
            'position' => 'required|in:home,products,categories',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'status' => 'required|in:active,inactive',
        ]);

        $banner->title = $request->title;
        $banner->subtitle = $request->subtitle;
        $banner->link = $request->link;
        $banner->position = $request->position;
        $banner->start_date = $request->start_date;
        $banner->end_date = $request->end_date;
        $banner->status = $request->status;

        // image optional
        if ($request->hasFile('image')) {
            $path = FileUploadService::upload(
                $request->file('image'),
                'uploads/banners',
                ['jpg', 'jpeg', 'png', 'webp'],
                $banner->image
            );

            $banner->image = $path;
        }

        $banner->save();

        return redirect()->route('admin.banners.index')
            ->with('success', 'تم تحديث البانر بنجاح');
    }

    /**
     * حذف بانر
     */
    public function destroy($id)
    {
        $banner = Banner::findOrFail($id);

        if ($banner->image) {
            FileUploadService::delete($banner->image);
        }

        $banner->delete();
        if (request()->ajax()) {
            return response()->json([
                'success' => true,
                'message' => 'تم حذف البانر بنجاح'
            ]);
        }
    }
}
