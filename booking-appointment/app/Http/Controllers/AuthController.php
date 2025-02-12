<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

use Exception;

class AuthController extends Controller
{
    public function register(Request $request)
   {
        $dataValidation = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'required|string|exists:roles,name',
            'status' => 'nullable|string|in:active,inactive',
        ]);

        if ($dataValidation->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $dataValidation->errors()
            ], 401);
        }

        try {
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'role' => $request->role,
                'status' => $request->status ?? 'active',
            ]);

            return response()->json([
               'status' =>'success',
               'message' => 'User registered successfully',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                    'status' => $user->status,
                ],
            ], 201);
        } catch (Exception $e) {
            Log::error('Registration Error: ' . $e->getMessage());
            return response()->json([
                'error' => 'An error occurred while registering the user',
            ], 500);
        }
    } 
}
