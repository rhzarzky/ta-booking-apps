<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class RoleController extends Controller
{
    public function index()
    {
        $roles = Role::with('permissions')->get();
        return response()->json($roles);
    }

    public function store(Request $request)
    {
        $request->validate(['name' => 'required|unique:roles,name']);
        $role = Role::create(['name' => $request->name]);
        return response()->json([
            'message' => 'Role created successfully', 
            'role' => $role
        ], 200);
    }

    public function permissions()
    {
        return response()->json(Permission::all(), 200);
    }

    public function assignPermissions(Request $request, Role $role)
    {
        $request->validate(['permissions' => 'required|array']);

        $permissions = Permission::whereIn('name', $request->permissions)->get();

        $role->syncPermissions($permissions);

        return response()->json([
           'message' => 'Permissions assigned successfully',
            'role' => $role
        ], 200);
    }
}
