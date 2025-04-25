<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\{AuthController, RoleController, ServiceController, UserController, BookingController};
use App\Http\Middleware\JwtMiddleware;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::middleware([JwtMiddleware::class])->group(function () {

    Route::middleware(['permission:show user'])->group(function () {
        Route::get('/user', [UserController::class, 'showUser']);
    });
    Route::middleware(['permission:create role'])->group(function () {
        Route::post('/role', [RoleController::class, 'storeRole']);
    });
    Route::middleware(['permission:show role'])->group(function () {
        Route::get('/role', [RoleController::class, 'showRole']); 
    });
    Route::middleware(['permission:show permission'])->group(function () {
        Route::get('/permission', [RoleController::class, 'showPermission']);
    });
    Route::middleware(['permission:assign role'])->group(function () {
        Route::post('/users/{id}/assign-role', [UserController::class, 'assignRole']);
    });
    Route::middleware(['permission:assign permission'])->group(function () {
        Route::post('/users/{id}/assign-permission', [UserController::class, 'assignPermission']);
    });
    
    Route::get('/service', [ServiceController::class, 'showAllService']);
    Route::get('/service/{id}', [ServiceController::class, 'showService']);
    Route::post('/service', [ServiceController::class, 'storeService']);
    Route::put('/service/{id}', [ServiceController::class, 'editService']);
    
    Route::post('/service/{id}/book', [BookingController::class, 'bookService']);
    Route::get('/booking', [BookingController::class, 'showAllBooking']);
    Route::get('/booking/{id}', [BookingController::class, 'showBooking']);

    Route::post('/logout', [AuthController::class, 'logout']);
});
