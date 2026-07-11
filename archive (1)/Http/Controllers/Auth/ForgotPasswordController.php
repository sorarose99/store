<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Mail\SendOtpMail;
use App\Models\User;
use App\Models\Verification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\Rules;

class ForgotPasswordController extends Controller
{
    /**
     * Display the registration view.
     */
    public function create()
    {
        return view('auth.reset-password');
    }

    /**
     * Send OTP
     */
    public function sendResetOtp(Request $request)
    {
        $request->validate([
            'target' => 'required', // email أو phone
        ]);

        $target = $request->target;
        $existing = Verification::where('target', $target)->where('updated_at', '>', now()->subSeconds(60))->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => __('messages.wait_before_resend'),
            ], 429);
        }

        // تحقق أن المستخدم موجود
        if (filter_var($target, FILTER_VALIDATE_EMAIL)) {
            $user = User::where('email', $target)->first();
        } else {
            $user = User::where('phone', $target)->first();
        }
        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => __('messages.user_not_found'),
            ], 404);
        }

        $otp = random_int(100000, 999999);

        Verification::updateOrCreate(
            [
                'target' => $target,
                'type' => $user->register_type,
            ],
            [
                'code' => Hash::make($otp),
                'expires_at' => now()->addMinutes(5),
            ]
        );

        if ($user->register_type === 'email') {
            Mail::to($target)->send(new SendOtpMail($otp));
        } else {
            // SMS / WhatsApp
        }

        return response()->json([
            'success' => true,
            'message' => __('messages.otp_sent_successfully'),
        ]);
    }

    /**
     * Reset password
     */
    public function store(Request $request)
    {
        $request->validate([
            'target' => 'required',
            'otp' => 'required|digits:6',
            'password' => ['required', 'confirmed', Rules\Password::min(8)],
        ]);

        $target = $request->target;

        $verification = Verification::where('target', $target)->latest()->first();

        if (! $verification) {
            return back()->withErrors(['otp' => __('messages.otp_not_sent')])->withInput();
        }

        if ($verification->expires_at->isPast()) {
            return back()->withErrors(['otp' => __('messages.otp_expired')])->withInput();
        }

        if (! Hash::check($request->otp, $verification->code)) {
            return back()->withErrors(['otp' => __('messages.invalid_otp')])->withInput();
        }

        if (filter_var($target, FILTER_VALIDATE_EMAIL)) {
            $user = User::where('email', $target)->first();
        } else {
            $user = User::where('phone', $target)->first();
        }

        if (! $user) {
            return back()->withErrors(['target' => __('messages.user_not_found')]);
        }

        $user->update([
            'password' => Hash::make($request->password),
        ]);

        Verification::where('target', $target)->delete();

        return redirect()->route('login')->with('success', __('messages.password_changed_successfully'));
    }
}
