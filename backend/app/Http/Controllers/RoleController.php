<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class RoleController extends Controller
{
    public function showRole()
    {
        $roles = Role::with('permissions:id,name')->select('id', 'name')->get();
        $roles = $roles->map(function ($role) {
            return [
                'id' => $role->id,
                'name' => $role->name,
                'permissions' => $role->permissions->pluck('name')
            ];
        });
        return response()->json($roles);
    }

    public function storeRole(Request $request)
    {
        try {
            $validated = $request->validate([
                'name' => 'required|unique:roles,name',
                'permissions' => 'nullable|array',
                'permissions.*' => 'string|exists:permissions,name'
            ]);

            $role = Role::create(['name' => $validated['name']]);

            if (!empty($validated['permissions'])) {
                $permissions = Permission::whereIn('name', $validated['permissions'])->get();
                $role->syncPermissions($permissions);
            }

            $role->load('permissions:id,name');

            return response()->json([
                'message' => 'Role created successfully',
                'role' => [
                    'id' => $role->id,
                    'name' => $role->name,
                    'permissions' => $role->permissions->pluck('name')
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function showPermission()
    {
        return response()->json(Permission::select('id', 'name')->get());
    }

    public function assignPermissionRole(Request $request, $id)
    {
        try {
            $validated =  $request->validate([
                'permissions' => 'required|array',
                'permissions.*' => 'string|exists:permissions,name'
            ]);

            $role = Role::findOrFail($id);
            if (!$role) {
                return response()->json(['message' => 'Role not found'], 404);
            }

            $permissions = Permission::whereIn('name', $validated['permissions'])->get();
            $role->syncPermissions($permissions);

            return response()->json(['message' => 'Permission assigned successfully'], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function editRole(Request $request, $id)
    {
        try {
            $validated = $request->validate([
                'name' => 'sometimes|unique:roles,name,' . $id,
                'permissions' => 'nullable|array',
                'permissions.*' => 'string|exists:permissions,name'
            ]);

            $role = Role::findOrFail($id);

            // Update name if provided
            if (isset($validated['name'])) {
                $role->name = $validated['name'];
                $role->save();
            }

            // Sync permissions if provided
            if (isset($validated['permissions'])) {
                $role->syncPermissions($validated['permissions']);
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Role updated successfully',
                'role' => [
                    'id' => $role->id,
                    'name' => $role->name,
                    'permissions' => $role->permissions->pluck('name')
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function deleteRole($id)
    {
        try {
            $role = Role::findOrFail($id);
            $role->delete();

            return response()->json(['message' => 'Role deleted successfully'], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
