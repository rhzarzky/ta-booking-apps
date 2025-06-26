<?php

namespace App\Jobs;

use App\Models\Booking;
use App\Services\FCMService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class SendAppointmentNotificationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $booking;
    protected $status;

    public function __construct(Booking $booking, string $status)
    {
        $this->booking = $booking;
        $this->status = $status;
    }

    public function handle(FCMService $fcmService): void
    {
        try {
            $user = $this->booking->user;
            $service = $this->booking->service;

            // Skip jika user tidak ada atau tidak memiliki FCM token
            if (!$user || !$user->fcm_token) {
                Log::info('Cannot send notification - no FCM token', [
                    'user_id' => $user->id ?? 'Unknown',
                    'booking_id' => $this->booking->id
                ]);
                return;
            }

            // Tentukan judul dan pesan berdasarkan status
            $title = 'Appointment Update';
            $body = '';

            switch ($this->status) {
                case 'approved':
                    $title = 'Appointment Approved! ✅';
                    $body = "Great news! Your appointment for {$service->name} has been approved.";
                    break;

                case 'declined':
                    $title = 'Appointment Declined ❌';
                    $body = "Sorry, your appointment for {$service->name} has been declined.";
                    break;

                case 'cancelled':
                    $title = 'Appointment Cancelled';
                    $body = "Your appointment for {$service->name} has been cancelled.";
                    break;

                default:
                    $body = "Your appointment status has been updated to: {$this->status}";
                    break;
            }

            // Data tambahan untuk notifikasi
            $data = [
                'bookingId' => (string) $this->booking->id,
                'type' => 'appointment_status_update',
                'status' => $this->status,
                'serviceId' => (string) $this->booking->service_id,
                'serviceName' => $service->name,
                'bookingDate' => $this->booking->booking_date,
                'bookingTime' => $this->booking->booking_time,
            ];

            // Kirim notifikasi FCM
            $success = $fcmService->sendPushNotification(
                $user->fcm_token,
                $title,
                $body,
                $data
            );

            if ($success) {
                Log::info("Appointment notification sent successfully", [
                    'user_id' => $user->id,
                    'booking_id' => $this->booking->id,
                    'status' => $this->status
                ]);
            } else {
                Log::error("Failed to send appointment notification", [
                    'user_id' => $user->id,
                    'booking_id' => $this->booking->id,
                    'status' => $this->status
                ]);
            }

        } catch (\Exception $e) {
            Log::error("SendAppointmentNotificationJob failed: " . $e->getMessage(), [
                'booking_id' => $this->booking->id,
                'status' => $this->status,
                'error' => $e->getTraceAsString()
            ]);

            // Re-throw untuk retry mechanism
            throw $e;
        }
    }

    /**
     * Handle job failure
     */
    public function failed(\Throwable $exception): void
    {
        Log::error("SendAppointmentNotificationJob permanently failed", [
            'booking_id' => $this->booking->id,
            'status' => $this->status,
            'error' => $exception->getMessage()
        ]);
    }
}
