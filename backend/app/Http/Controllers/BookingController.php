<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Booking;
use Illuminate\Support\Facades\Auth;
use App\Models\Service;

class BookingController extends Controller
{
    public function showAllBooking()
    {
        $bookings = Booking::with('user', 'service')
        ->get()
        ->map(function ($booking) {
            return [
                'id_booking' => $booking->id,
                'user' => [
                    'id' => $booking->user->id,
                    'email' => $booking->user->email,
                    'name' => $booking->user->name,
                ],
                'service' => [
                    'id' => $booking->service->id,
                    'title' => $booking->service->title,
                    'description' => $booking->service->description,
                    'option' => $booking->option,
                    'day' => $booking->day,
                    'time' => $booking->time,
                    'status' => $booking->status,
                ],
            ];
        });
        return response()->json([
            'status' => 'success',
            'message' => 'Booking retrieved successfully',
            'services' => $bookings,
        ], 200);
    }
   public function showBooking($id)
    {
        $user = Auth::user();
        $booking = Booking::where('user_id', $id)->get();
        return response()->json([
            'status' => 'success',
            'message' => 'Service retrieved successfully',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ],
            'service' => $booking->map(function ($booking) {
                return [
                    'id'=> $booking->id,
                    'service' => [
                        'id' => $booking->service->id,
                        'title' => $booking->service->title,
                        'description' => $booking->service->description,
                    ],
                    'option' => $booking->option,
                    'day' => $booking->day,
                    'time' => $booking->time,
                    'note' => $booking->note,
                    'status' => $booking->status,
                ];
            }),
        ], 200);
    }

   public function bookService(Request $request, $id)
    {
        $user = Auth::user();
        $service = Service::findOrFail($id);
        $availableOptions = json_decode($service->option, true);
        $validated = $request->validate([
            'day' => 'required|string|max:255',
            'time' => 'required|date_format:H:i',
            'note' => 'nullable|string|max:255',
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
            'day' => $validated['day'],
            'time' => $validated['time'],
            'note' => $validated['note'],
            'status' => 'Pending',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Service booked successfully, awaiting approval.',
            'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ],
            'booking' => [
                'id' => $booking->id,
                'option' => $booking->option,
                'day' => $booking->day,
                'time' => $booking->time,
                'note' => $booking->note,
                'status' => $booking->status,
                'service' => [
                    'id' => $service->id,
                    'title' => $service->title,
                    'description' => $service->description,
                    'option' => json_decode($service->option),
                ],
            ],
        ], 201);
    }
}
