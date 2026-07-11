<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;

use App\Models\Address;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AddressController extends Controller
{
    /**
     * عرض صفحة عناوين الشحن
     */
    public function index()
    {
        $user = Auth::user();
        $addresses = Address::where('user_id', $user->id)
            ->orderByDesc('is_default')->paginate(15);

        return response()->json([
            'success' => true,
            'addresses' => $addresses,
        ]);
    }

    /**
     * إضافة عنوان جديد
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'full_name' => 'required|string|max:255',
            'phone' => 'nullable|string|max:20',
            'email' => 'nullable|email|max:255',
            'country' => 'required|in:SA,BH,KW,QA,OM,AE',
            'city' => 'required|string|max:255',
            'postal_code' => 'nullable|string|max:20',
            'address' => 'required|string',
            'is_default' => 'nullable|boolean',
        ]);

        $data['country'] = $data['country'] ?? null;

        $data['is_default'] = $request->has('is_default');

        $user_id = Auth::id();

        // أول عنوان يخليه افتراضي
        if (Address::where('user_id', $user_id)->count() == 0) {
            $data['is_default'] = true;
        }

        // إذا اختار افتراضي → نلغي الباقي
        if ($data['is_default']) {
            Address::where('user_id', $user_id)->update(['is_default' => false]);
        }

        $data['user_id'] = $user_id;
        Address::create($data);

        return response()->json([
            'success' => true,
            'message' => __('messages.address_added_successfully')
        ]);
    }

    /**
     * عرض صفحة تحديث العنوان
     */
    public function edit($id)
    {
        $address = Address::findOrFail($id);
        $user = Auth::user();
        // تأكد العنوان يخص المستخدم
        if ($address->user_id !== $user->id) {
            abort(403);
        }

        return response()->json([
            'success' => true,
            'address' => $address,
        ]);
    }

    /**
     * تحديث عنوان
     */
    public function update(Request $request, $id)
    {
        $address = Address::findOrFail($id);
        $user_id = Auth::id();

        // تأكد العنوان يخص المستخدم
        if ($address->user_id !== $user_id) {
            abort(403);
        }

        $data = $request->validate([
            'title' => 'required|string|max:255',
            'full_name' => 'required|string|max:255',
            'phone' => 'nullable|string|max:20',
            'email' => 'nullable|email|max:255',
            'country' => 'required|string|max:255',
            'city' => 'required|string|max:255',
            'postal_code' => 'nullable|string|max:20',
            'address' => 'required|string',
            'is_default' => 'nullable|boolean',
        ]);
        
        $data['country'] = $data['country'] ?? null;

        $data['is_default'] = $request->has('is_default');

        // إذا اختار افتراضي → نلغي باقي العناوين
        if ($data['is_default']) {
            Address::where('user_id', $user_id)
                ->where('id', '!=', $address->id)
                ->update(['is_default' => false]);
        }

        $address->update($data);

        return response()->json([
            'success' => true,
            'message' => __('messages.address_updated_successfully')
        ]);

    }

    /**
     * حذف عنوان
     */
    public function destroy($id)
    {
        $address = Address::findOrFail($id);
        $user_id = Auth::id();

        // تأكد العنوان يخص المستخدم
        if ($address->user_id !== $user_id) {
            abort(403);
        }

        $address->delete();

        return response()->json([
            'success' => true,
            'message' => __('messages.address_deleted_successfully'),
        ]);
    }
}
