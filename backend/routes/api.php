<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\{AuthController, RoleController, ServiceController, 
    UserController, BookingController, VerificationController,ForgotPasswordController,
    BookingCompletionController, ReviewController};
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
    Route::middleware(['permission:create service'])->group(function () {
        Route::post('/service', [ServiceController::class, 'storeService']);
    });
    Route::middleware(['permission:edit service'])->group(function () {
        Route::put('/service/{id}', [ServiceController::class, 'editService']);
    });
    Route::middleware(['permission:delete service'])->group(function () {
        Route::delete('/service/{id}', [ServiceController::class, 'deleteService']);
    }); 
    Route::middleware(['permission:show booking'])->group(function () {
        Route::get('/booking', [BookingController::class, 'showAllBooking']);
    });
    Route::middleware(['permission:confirm booking'])->group(function () {
        Route::post('/booking/{id}/confirm', [BookingController::class, 'confirm']);
    });
    
    Route::get('/service', [ServiceController::class, 'showAllService']);
    Route::get('/service/{id}', [ServiceController::class, 'showService']);

    Route::post('/service/{id}/book', [BookingController::class, 'bookService']);
    Route::get('/booking/{id}', [BookingController::class, 'showDetailBooking']); 
    Route::get('/user/booking', [BookingController::class, 'showUserBooking']);
    
    Route::get('/user/profile', [UserController::class, 'userProfile']);
    Route::put('/user/profile', [UserController::class, 'updateProfile']);
    
    
    Route::post('/booking/{id}/complete', [BookingCompletionController::class, 'markAsCompleted']);
    Route::get('/booking/{id}/completion-status', [BookingCompletionController::class, 'getCompletionStatus']);
    
    // Admin routes for completion
    Route::middleware(['permission:confirm booking'])->group(function () {
        Route::post('/admin/booking/{id}/complete', [BookingCompletionController::class, 'adminMarkAsCompleted']);
        Route::post('/admin/process-expired-reviews', [BookingCompletionController::class, 'processExpiredReviews']);
    });
    
    Route::post('/booking/{id}/review', [ReviewController::class, 'submitReview']);
    Route::get('/booking/{id}/review', [ReviewController::class, 'getReview']);
    Route::get('/booking/{id}/can-review', [ReviewController::class, 'canReview']);
    Route::get('/service/{id}/reviews', [ReviewController::class, 'getServiceReviews']);
    Route::get('/user/reviews', [ReviewController::class, 'getUserReviews']);
    
    Route::post('/logout', [AuthController::class, 'logout']);
});
