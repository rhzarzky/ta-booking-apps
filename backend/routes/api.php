<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\{AuthController, RoleController, UserController};
use App\Http\Middleware\JwtMiddleware;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware([JwtMiddleware::class])->group(function () {
    Route::middleware(['auth:sanctum', 'role:admin'])->group(function () {
        Route::post('/roles', [RoleController::class, 'store']);  // Create Role
        Route::get('/roles', [RoleController::class, 'index']);   // List Roles
        Route::post('/roles/{role}/permissions', [RoleController::class, 'assignPermissions']); // Assign Permissions to Role
        Route::get('/permissions', [RoleController::class, 'permissions']); // List All Permissions
        Route::post('/users/{id}/assign-role', [UserController::class, 'assignRole']); // Assign Role to User
    });
});
