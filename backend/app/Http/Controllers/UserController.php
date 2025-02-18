<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index()
    {
        $users = User::with('roles')->get();

        return response()->json([
            'users' => $users->map(function ($user) {
                return [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->roles->pluck('name')->first() ?? 'No Role',
                ];
            })
        ]); 
    }
    public function assignRole(Request $request, $id)
    {
        $request->validate(['role' => 'required|exists:roles,name']);

        $user = User::findOrFail($id);
        $user->syncRoles([$request->role]);

        return response()->json([
            'message' => "Role '{$request->role}' assigned to {$user->name}."
        ], 200);
    }
}
