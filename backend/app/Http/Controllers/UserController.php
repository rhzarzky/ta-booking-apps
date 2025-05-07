<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;

use Exception;

class UserController extends Controller
{
    public function showAllUser()
    {
        $users = User::with('roles')->get();

        return response()->json([
            'status' => 'success',
            'users' => $users->map(function ($user) {
                return [
                    'id' => $user->id,
                    'image' => $user->image ? asset('storage/' . $user->image) : null,
                    'name' => $user->name,
                    'email' => $user->email,
                    'status' => $user->status,
                    'role' => $user->roles->pluck('name')->toArray(),  
                    'permission' => $user->permissions->pluck('name')->toArray(), 
                ];
            }),
        ], 200);
    }
    public function assignRole(Request $request, $id)
    {
        try {
            $request->validate([
                'role' => 'required|exists:roles,name'
            ]);

            $user = User::findOrFail($id);

            $role = Role::where('name', $request->role)->first();

            // Sync role (removes old roles and assigns the new one)
            $user->syncRoles([$role->name]);

            return response()->json([
                'status' => 'success',
                'message' => "Role assigned successfully.",
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $role->name
                ]
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
    public function assignPermission(Request $request, $id)
    {
        try{
            $request->validate([
                'permissions' => 'required|array',
                'permissions.*' => 'string|exists:permissions,name'
            ]);

            $user = User::findOrFail($id);

            $permissions = Permission::whereIn('name', $request->permissions)->get();

            // Assign permissions to user
            $user->syncPermissions($permissions);

            return response()->json([
                'status' => 'success',
                'message' => 'Permissions assigned successfully',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'permission' => $user->permissions->pluck('name')
                ]
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
    public function userProfile()
    {
        $user = Auth::user();

        return response()->json([
            'status' => 'success',
            'user' => [
                'id' => $user->id,
                'image' => $user->image ? asset('storage/' . $user->image) : null,
                'name' => $user->name,
                'status' => $user->status,
                'email' => $user->email,
                'role' => $user->roles->pluck('name')->toArray(),
                'permissions' => $user->permissions->pluck('name')->toArray(), 
            ],
        ], 200);
    }
    public function updateProfile(Request $request)
    {
        $user = Auth::user();

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthenticated',
            ], 401);
        }

        $validate = Validator::make($request->all(), [
            'image' => 'nullable|image|mimes:jpg,jpeg,png,gif|max:2048',
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|string|email|max:255|unique:users,email,' . $user->id,
            'password' => 'nullable|string|min:8|confirmed',
            'current_password' => 'required_with:password|string',
        ]);

        if ($validate->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $validate->errors(),
            ], 422);
        }

        try {
            // Handle password update
            if ($request->filled('password')) {
                if (!Hash::check($request->current_password, $user->password)) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'The current password is incorrect',
                    ], 403);
                }
                $user->password = Hash::make($request->password);
            }

            // Update name and email
            if ($request->has('name')) {
                $user->name = $request->name;
            }

            if ($request->has('email')) {
                $user->email = $request->email;
            }

            // Handle image upload
            if ($request->hasFile('image')) {
                $path = $request->file('image')->store('profile', 'public');
                $user->image = $path;
            }

            $user->save();

            return response()->json([
                'status' => 'success',
                'message' => 'Profile updated successfully',
                'user' => [
                    'id' => $user->id,
                    'image' => $user->image ? asset('storage/' . $user->image) : null,
                    'name' => $user->name,
                    'email' => $user->email,
                ],
            ], 200);

        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while updating the profile',
            ], 500);
        }
    }
}
