<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class RoleController extends Controller
{
    public function showRole()
    {
        $roles = Role::select('id', 'name')->get();
        return response()->json($roles);
    }

    public function storeRole(Request $request)
    {
        try{
            $validated = $request->validate([
                'name' => 'required|unique:roles,name'
            ]);
            
            $role = Role::create(['name' => $validated['name']]);

            return response()->json([
                'message' => 'Role created successfully', 
                'role' => [
                    'id' => $role->id,
                    'name' => $role->name,
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
}
