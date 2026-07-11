<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Setting;
use App\Services\FileUploadService;

class SettingController extends Controller
{
    public function __construct()
    {
        $this->middleware('check.permission:settings');
    }
    /**
     * عرض الإعدادات العامة
     */
    public function index()
    {
        $settings = Setting::where('group', 'store')
            ->pluck('value', 'key')
            ->toArray();

        return view('admin.settings.index', compact('settings'));
    }

    public function update(Request $request)
    {
        $request->validate([
            'store_name' => 'required|string|max:255',
            'store_email' => 'nullable|email',
            'store_phone' => 'nullable|string|max:50',
            'store_address' => 'nullable|string',

            'maintenance_mode' => 'nullable|boolean',
            'maintenance_message' => 'nullable|string',

            'facebook' => 'nullable|url',
            'twitter' => 'nullable|url',
            'instagram' => 'nullable|url',
            'whatsapp' => 'nullable|url',

            'store_logo' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:2048',
        ]);

        $data = $request->except(['_token', 'store_logo']);

        $data['maintenance_mode'] = $request->has('maintenance_mode') ? 1 : 0;

        foreach ($data as $key => $value) {
            Setting::set($key, $value, 'store');
        }

        // رفع الشعار
        if ($request->hasFile('store_logo')) {
            $oldLogo = Setting::get('store_logo');

            $path = FileUploadService::upload(
                $request->file('store_logo'),
                'uploads/settings',
                ['jpg', 'jpeg', 'png', 'webp'],
                $oldLogo,
                'logo'
            );

            Setting::set('store_logo', $path, 'store');
            cache()->forget("setting:store_logo");
        }

        cache()->forget('settings_all');

        return back()->with('success', 'تم حفظ الإعدادات بنجاح');
    }
}
