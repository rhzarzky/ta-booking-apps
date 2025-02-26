<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;
Use Illuminate\Http\JsonResponse;

use Exception;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $dataValidation = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'nullable|string|exists:roles,name', 
            'permissions' => 'nullable|array',
            'permissions.*' => 'string|exists:permissions,name',
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
                'status' => $request->status ?? 'active',
            ]);

            $roleName = $request->role ?? 'user';
            $role = Role::where('name', $roleName)->first();

            if ($role) {
                $user->assignRole($role);
            }

            if ($request->has('permissions')) {
                $permissions = Permission::whereIn('name', $request->permissions)->get();
                $user->givePermissionTo($permissions);
            }

            $token = JWTAuth::fromUser($user);

            return response()->json([
                'status' => 'success',
                'message' => 'User registered successfully',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->getRoleNames(),
                    'status' => $user->status,
                ],
                'token' => $token
            ], 201);

        } catch (Exception $e) {
            Log::error('Registration Error: ' . $e->getMessage());
            return response()->json([
                'error' => 'An error occurred while registering the user',
            ], 500);
        }
    } 

    public function login(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required']
        ]);

        try {
            $user = User::where('email', $credentials['email'])->first();

            if (!$user) {
                return response()->json([
                    'status' => 'error',
                    'error' => 'Invalid credentials',
                ], 401);
            }

            if (!Hash::check($credentials['password'], $user->password)) {
                return response()->json([
                    'status' => 'error',
                    'error' => 'Invalid credentials',
                ], 401);
            }

            if ($user->status !== 'active') {
                return response()->json([
                    'status' => 'error',
                    'error' => 'Your account is inactive. Please contact support.',
                ], 403);
            }

            $token = JWTAuth::fromUser($user);

            return response()->json([
                'status' => 'success',
                'message' => 'Login successful',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->getRoleNames(),
                    'status' => $user->status,
                ],
                'token' => $token,
            ], 200);

        } catch (JWTException $e) {
            return response()->json([
                'status' => 'error',
                'error' => 'Could not create token',
            ], 500);
        }
    } 
    
    public function logout(Request $request): JsonResponse
    {
        try {
            JWTAuth::invalidate(JWTAuth::getToken());
            return response()->json([
               'status' => 'success',
               'message' => 'Logged out successfully',
            ], 200);
        } catch (JWTException $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Could not log out',
            ], 500);
        }
    }
}
