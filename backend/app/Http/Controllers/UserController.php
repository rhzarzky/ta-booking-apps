<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
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
