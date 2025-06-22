<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Review;
use App\Models\Service;
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
    public function submitReview(Request $request,$id)
    {
        $service = Service::findOrFail($id);

        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string',
        ]);

        // Check if the service exists
        if (!$service) {
            return response()->json(['message' => 'Service not found.'], 404);
        }

        // Check if the user has already booked the service
        $hasBooked = Booking::where('user_id', auth()->id())
            ->where('service_id', $request->service_id)
            ->where('status', 'approved')
            ->exists();

        if (!$hasBooked) {
            return response()->json(['message' => 'You must book the service before reviewing.'], 403);
        }

        Review::create([
            'user_id' => auth()->id(),
            'service_id' => $request->service_id,
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
            $reviews = Review::where('service_id', $id)->get();

            if ($reviews->isEmpty()) {
                return response()->json([
                    'status' => "success",
                    'message' => 'No reviews found for this service.'
                ], 404);
            }

            return response()->json([
                'status' => "success",
                'data' => $reviews
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
            $reviews = Review::where('user_id', $userId)->get();

            if ($reviews->isEmpty()) {
                return response()->json([
                    'status' => "success",
                    'message' => 'No reviews found for this user.'
                ], 404);
            }

            return response()->json([
                'status' => "success",
                'data' => $reviews
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'status' => "error",
                'message' => $e->getMessage()
            ], 500);
        }
    } 
}