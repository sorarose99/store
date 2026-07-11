<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Mail\SendOtpMail;
use App\Models\User;
use App\Models\Verification;
use App\Services\InfobipService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\Rules;

class RegisterController extends Controller
{
    /**
     * Display the registration view.
     */
    public function create()
    {
        return view('auth.register');
    }

    /**
     * Send OTP
     */
    public function sendOtp(Request $request)
    {

        $request->validate([
            'register_type' => 'required|in:email,phone,whatsapp',
            'email' => 'nullable|required_if:register_type,email|email',
            'phone' => 'nullable|required_if:register_type,phone,whatsapp|string|max:20',
        ]);

        // تحديد الهدف
        $target = $request->register_type === 'email' ? $request->email : $request->phone;

        $existing = Verification::where('target', $target)->where('updated_at', '>', now()->subSeconds(60))->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => __('messages.wait_before_resend'),
            ], 429);
        }

        // توليد رمز من 6 أرقام
        $otp = random_int(100000, 999999);

        // تخزين الرمز
        Verification::updateOrCreate(
            [
                'target' => $target,
            ],
            [
                'type' => $request->register_type,
                'code' => Hash::make($otp),
                'expires_at' => now()->addMinutes(5),
            ]
        );

        /**
         * Email
         */
        if ($request->register_type === 'email') {
            Mail::to($target)->send(new SendOtpMail($otp));
        } else {
            // SEND SMS OR WHATSAPP HERE
            $infobip = app(InfobipService::class);
            $message = __('user_interface.your_otp_code').' : '.$otp;
            match ($request->register_type) {
                'phone' => $infobip->sendSMS($target, $otp, $message),
                'whatsapp' => $infobip->sendWhatsApp($target, $otp, $message),
            };
        }

        return response()->json([
            'success' => true,
            'message' => __('messages.otp_sent_successfully'),
        ]);
    }

    /**
     * Register User
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'register_type' => ['required', 'in:email,phone,whatsapp'],
            'first_name' => ['required', 'string', 'max:255'],
            'last_name' => ['required', 'string', 'max:255'],
            'email' => ['exclude_unless:register_type,email', 'required', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['exclude_unless:register_type,phone,whatsapp', 'required', 'string', 'max:20', 'unique:users,phone'],
            'password' => ['required', 'confirmed', Rules\Password::min(8)],
            'otp' => ['required', 'digits:6'],
            'terms' => ['accepted'],
        ]);

        /**
         * تحديد الهدف
         */
        $target = $validated['register_type'] === 'email' ? $validated['email'] : $validated['phone'];

        /**
         * جلب رمز التحقق
         */
        $verification = Verification::where('target', $target)->where('type', $validated['register_type'])->latest()->first();

        /**
         * التحقق من وجود الرمز
         */
        if (! $verification) {
            return back()->withErrors(['otp' => __('messages.otp_not_sent')])->withInput();
        }

        /**
         * التحقق من انتهاء الصلاحية
         */
        if ($verification->expires_at->isPast()) {
            return back()->withErrors(['otp' => __('messages.otp_expired')])->withInput();
        }

        /**
         * التحقق من صحة الرمز
         */
        if (! Hash::check($validated['otp'], $verification->code)) {

            return back()->withErrors(['otp' => __('messages.invalid_otp')])->withInput();
        }

        /**
         * إنشاء الحساب
         */
        $user = User::create([
            'first_name' => $validated['first_name'],
            'last_name' => $validated['last_name'],
            'email' => $validated['email'] ?? null,
            'phone' => $validated['phone'] ?? null,
            'register_type' => $validated['register_type'],
            'password' => Hash::make($validated['password']),
            'terms_accepted_at' => now(),
            'verified_at' => now(),
        ]);

        /**
         * حذف رموز التحقق القديمة
         */
        Verification::where('target', $target)->delete();

        /**
         * تسجيل الدخول
         */
        Auth::login($user);

        return redirect()->route('home');
    }
}
