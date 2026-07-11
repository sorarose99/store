<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\InfobipService;

class SmsController extends Controller
{
    protected $sms;

    public function __construct(InfobipService $sms)
    {
        $this->sms = $sms;
    }

    // إشعار عادي
    public function sendNotification(Request $request)
    {
        $request->validate([
            'phone' => ['required', 'string', 'regex:/^\+?[0-9]{10,15}$/'],
            'message' => 'required'
        ]);

        $response = $this->sms->sendSMS($request->phone, $request->message);

        return response()->json($response);
    }

    // إرسال OTP
    public function sendOtp(Request $request)
    {
        $request->validate([
            'phone' => ['required', 'string', 'regex:/^\+?[0-9]{10,15}$/'],
        ]);

        $result = $this->sms->sendOTP($request->phone);

        return response()->json($result);
    }

    // تحقق OTP
    public function verifyOtp(Request $request)
    {
        $request->validate([
            'phone' => ['required', 'string', 'regex:/^\+?[0-9]{10,15}$/'],
            'otp' => ['required', 'digits:6']
        ]);

        $result = $this->sms->verifyOTP(
            $request->phone,
            $request->otp
        );

        return response()->json($result);
    }
}
