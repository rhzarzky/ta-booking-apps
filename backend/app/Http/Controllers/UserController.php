<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;
use Illuminate\Database\Eloquent\ModelNotFoundException;

use Exception;

class UserController extends Controller
{
    public function showAllUser()
    {
        $users = User::with(['roles', 'permissions'])->get();

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
    public function getUserById($id)
    {
        $user = User::find($id);

        if(!$user){
            return response()->json([
                'status' => 'error',
                'message' => 'User not found',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'User found',
            'user' => [
                'id' => $user->id,
                'image' => $user->image ? asset('storage/' . $user->image) : null,
                'name' => $user->name,
                'email' => $user->email,
                'status' => $user->status,
                'role' => $user->roles->pluck('name')->toArray(),  
                'permission' => $user->permissions->pluck('name')->toArray(), 
            ],
        ], 200);
    }
    public function editUserById(Request $request, $id)
    {

        $dataValidation = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|string|email|max:255|unique:users,email,' . $id,
            'role' => 'nullable|string|max:50',
            'password' => 'sometimes|string|min:8|confirmed',
            'status' => 'sometimes|in:Active,Inactive',
            'permissions' => 'nullable|array', 
            'permissions.*' => 'string|exists:permissions,name',
        ]);

        if ($dataValidation->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $dataValidation->errors(),
            ], 422);
        }

        try {
            $user = User::findOrFail($id);

            if ($user->hasRole('admin')) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Admin cannot be edited.',
                ], 403);
            }

            if ($request->has('name')) {
                $user->name = $request->name;
            }

            if ($request->has('email')) {
                $user->email = $request->email;
            }

            if ($request->has('password')) {
                $user->password = Hash::make($request->password);
            }

            if ($request->has('status')) {
                $user->status = $request->status;
            }

            if ($request->has('role')) {
                $user->syncRoles([$request->role]); // Sync role (removes old roles and assigns the new one)
            }
            
            if ($request->has('permissions')) {
                $user->syncPermissions($request->permissions); 
            }

            $user->save();
            $roles = $user->getRoleNames();
            $permissions = $user->getPermissionNames();

            return response()->json([
                'status' => 'success',
                'message' => 'User profile updated successfully',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'status' => $user->status,
                    'role' => $roles,
                    'permissions' => $permissions,

                ],
            ], 200);
        } catch (ModelNotFoundException $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'User not found',
            ], 404);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while updating the user profile',
            ], 500);
        }
    }
    public function deleteUserById($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'status' => 'error', 
                'message' => 'User not found'
            ], 404);
        }
        
        // Prevent deletion of the authenticated user
        if (auth()->check() && auth()->id() == $user->id) {
            return response()->json([
                'status' => 'error',
                'message' => 'You cannot delete your own account.',
            ], 403);
        }

        if ($user->hasRole('admin')) {
            return response()->json([
                'status' => 'error',
                'message' => 'Admin cannot be deleted.',
            ], 403);
        }

        $user->delete();

        return response()->json([
            'status' => 'success', 
            'message' => 'User deleted successfully'
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

        $messages = [
            'password.regex' => 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character.',
        ];

        $validate = Validator::make($request->all(), [
            'image' => 'nullable|image|mimes:jpg,jpeg,png,gif|max:2048',
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|string|email|max:255|unique:users,email,' . $user->id,
            'password' => [
                'sometimes',
                'required',
                'string',
                'min:8',
                'confirmed',
                'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*#?&^])[A-Za-z\d@$!%*#?&^]{8,}$/'
            ],
            'current_password' => 'required_with:password|string',
        ],$messages);

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
                $path = $request->file('image')->store('profile_images', 'public');
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
    public function createUser(Request $request)
    {
        $validate = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'nullable|string|exists:roles,name',
            'status' => 'nullable|in:Active,Inactive',
        ]);

        if ($validate->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $validate->errors(),
            ], 422);
        }

        try {
            $user = new User();
            $user->name = $request->name;
            $user->email = $request->email;
            $user->password = Hash::make($request->password);
            $user->status = $request->status ?? 'Active';
            $user->save();

            if ($request->has('role')) {
                $user->assignRole($request->role);
            }

            return response()->json([
                'status' => 'success',
                'message' => 'User created successfully',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->getRoleNames(),
                    'status' => $user->status,                   
                ],
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while creating the user',
            ], 500);
        }
    }
}
