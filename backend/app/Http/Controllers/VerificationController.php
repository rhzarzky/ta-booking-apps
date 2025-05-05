<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\URL;

class VerificationController extends Controller
{
    public function verify(Request $request, $id, $hash)
    {
        if (! URL::hasValidSignature($request)) {
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

        return response()->json([
            'status' => 'success',
            'message' => 'Your email has been successfully verified! You can now log in to your account.',
            'redirect_to' => url('/login'),
        ], 200);
    }
}

