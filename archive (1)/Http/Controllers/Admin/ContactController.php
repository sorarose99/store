<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ContactMessage;

class ContactController extends Controller
{
    public function __construct()
    {
        $this->middleware('check.permission:contact_messages');
    }

    /**
     * عرض رسائل استفسارات العملاء
     */
    public function index()
    {
        $contact_messages = ContactMessage::latest()->paginate(15);

        return view('admin.contact_messages.index', compact('contact_messages'));
    }

    /**
     * عرض تفاصيل رسالة محددة
     */
    public function show($id)
    {
        $contact_message = ContactMessage::where('id', $id)->firstOrFail();
        if (!$contact_message->is_read) {
            $contact_message->update([
                'is_read' => true,
                'read_at' => now()
            ]);
        }
        return view('admin.contact_messages.show', compact('contact_message'));
    }

    /**
     * حذف رسالة محددة
     */
    public function destroy($id)
    {
        $contact_message = ContactMessage::where('id', $id)->firstOrFail();

        $contact_message->delete();

        if (request()->ajax()) {
            return response()->json([
                'success' => true,
                'message' => 'تم حذف الرسالة بنجاح'
            ]);
        }
    }
}
