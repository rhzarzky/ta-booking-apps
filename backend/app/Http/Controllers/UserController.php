<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class UserController extends Controller
{
    public function showUser()
    {
        $users = User::with('roles')->get();

        return response()->json([
            'status' => 'success',
            'users' => $users->map(function ($user) {
                return [
                    'id' => $user->id,
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
        } catch (\Exception $e) {
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
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
