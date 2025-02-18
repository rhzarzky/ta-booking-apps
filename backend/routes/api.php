<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\{AuthController, RoleController, UserController};
use App\Http\Middleware\JwtMiddleware;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware([JwtMiddleware::class])->group(function () {
    Route::middleware(['role:admin'])->group(function () {
        Route::get('/users', [UserController::class, 'index']);
        Route::post('/roles', [RoleController::class, 'store']);
        Route::get('/roles', [RoleController::class, 'index']);
        Route::post('/roles/{role}/permissions', [RoleController::class, 'assignPermissions']);
        Route::get('/permissions', [RoleController::class, 'permissions']);
        Route::post('/users/{id}/assign-role', [UserController::class, 'assignRole']);
    });
    Route::post('/logout', [AuthController::class, 'logout']);
});
