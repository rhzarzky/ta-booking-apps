<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Booking;
use App\Models\Service;
use Illuminate\Support\Facades\Auth;

class BookingController extends Controller
{
    public function showAllBooking()
    {
        $bookings = Booking::with('user', 'service')->get();

        $grouped = $bookings->groupBy('status')->map(function ($group) {
            return $group->map(function ($booking) {
                return [
                    'id_booking' => $booking->id,
                    'user' => [
                        'id_user' => $booking->user->id,
                        'email' => $booking->user->email,
                        'name' => $booking->user->name,
                    ],
                    'service' => [
                        'id_service' => $booking->service->id,
                        'image' => $booking->service->image,
                        'title' => $booking->service->title,
                        'description' => $booking->service->description,
                        'location'  => $booking->service->location,
                        'option' => $booking->option,
                        'date' => $booking->date,
                        'time' => $booking->time,
                        'note' => $booking->note,
                        'status' => $booking->status,
                    ],
                ];
            });
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Booking retrieved successfully',
            'bookings' => $grouped,
        ], 200);
    }
    public function showUserBooking()
    {
        $user = Auth::user();

        $bookings = Booking::with('service')
            ->where('user_id', $user->id)
            ->get()
            ->groupBy('status')
            ->map(function ($group) {
                return $group->map(function ($booking) {
                    return [
                        'id_booking' => $booking->id,
                        'service' => [
                            'id_service' => $booking->service->id,
                            'image' => $booking->service->image,
                            'title' => $booking->service->title,
                            'description' => $booking->service->description,
                            'location'  => $booking->service->location,
                        ],
                        'option' => $booking->option,
                        'date' => $booking->date,
                        'time' => $booking->time,
                        'note' => $booking->note,
                        'status' => $booking->status,
                    ];
                });
            });

        return response()->json([
            'status' => 'success',
            'message' => 'Service retrieved successfully',
            'user' => [
                'id_user' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ],
            'services' => $bookings,
        ], 200);
    }
    public function showDetailBooking($id)
    {
        $user = Auth::user();

        $booking = Booking::with(['service', 'user'])->findOrFail($id);

        if ($booking->user_id !== $user->id) {
            return response()->json([
                'status' => 'error',
                'message' => 'You are not authorized to view this booking.',
            ], 403);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Booking retrieved successfully',
            'id_booking' => $booking->id,
            'user' => [
                'id' => $booking->user->id,
                'name' => $booking->user->name,
                'email' => $booking->user->email,
            ],
            'service' => [
                'id_service' => $booking->service->id,
                'image' => $booking->service->image,
                'title' => $booking->service->title,
                'description' => $booking->service->description,
                'location'  => $booking->service->location,
                'option' => $booking->option,
                'date' => $booking->date,
                'time' => $booking->time,
                'note' => $booking->note,
                'status' => $booking->status,
            ],
        ], 200);
    }
    public function bookService(Request $request, $id)
    {
        $user = Auth::user();
        $service = Service::with('schedule')->findOrFail($id);

        $availableOption = json_decode($service->option, true);
        $availableTime = json_decode($service->schedule->time, true);

        $scheduleDates = json_decode($service->schedule->date, true);
        $availableDate= collect($scheduleDates)->pluck('date')->toArray();

        $validated = $request->validate([
            'date' => 'required|date|in:'. implode(',', $availableDate),
            'time' => 'required|date_format:H:i|in:'. implode(',', $availableTime),
            'note' => 'nullable|string|max:255',
            'option' => 'required|string|in:' . implode(',', $availableOption),
        ]); 

        $alreadyBooked = Booking::where('service_id', $service->id)
        ->where('user_id', $user->id)
        ->where('date', $validated['date'])
        ->where('time', $validated['time'])
        ->exists();

        if ($alreadyBooked) {
            return response()->json([
                'status' => 'error',
                'message' => 'You have already booked this service at the selected date and time.',
            ], 400);
        }

        $booking = Booking::create([
            'service_id' => $service->id,
            'user_id' => $user->id,
            'option' => $validated['option'],
            'date' => $validated['date'],
            'time' => $validated['time'],
            'note' => $validated['note'] ?? null,
            'status' => 'Pending',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Service booked successfully, awaiting approval.',
            'user' => [
                    'id_user' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ],
            'booking' => [
                'id_booking' => $booking->id,
                'option' => $booking->option,
                'date' => $booking->date,
                'time' => $booking->time,
                'note' => $booking->note,
                'status' => $booking->status,
                'service' => [
                    'id' => $service->id,
                    'title' => $service->title,
                    'description' => $service->description,
                    'location'  => $booking->service->location,
                    'option' => json_decode($service->option),
                ],
            ],
        ], 201);
    }
    public function confirm(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:Approved,Declined',
        ]);

        $booking = Booking::findOrFail($id);

        $booking->status = $request->status;
        $booking->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Booking status updated successfully.',
            'booking' => [
                'id_booking' => $booking->id,
                'status' => $booking->status,
            ],
        ], 200);
    }
}
