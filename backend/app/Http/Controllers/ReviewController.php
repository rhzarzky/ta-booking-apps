<?php

namespace App\Http\Controllers;

use App\Models\Review;
use App\Models\Booking;
use App\Services\ReviewService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class ReviewController extends Controller
{
    protected $reviewService;

    public function __construct(ReviewService $reviewService)
    {
        $this->reviewService = $reviewService;
    }

   
    public function submitReview(Request $request, $bookingId)
    {
        try {
            $validator = Validator::make($request->all(), [
                'rating' => 'required|integer|min:1|max:5',
                'comment' => 'nullable|string|max:1000'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data tidak valid',
                    'errors' => $validator->errors()
                ], 400);
            }

            $userId = Auth::id();
            $review = $this->reviewService->submitReview(
                $bookingId,
                $userId,
                $request->rating,
                $request->comment
            );

            return response()->json([
                'success' => true,
                'message' => 'Review berhasil dikirim',
                'data' => $review
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

   
    public function getReview($bookingId)
    {
        try {
            $userId = Auth::id();
            $booking = Booking::where('id', $bookingId)
                ->where('user_id', $userId)
                ->first();

            if (!$booking) {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking tidak ditemukan'
                ], 404);
            }

            $review = $this->reviewService->getReviewByBooking($bookingId);
            $isWithinPeriod = $this->reviewService->isWithinReviewPeriod($bookingId);

            return response()->json([
                'success' => true,
                'data' => [
                    'review' => $review,
                    'booking' => $booking,
                    'can_review' => $isWithinPeriod && (!$review || $review->status === 'pending'),
                    'deadline' => $review ? $review->review_deadline : null,
                    'completed_at' => $review ? $review->completed_at : null
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function getServiceReviews($serviceId)
    {
        try {
            $reviews = $this->reviewService->getServiceReviews($serviceId);
            $averageRating = $this->reviewService->getAverageRating($serviceId);

            return response()->json([
                'success' => true,
                'data' => [
                    'reviews' => $reviews,
                    'average_rating' => round($averageRating, 1),
                    'total_reviews' => $reviews->count()
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    
    public function getUserReviews()
    {
        try {
            $userId = Auth::id();
            $reviews = $this->reviewService->getUserReviews($userId);

            return response()->json([
                'success' => true,
                'data' => $reviews
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    
    public function canReview($bookingId)
    {
        try {
            $userId = Auth::id();
            $booking = Booking::where('id', $bookingId)
                ->where('user_id', $userId)
                ->first();

            if (!$booking) {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking tidak ditemukan'
                ], 404);
            }

            $completionStatus = $this->reviewService->getBookingCompletionStatus($bookingId);
            $review = $completionStatus['review'];
            $canReview = $completionStatus['can_review'];

            return response()->json([
                'success' => true,
                'data' => [
                    'can_review' => $canReview,
                    'booking_status' => $booking->status,
                    'review_status' => $completionStatus['review_status'],
                    'deadline' => $review ? $review->review_deadline : null,
                    'hours_remaining' => $review && $review->isReviewPeriodActive() ? 
                        now()->diffInHours($review->review_deadline, false) : 0,
                    'is_completed' => $completionStatus['is_completed']
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }
}