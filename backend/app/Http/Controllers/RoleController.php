<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class RoleController extends Controller
{
    public function index()
    {
        $roles = Role::select('id', 'name')->get();
        return response()->json($roles);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|unique:roles,name'
        ]);

        if (Role::where('name',  $validated['name'])->exists()) {
            return response()->json([
                'status' => 'error',
               'message' => 'Role already exists',
            ], 400);
        }
        
        $role = Role::create(['name' => $validated['name']]);

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
