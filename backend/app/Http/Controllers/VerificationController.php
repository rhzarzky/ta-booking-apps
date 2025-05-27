<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\PasswordReset;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\URL;

class VerificationController extends Controller
{
    public function verify(Request $request, $id, $hash)
    {
        if (!URL::hasValidSignature($request)) {
            return response()->json(['status' => 'error', 'message' => 'Invalid or expired verification link.'], 403);
        }

        $user = User::findOrFail($id);

        if (sha1($user->email) !== $hash) {
            return response()->json(['status' => 'error', 'message' => 'Invalid hash.'], 403);
        }

        if ($user->status === 'Active') {
            return response()->json(['status' => 'info', 'message' => 'Email already verified.'], 200);
        }

        $user->status = 'Active';
        $user->email_verified_at = now();
        $user->save();

        return redirect(env('APP_FRONTEND_URL') . '/login');
    }

    public function sendOtp(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $user = User::where('email', $request->email)->first();
        if (!$user) {
            return response()->json(['message' => 'Email not found'], 404);
        }

        $otp = rand(100000, 999999);

        PasswordReset::updateOrCreate(
            ['email' => $request->email],
            [
                'otp' => $otp,
                'expires_at' => now()->addMinutes(10),
                'is_verified' => false,
            ]
        );

        Mail::raw("Your OTP is: $otp", function ($message) use ($request) {
            $message->to($request->email)->subject('Reset Password OTP');
        });

        return response()->json(['message' => 'OTP sent']);
    }

    // Verifikasi OTP
    public function verifyOtp(Request $request)
    {
        $request->validate(['otp' => 'required']);

        $reset = PasswordReset::where('otp', $request->otp)
            ->where('expires_at', '>', now())
            ->first();

        if (!$reset) {
            return response()->json(['message' => 'Invalid or expired OTP'], 400);
        }

        $reset->is_verified = true;
        $reset->save();

        return response()->json(['message' => 'OTP verified']);
    }

    // Reset password setelah OTP diverifikasi
    public function resetPassword(Request $request)
    {
        $request->validate([
            'password' => 'required|min:6|confirmed'
        ]);

        $reset = PasswordReset::where('is_verified', true)
            ->where('expires_at', '>', now())
            ->latest()
            ->first();

        if (!$reset) {
            return response()->json(['message' => 'OTP not verified or expired'], 400);
        }

        $user = User::where('email', $reset->email)->first();
        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        $user->password = Hash::make($request->password);
        $user->save();

        $reset->delete();

        return response()->json(['message' => 'Password reset successful']);
    }

    // Resend OTP (hanya tombol tanpa input baru)
    public function resendOtp(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $user = User::where('email', $request->email)->first();
        if (!$user) {
            return response()->json(['message' => 'Email not found'], 404);
        }

        $otp = rand(100000, 999999);

        PasswordReset::updateOrCreate(
            ['email' => $request->email],
            [
                'otp' => $otp,
                'expires_at' => now()->addMinutes(10),
                'is_verified' => false,
            ]
        );

        Mail::raw("Your new OTP is: $otp", function ($message) use ($request) {
            $message->to($request->email)->subject('Resend OTP');
        });

        return response()->json(['message' => 'OTP resent']);
    }
}
