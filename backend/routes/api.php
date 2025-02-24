<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\{AuthController, RoleController, UserController};
use App\Http\Middleware\JwtMiddleware;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::middleware([JwtMiddleware::class])->group(function () {

    Route::middleware(['permission:show user'])->group(function () {
        Route::get('/user', [UserController::class, 'index']);
    });
    Route::middleware(['permission:create role'])->group(function () {
        Route::post('/role', [RoleController::class, 'store']);
    });
    Route::middleware(['permission:show role'])->group(function () {
        Route::get('/role', [RoleController::class, 'index']); 
    });
    Route::middleware(['permission:show permission'])->group(function () {
        Route::get('/permission', [RoleController::class, 'permission']);
    });
    Route::middleware(['permission:assign role'])->group(function () {
        Route::post('/users/{id}/assign-role', [UserController::class, 'assignRole']);
    });
    Route::middleware(['permission:assign permission'])->group(function () {
        Route::post('/users/{id}/assign-permission', [UserController::class, 'assignPermission']);
    });

    Route::post('/logout', [AuthController::class, 'logout']);
});
