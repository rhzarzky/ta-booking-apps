<?php

namespace App\Services;

use App\Models\Booking;
use App\Models\Review;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class BookingCompletionService
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    public function markAsCompleted(Booking $booking, $userType = 'user')
    {
        // Check if booking is already completed or reviewed
        $existingReview = $booking->review;
        if ($existingReview && $existingReview->completed_at) {
            return ['status' => false, 'message' => 'Booking sudah ditandai sebagai selesai.'];
        }

        $reviewData = [
            'booking_id' => $booking->id,
            'user_id' => $booking->user_id,
            'completed_at' => Carbon::now(),
            'review_deadline' => Carbon::now()->addHours(72),
            'status' => 'pending',
        ];

        if ($existingReview) {
            $existingReview->update($reviewData);
        } else {
            Review::create($reviewData);
        }

        // Send notifications
        $this->notificationService->sendCompletionConfirmation($booking, $userType);
        $this->notificationService->sendReviewRequest($booking, $userType);

        return ['status' => true, 'message' => 'Booking berhasil ditandai sebagai selesai.'];
    }

   
    public function getCompletionStatus(Booking $booking)
    {
        // Refresh relasi review untuk memastikan data terbaru
        $booking->load('review');
        $review = $booking->review;
        
        if (!$review || !$review->completed_at) {
            return 'Not Completed';
        }

        if ($review->rating && $review->reviewed_at) {
            return 'Reviewed';
        }

        if ($review->review_deadline < Carbon::now()) {
            return 'Declined Review';
        }

        return 'Completed - Awaiting Review';
    }

  
    public function processExpiredReviews()
    {
        $expiredReviews = Review::whereNotNull('completed_at')
            ->whereNull('rating')
            ->whereNull('reviewed_at')
            ->where('review_deadline', '<', Carbon::now())
            ->get();

        foreach ($expiredReviews as $review) {
            // Simply mark as declined review by virtue of deadline passing
            Log::info('Review expired for booking: ' . $review->booking_id);
            $this->notificationService->sendReviewDeclined($review->booking, 'user');
        }

        return count($expiredReviews);
    }

   
    public function canUserComplete($bookingId, $userId)
    {
        $booking = Booking::find($bookingId);
        
        if (!$booking) {
            return false;
        }

        return $booking->user_id === $userId;
    }

    
} 