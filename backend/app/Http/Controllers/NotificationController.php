<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    public function getRecentUpdates(Request $request)
    {
        $userId = Auth::id();
        $lastCheck = $request->input('last_check', Carbon::now()->subMinutes(30)->toDateTimeString());

        // Ambil booking yang baru diupdate
        $recentUpdates = Booking::with(['service'])
            ->where('user_id', $userId)
            ->where('updated_at', '>', $lastCheck)
            ->whereIn('status', ['Approved', 'Declined', 'Completed'])
            ->get()
            ->map(function ($booking) {
                return [
                    'id' => $booking->id,
                    'status' => $booking->status,
                    'service_name' => $booking->service->title ?? 'Unknown',
                    'message' => $this->getStatusMessage($booking->status),
                    'updated_at' => $booking->updated_at->toISOString(),
                    'booking_date' => $booking->date,
                    'booking_time' => $booking->time,
                    'location' => $booking->location,
                ];
            });

        return response()->json([
            'success' => true,
            'notifications' => $recentUpdates,
            'count' => $recentUpdates->count(),
            'last_check' => now()->toISOString()
        ]);
    }

    private function getStatusMessage($status)
    {
        switch (strtolower($status)) {
            case 'approved':
                return "Your appointment has been approved! ✅";
            case 'declined':
                return "Your appointment has been declined ❌";
            case 'completed':
                return "Your appointment has been completed ✨";
            default:
                return "Your appointment status has been updated";
        }
    }
}
