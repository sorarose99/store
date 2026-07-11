<?php

namespace App\Http\Controllers;

use App\Models\ContactMessage;
use Illuminate\Http\Request;

class PageController extends Controller
{
    /**
     * عرض صفحة من نحن
     */
    public function about()
    {
        
        return view('pages.about');
    }

    /**
     * عرض صفحة تواصل معنا
     */
    public function contact()
    {
        return view('pages.contact');
    }

    /**
     * معالجة نموذج التواصل
     */
    public function sendContact(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'phone' => 'nullable|string|max:20',
            'type' => 'nullable|string|max:100',
            'subject' => 'required|string|max:255',
            'message' => 'required|string',
        ]);

        ContactMessage::create($data);

        return back()->with('success', __('messages.contact_message_success'));
    }

    /**
     * عرض صفحة الشروط والأحكام
     */
    public function terms()
    {
        return view('pages.terms');
    }

    /**
     * عرض صفحة سياسة الخصوصية
     */
    public function privacy()
    {
        return view('pages.privacy');
    }

    /**
     * عرض صفحة سياسات الاستبدال و الاسترجاع
     */
    public function returnPolicy()
    {
        return view('pages.return-policy');
    }

    /**
     * عرض صفحة الشكاوى و اﻹقتراحات
     */
    public function feedback()
    {
        return view('pages.feedback');
    }

    /**
     * عرض صفحة التراخيص
     */
    public function licenses()
    {
        return view('pages.licenses');
    }

    /**
     * عرض صفحة خطوات حذف الحساب للمستخدمين
     */
    public function deleteAccount()
    {
        return view('pages.delete-account');
    }

    
}
