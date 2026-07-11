<?php

namespace App\Http\Controllers\Api\Auth;

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
     * Send Reset OTP (API)
     */
    public function sendResetOtp(Request $request)
    {
        $request->validate([
            'target' => 'required', // email or phone
        ]);

        $target = $request->target;

        /**
         * Rate limit
         */
        $existing = Verification::where('target', $target)
            ->where('updated_at', '>', now()->subSeconds(60))
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => __('messages.wait_before_resend'),
            ], 429);
        }

        /**
         * Find user
         */
        $user = filter_var($target, FILTER_VALIDATE_EMAIL)
            ? User::where('email', $target)->first()
            : User::where('phone', $target)->first();

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => __('messages.user_not_found'),
            ], 404);
        }

        /**
         * Generate OTP
         */
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

        /**
         * Send OTP
         */
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
     * Reset Password (API)
     */
    public function resetPassword(Request $request)
    {
        $request->validate([
            'target' => 'required',
            'otp' => 'required|digits:6',
            'password' => ['required', 'confirmed', Rules\Password::min(8)],
        ]);

        $target = $request->target;

        /**
         * Get verification
         */
        $verification = Verification::where('target', $target)
            ->latest()
            ->first();

        if (! $verification) {
            return response()->json([
                'success' => false,
                'message' => __('messages.otp_not_sent'),
            ], 422);
        }

        if ($verification->expires_at->isPast()) {
            return response()->json([
                'success' => false,
                'message' => __('messages.otp_expired'),
            ], 422);
        }

        if (! Hash::check($request->otp, $verification->code)) {
            return response()->json([
                'success' => false,
                'message' => __('messages.invalid_otp'),
            ], 422);
        }

        /**
         * Find user
         */
        $user = filter_var($target, FILTER_VALIDATE_EMAIL)
            ? User::where('email', $target)->first()
            : User::where('phone', $target)->first();

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => __('messages.user_not_found'),
            ], 404);
        }

        /**
         * Update password
         */
        $user->update([
            'password' => Hash::make($request->password),
        ]);

        /**
         * Clean OTP
         */
        Verification::where('target', $target)->delete();

        return response()->json([
            'success' => true,
            'message' => __('messages.password_changed_successfully'),
        ]);
    }
}
