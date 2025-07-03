<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\PasswordReset;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Redirect;
use Illuminate\Support\Facades\URL;
use Exception;

class VerificationController extends Controller
{
    public function verify(Request $request, $id, $hash)
    {
        if (!URL::hasValidSignature($request)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid or expired verification link.',
            ], 403);
        }

        $user = User::findOrFail($id);

        if (sha1($user->email) !== $hash) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid verification hash.',
            ], 403);
        }

        if ($user->status === 'Active') {
            return response()->json([
                'status' => 'info',
                'message' => 'Email already verified.',
            ], 200);
        }

        $user->status = 'Active';
        $user->email_verified_at = now();
        $user->save();

        // Redirect to the frontend URL after successful verification
        return Redirect::away(env('FRONTEND_URL') . '/email-verified');
    }

    public function sendOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::where('email', $request->email)->first();
        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'Email not found.',
            ], 404);
        }

        try {
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

            return response()->json([
                'status' => 'success',
                'message' => 'OTP has been sent to your email.',
            ]);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to send OTP.',
            ], 500);
        }
    }

    public function verifyOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'otp' => 'required|digits:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $reset = PasswordReset::where('otp', $request->otp)
            ->where('expires_at', '>', now())
            ->first();

        if (!$reset) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid or expired OTP.',
            ], 400);
        }

        $reset->is_verified = true;
        $reset->save();

        return response()->json([
            'status' => 'success',
            'message' => 'OTP verified successfully.',
        ]);
    }

    public function resetPassword(Request $request)
    {
        $messages = [
            'password.regex' => 'Password must contain at least one uppercase, lowercase, number, and special character.',
        ];

        $validator = Validator::make($request->all(), [
            'password' => [
                'required',
                'string',
                'min:8',
                'confirmed',
                'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*#?&^])[A-Za-z\d@$!%*#?&^]{8,}$/',
            ],
        ], $messages);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $reset = PasswordReset::where('is_verified', true)
            ->where('expires_at', '>', now())
            ->latest()
            ->first();

        if (!$reset) {
            return response()->json([
                'status' => 'error',
                'message' => 'OTP has not been verified or has expired.',
            ], 400);
        }

        $user = User::where('email', $reset->email)->first();
        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'User not found.',
            ], 404);
        }

        try {
            $user->password = Hash::make($request->password);
            $user->save();

            $reset->delete();

            return response()->json([
                'status' => 'success',
                'message' => 'Password reset successfully.',
            ]);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred during password reset.',
            ], 500);
        }
    }

    public function resendOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::where('email', $request->email)->first();
        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'Email not found.',
            ], 404);
        }

        try {
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
                $message->to($request->email)->subject('New OTP Request');
            });

            return response()->json([
                'status' => 'success',
                'message' => 'New OTP sent successfully.',
            ]);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to resend OTP.',
            ], 500);
        }
    }
}
