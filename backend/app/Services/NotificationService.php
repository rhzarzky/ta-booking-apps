<?php

namespace App\Services;

use App\Models\Booking;
use App\Models\User;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    
    public function sendCompletionConfirmation(Booking $booking, $userType = 'user')
    {
        try {
            $user = $booking->user;
            $service = $booking->service;
            
            Log::info("Notifikasi Konfirmasi Pelaksanaan", [
                'user_id' => $user->id,
                'booking_id' => $booking->id,
                'completed_by' => $userType,
                'message' => "Konfirmasi pelaksanaan Anda telah kami terima untuk layanan {$service->name}"
            ]);
            
            
            return true;
        } catch (\Exception $e) {
            Log::error("Error sending completion confirmation: " . $e->getMessage());
            return false;
        }
    }

   
    public function sendReviewRequest(Booking $booking, $userType = 'user')
    {
        try {
            $user = $booking->user;
            $service = $booking->service;
            
            Log::info("Notifikasi Permintaan Review", [
                'user_id' => $user->id,
                'booking_id' => $booking->id,
                'completed_by' => $userType,
                'message' => "Silakan berikan rating & review dalam 72 jam ke depan untuk layanan {$service->name}"
            ]);
            
            
            return true;
        } catch (\Exception $e) {
            Log::error("Error sending review request: " . $e->getMessage());
            return false;
        }
    }

    public function sendReviewDeclined(Booking $booking, $userType = 'user')
    {
        try {
            $user = $booking->user;
            $service = $booking->service;
            
            Log::info("Notifikasi Review Declined", [
                'user_id' => $user->id,
                'booking_id' => $booking->id,
                'declined_by' => $userType,
                'message' => "Karena Anda belum memberikan rating & review dalam 72 jam, proses dianggap selesai tanpa review untuk layanan {$service->name}"
            ]);
            
            
            return true;
        } catch (\Exception $e) {
            Log::error("Error sending review declined notification: " . $e->getMessage());
            return false;
        }
    }

   
    public function sendReviewSubmitted(Booking $booking)
    {
        try {
            $user = $booking->user;
            $service = $booking->service;
            
            Log::info("Notifikasi Review Submitted", [
                'user_id' => $user->id,
                'booking_id' => $booking->id,
                'message' => "Terima kasih telah memberikan review untuk layanan {$service->name}"
            ]);
            
            return true;
        } catch (\Exception $e) {
            Log::error("Error sending review submitted notification: " . $e->getMessage());
            return false;
        }
    }
} 