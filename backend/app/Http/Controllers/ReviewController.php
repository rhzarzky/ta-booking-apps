<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ReviewController extends Controller
{
    public function markCompleted($id)
    {
        $booking = Booking::where('id', $id)
            ->where('user_id', auth()->id())
            ->first();

        if (!$booking) {
            return response()->json([
                'responseMessage' => 'The requested booking was not found in this user.'
            ], 404);
        }   

        if ($booking->status !== 'Approved') {
            return response()->json([
                'message' => 'Only approved booking can be marked as completed.'
            ], 403);
        }

        $booking->status = 'Completed';
        $booking->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Booking marked as completed.'
        ]);
    }
    public function submitReview(Request $request, $id)
    {
        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string',
        ]);

        // Check if the user has booked the service
        $hasBooked = Booking::where('user_id', Auth::user()->id)
            ->where('service_id', $id)
            ->where('status', 'Completed')
            ->exists();

        if (!$hasBooked) {
            return response()->json([
                'status' => 'error',
                'message' => 'You must book the service before reviewing.'
            ], 403);
        }

        Review::create([
            'user_id' => auth()->id(),
            'service_id' => $id,
            'rating' => $request->rating,
            'comment' => $request->comment,
        ]);

        return response()->json([
            'status' => "success",
            'message' => 'Review submitted successfully.'
        ], 201);
    }

    public function getServiceReviews($id)
    {
        try {
            $reviews = Review::where('service_id', $id)->get()->map(function ($review) {
                return [
                    'id' => $review->id,
                    'user' => [
                        'user_id' => $review->user_id,
                        'name' => $review->user->name,
                        'email' => $review->user->email,
                    ],
                    'service_id' => $review->service_id,
                    'rating' => $review->rating,
                    'comment' => $review->comment,
                    'created_at' => $review->created_at->format('d-m-Y H:i:s'),
                ];
            });

            if ($reviews->isEmpty()) {
                return response()->json([
                    'status' => "success",
                    'message' => 'No reviews found for this service.'
                ], 200);
            }

            return response()->json([
                'status' => "success",
                'reviews' => $reviews
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'status' => "error",
                'message' => $e->getMessage()
            ], 500);
        }
    }
    
    public function getUserReviews()
    {
        try {
            $userId = Auth::id();
            $reviews = Review::with('service')
            ->where('user_id', $userId)
            ->get()
            ->map(function ($review) {
                return [
                    'review_id' => $review->id,
                    'service' => [
                        'id' => $review->service?->id,
                        'title' => $review->service?->title,
                    ],
                    'rating' => $review->rating,
                    'comment' => $review->comment,
                    'created_at' => $review->created_at->format('d-m-Y H:i:s'),
                ];
            });

            if ($reviews->isEmpty()) {
                return response()->json([
                    'status' => "success",
                    'message' => 'No reviews found for this user.'
                ], 200);
            }

            return response()->json([
                'status' => "success",
                'reviews' => $reviews
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'status' => "error",
                'message' => $e->getMessage()
            ], 500);
        }
    } 
}