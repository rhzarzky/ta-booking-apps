<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\{AuthController, RoleController, ServiceController, 
    UserController, BookingController, VerificationController, ReviewController};
use App\Http\Middleware\JwtMiddleware;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::get('/email/verify/{id}/{hash}', [VerificationController::class, 'verify'])->name('verification.verify.jwt');
Route::post('/forgot-password', [VerificationController::class, 'sendOtp']);
Route::post('/verify-otp', [VerificationController::class, 'verifyOtp']);
Route::post('/reset-password', [VerificationController::class, 'resetPassword']);
Route::post('/resend-otp', [VerificationController::class, 'resendOtp']);

Route::middleware([JwtMiddleware::class])->group(function () {

    Route::middleware(['permission:show user'])->group(function () {
        Route::get('/users', [UserController::class, 'showAllUser']);
        Route::get('/users/{id}', [UserController::class, 'getUserById']);
    });
    
    Route::middleware(['permission:create user'])->group(function () {
        Route::post('/users', [UserController::class, 'createUser']);
    });

    Route::middleware(['permission:edit user'])->group(function () {
        Route::put('/users/{id}', [UserController::class, 'editUserById']);
    });

    Route::middleware(['permission:delete user'])->group(function () {
        Route::delete('/users/{id}', [UserController::class, 'deleteUserById']);
    }); 

    Route::middleware(['permission:create role'])->group(function () {
        Route::post('/role', [RoleController::class, 'storeRole']);
    });
    
    Route::middleware(['permission:edit role'])->group(function () {
        Route::put('/role/{id}', [RoleController::class, 'editRole']);
    });

    Route::middleware(['permission:delete role'])->group(function () {
        Route::delete('/role/{id}', [RoleController::class, 'deleteRole']);
    });

    Route::middleware(['permission:show role'])->group(function () {
        Route::get('/role', [RoleController::class, 'showRole']); 
        Route::get('/role/{id}', [RoleController::class, 'showDetailRole']);
    });

    Route::middleware(['permission:show permission'])->group(function () {
        Route::get('/permission', [RoleController::class, 'showPermission']);
    });

    Route::middleware(['permission:assign role'])->group(function () {
        Route::post('/users/{id}/assign-role-user', [UserController::class, 'assignRoleUser']);
    });

    Route::middleware(['permission:assign permission'])->group(function () {
        Route::post('/users/{id}/assign-permission-user', [UserController::class, 'assignPermissionUser']);
        Route::post('/role/{id}/assign-permission-role', [RoleController::class, 'assignPermissionRole']);
    });

    Route::middleware(['permission:show all service'])->group(function () {
        Route::get('/service', [ServiceController::class, 'showAllService']);
    });

    Route::middleware(['permission:create service'])->group(function () {
        Route::post('/service', [ServiceController::class, 'storeService']);
    });

    Route::get('/service/assigned', [ServiceController::class, 'showAssignedService']);

    Route::middleware(['permission:edit service'])->group(function () {
        Route::put('/service/{id}', [ServiceController::class, 'editService']);
    });

    Route::middleware(['permission:delete service'])->group(function () {
        Route::delete('/service/{id}', [ServiceController::class, 'deleteService']);
    }); 

    Route::middleware(['permission:show all booking'])->group(function () {
        Route::get('/booking', [BookingController::class, 'showAllBooking']);
    });
    
    Route::get('/booking/assigned', [BookingController::class, 'showAssignedBooking']);

    Route::middleware(['permission:confirm booking'])->group(function () {
        Route::post('/booking/{id}/confirm', [BookingController::class, 'confirm']);
    });

    
    Route::get('/service/{id}', [ServiceController::class, 'showService']);

    Route::post('/service/{id}/book', [BookingController::class, 'bookService']);
    Route::get('/booking/{id}', [BookingController::class, 'showDetailBooking']); 
    Route::get('/user/booking', [BookingController::class, 'showUserBooking']);
    
    Route::get('/user/profile', [UserController::class, 'userProfile']);
    Route::put('/user/profile', [UserController::class, 'updateProfile']);
    
    Route::post('/booking/{id}/complete', [ReviewController::class, 'markCompleted']);
    Route::post('/service/{id}/review', [ReviewController::class, 'submitReview']);
    Route::get('/service/{id}/reviews', [ReviewController::class, 'getServiceReviews']);
    Route::get('/user/reviews', [ReviewController::class, 'getUserReviews']);
    
    Route::post('/logout', [AuthController::class, 'logout']);
});
