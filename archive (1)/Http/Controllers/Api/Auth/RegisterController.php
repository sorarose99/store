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

class RegisterController extends Controller
{
    /**
     * Send OTP (API)
     */
    public function sendOtp(Request $request)
    {
        $request->validate([
            'register_type' => 'required|in:email,phone,whatsapp',
            'email' => 'nullable|required_if:register_type,email|email',
            'phone' => 'nullable|required_if:register_type,phone,whatsapp|string|max:20',
        ]);

        $target = $request->register_type === 'email'
            ? $request->email
            : $request->phone;

        $existing = Verification::where('target', $target)
            ->where('updated_at', '>', now()->subSeconds(60))
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => __('messages.wait_before_resend'),
            ], 429);
        }

        $otp = random_int(100000, 999999);

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

        if ($request->register_type === 'email') {
            Mail::to($target)->send(new SendOtpMail($otp));
        } else {
            // SMS / WhatsApp integration
        }

        return response()->json([
            'success' => true,
            'message' => __('messages.otp_sent_successfully'),
        ]);
    }

    /**
     * Register User (API + Sanctum Token)
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

        $target = $validated['register_type'] === 'email'
            ? $validated['email']
            : $validated['phone'];

        $verification = Verification::where('target', $target)
            ->where('type', $validated['register_type'])
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

        if (! Hash::check($validated['otp'], $verification->code)) {
            return response()->json([
                'success' => false,
                'message' => __('messages.invalid_otp'),
            ], 422);
        }

        /**
         * Create user
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
         * delete OTPs
         */
        Verification::where('target', $target)->delete();

        /**
         * Sanctum token
         */
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Account created successfully',
            'user' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }
}
