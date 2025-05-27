<?php

namespace App\Services;

use App\Models\Review;
use App\Models\Booking;
use Carbon\Carbon;

class ReviewService
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    public function submitReview($bookingId, $userId, $rating, $comment = null)
    {
        $booking = Booking::find($bookingId);
        
        if (!$booking || $booking->user_id != $userId) {
            throw new \Exception('Booking tidak ditemukan atau tidak memiliki akses');
        }

        $review = Review::where('booking_id', $bookingId)->first();
        
        if (!$review || !$review->completed_at) {
            throw new \Exception('Booking belum diselesaikan. Silakan selesaikan booking terlebih dahulu.');
        }

        if ($review->rating && $review->reviewed_at) {
            throw new \Exception('Review sudah disubmit sebelumnya');
        }

        // Check if still within 72 hours
        if ($review->review_deadline < Carbon::now()) {
            throw new \Exception('Periode review telah berakhir');
        }

        // Update review
        $review->update([
            'rating' => $rating,
            'comment' => $comment,
            'reviewed_at' => Carbon::now(),
            'status' => 'submitted'
        ]);

        // Kirim notifikasi review submitted
        $this->notificationService->sendReviewSubmitted($booking);

        return $review;
    }

    public function isWithinReviewPeriod($bookingId)
    {
        $review = Review::where('booking_id', $bookingId)->first();
        
        if (!$review || !$review->completed_at) {
            return false;
        }

        return $review->review_deadline > Carbon::now();
    }

    public function getReviewByBooking($bookingId)
    {
        return Review::where('booking_id', $bookingId)->first();
    }

    public function processExpiredReviews()
    {
        $expiredReviews = Review::whereNotNull('completed_at')
            ->whereNull('rating')
            ->whereNull('reviewed_at')
            ->where('review_deadline', '<', Carbon::now())
            ->get();

        foreach ($expiredReviews as $review) {
            // Update status to declined for expired reviews
            $review->update(['status' => 'declined']);
            
            // Send notification for expired review
            $booking = $review->booking;
            if ($booking) {
                $this->notificationService->sendReviewDeclined($booking, 'system');
            }
        }

        return $expiredReviews->count();
    }

    public function getServiceReviews($serviceId, $limit = 10)
    {
        return Review::whereHas('booking', function($query) use ($serviceId) {
            $query->where('service_id', $serviceId);
        })
        ->where(function($query) {
            $query->where('status', 'submitted')
                  ->orWhere(function($q) {
                      $q->whereNotNull('rating')
                        ->whereNotNull('reviewed_at');
                  });
        })
        ->with(['user', 'booking.service'])
        ->orderBy('created_at', 'desc')
        ->limit($limit)
        ->get();
    }

    public function getAverageRating($serviceId)
    {
        return Review::whereHas('booking', function($query) use ($serviceId) {
            $query->where('service_id', $serviceId);
        })
        ->where(function($query) {
            $query->where('status', 'submitted')
                  ->orWhere(function($q) {
                      $q->whereNotNull('rating')
                        ->whereNotNull('reviewed_at');
                  });
        })
        ->avg('rating');
    }

    public function getUserReviews($userId)
    {
        return Review::where('user_id', $userId)
            ->with(['booking.service'])
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function getBookingCompletionStatus($bookingId)
    {
        $booking = Booking::find($bookingId);
        if (!$booking) {
            return null;
        }

        $review = Review::where('booking_id', $bookingId)->first();
        
        $isCompleted = $review && $review->completed_at;
        $hasReview = $review && $review->rating && $review->reviewed_at;
        $canReview = $isCompleted && !$hasReview && $review->review_deadline > Carbon::now();
        
        $reviewStatus = 'not_completed';
        if ($isCompleted) {
            if ($hasReview) {
                $reviewStatus = 'reviewed';
            } elseif ($review->review_deadline < Carbon::now()) {
                $reviewStatus = 'declined_review';
            } else {
                $reviewStatus = 'pending_review';
            }
        }
        
        return [
            'booking' => $booking,
            'review' => $review,
            'is_completed' => $isCompleted,
            'can_review' => $canReview,
            'review_status' => $reviewStatus
        ];
    }
}