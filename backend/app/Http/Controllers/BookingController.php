<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Booking;
use Illuminate\Support\Facades\Auth;
use App\Models\Service;

class BookingController extends Controller
{
    public function index()
    {
        $bookings = Booking::with('user', 'service')
        ->get()
        ->map(function ($booking) {
            return [
                'id' => $booking->id,
                'user' => [
                    'id' => $booking->user->id,
                    'email' => $booking->user->email,
                    'name' => $booking->user->name,
                ],
                'service' => [
                    'id' => $booking->service->id,
                    'title' => $booking->service->title,
                    'description' => $booking->service->description,
                ],
                'option' => $booking->option,
                'time' => $booking->time,
                'status' => $booking->status,
            ];
        });
        return response()->json([
            'status' => 'success',
            'message' => 'Booking retrieved successfully',
            'services' => $bookings,
        ], 200);
    }
   public function bookService(Request $request, $id)
    {
        $user = Auth::user();
        $service = Service::findOrFail($id);

        $availableOptions = json_decode($service->option, true);

        $validated = $request->validate([
            'time' => 'required|date_format:H:i',
            'option' => 'required|string|in:' . implode(',', $availableOptions), // Only allow options set by admin
        ]);

        if (Booking::where('service_id', $service->id)->where('user_id', $user->id)->exists()) {
            return response()->json([
                'status' => 'error',
                'message' => 'You have already booked this service.',
            ], 400);
        }

        $booking = Booking::create([
            'service_id' => $service->id,
            'user_id' => $user->id,
            'option' => $validated['option'],
            'time' => $validated['time'],
            'status' => 'Pending',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Service booked successfully, awaiting approval.',
            'booking' => [
                'id' => $booking->id,
                'option' => $booking->option,
                'time' => $booking->time,
                'status' => $booking->status,
                'service' => [
                    'id' => $service->id,
                    'title' => $service->title,
                    'description' => $service->description,
                    'option' => json_decode($service->option),
                    'start_date' => $service->start_date,
                ],
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ],
            ],
        ], 201);
    }
}
