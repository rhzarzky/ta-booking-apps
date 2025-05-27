<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Services\BookingCompletionService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class BookingCompletionController extends Controller
{
    protected $completionService;

    public function __construct(BookingCompletionService $completionService)
    {
        $this->completionService = $completionService;
    }

    public function markAsCompleted($bookingId)
    {
        try {
            $userId = Auth::id();
            
            // Ambil booking object
            $booking = Booking::find($bookingId);
            if (!$booking) {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking tidak ditemukan'
                ], 404);
            }
            
            // Cek apakah user bisa complete booking ini
            if (!$this->completionService->canUserComplete($bookingId, $userId)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda tidak memiliki akses untuk menyelesaikan booking ini'
                ], 403);
            }

            $result = $this->completionService->markAsCompleted($booking, 'user');

            // Refresh booking untuk mendapatkan data terbaru
            $booking->refresh();

            return response()->json([
                'success' => $result['status'],
                'message' => $result['message'],
                'data' => [
                    'booking_id' => $booking->id,
                    'completion_status' => $this->completionService->getCompletionStatus($booking)
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }


    public function getCompletionStatus($bookingId)
    {
        try {
            $booking = Booking::find($bookingId);
            if (!$booking) {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking tidak ditemukan'
                ], 404);
            }

            $status = $this->completionService->getCompletionStatus($booking);

            return response()->json([
                'success' => true,
                'data' => [
                    'booking_id' => $booking->id,
                    'completion_status' => $status
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }    public function processExpiredReviews()
    {
        try {
            $processedCount = $this->completionService->processExpiredReviews();

            return response()->json([
                'success' => true,
                'message' => "Berhasil memproses {$processedCount} review yang expired",
                'data' => [
                    'processed_count' => $processedCount
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