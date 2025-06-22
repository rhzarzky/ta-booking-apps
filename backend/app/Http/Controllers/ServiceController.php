<?php

namespace App\Http\Controllers;

use App\Models\Service;
use App\Models\Schedule;
use App\Models\Location;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Carbon\Carbon;
use Illuminate\Support\Facades\Auth;

class ServiceController extends Controller
{
    public function showAllService()
    {
        $services = Service::with('schedule')
            ->select('id', 'user_id','image', 'title', 'description', 'option') 
            ->get()
            ->map(function ($service) {
                return [
                    'id' => $service->id,
                    'user' => [
                        'id' => $service->user_id,
                        'name' => $service->assigned->name,
                        'email' => $service->assigned->email,
                    ],
                    'image' => $service->image ? asset('storage/' . $service->image) : null,
                    'title' => $service->title,
                    'description' => $service->description,
                    'location'  => $service->location->location,
                    'longitude' => $service->location->longitude,
                    'latitude' => $service->location->latitude,
                    'option' => json_decode($service->option, true),
                    'time' => $service->schedule ? json_decode($service->schedule->time, true) : null,
                    'days' => $service->schedule ? json_decode($service->schedule->days, true) : null,
                    'date' => $service->schedule ? json_decode($service->schedule->date, true) : null,
                    'end_date' => $service->schedule ? $service->schedule->end_date : null,
                ];
            });

        return response()->json([
            'status' => 'success',
            'message' => 'Services retrieved successfully',
            'services' => $services,
        ], 200);
    }
    public function showService($id)
    {
        $service = Service::findOrFail($id);

        if (!$service) {
            return response()->json([
                'status' => 'error',
                'message' => 'Service not found',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Service retrieved successfully',
            'service' => [
                'id' => $service->id,
                'user' => [
                    'id' => $service->user_id,
                    'name' => $service->assigned->name,
                    'email' => $service->assigned->email,
                ],
                'image' => $service->image ? asset('storage/' . $service->image) : null,
                'title' => $service->title,
                'description' => $service->description,
                'location'  => $service->location->location,
                'longitude' => $service->location->longitude,
                'latitude' => $service->location->latitude,
                'option' => json_decode($service->option, true),
                'time' => $service->schedule ? json_decode($service->schedule->time, true) : null,
                'days' => $service->schedule ? json_decode($service->schedule->days, true) : null,
                'date' => $service->schedule ? json_decode($service->schedule->date, true) : null,
                'end_date' => $service->schedule ? $service->schedule->end_date : null,
            ],
        ], 200);
    }      
    public function showAssignedService()
    {
        $assignedUser = Auth::user();

        // Ambil service yang di-assign ke user ini
        $assignedService = Service::with('assigned')
            ->where( function ($query) use ($assignedUser) {
                $query->where('user_id', $assignedUser->id);
            })
            ->get()
            ->map(function ($service) {
                return [
                    'id' => $service->id,
                    'user' => [
                        'id' => $service->user_id,
                        'name' => $service->assigned->name,
                        'email' => $service->assigned->email,
                    ],
                    'image' => $service->image ? asset('storage/' . $service->image) : null,
                    'title' => $service->title,
                    'description' => $service->description,
                    'location'  => $service->location->location,
                    'longitude' => $service->location->longitude,
                    'latitude' => $service->location->latitude,
                    'option' => json_decode($service->option, true),
                    'time' => $service->schedule ? json_decode($service->schedule->time, true) : null,
                    'days' => $service->schedule ? json_decode($service->schedule->days, true) : null,
                    'date' => $service->schedule ? json_decode($service->schedule->date, true) : null,
                    'end_date' => $service->schedule ? $service->schedule->end_date : null,
                ];
            });

        return response()->json([
            'status' => 'success',
            'message' => 'Assigned booking retrieved successfully',
            'services' => $assignedService,
        ], 200);
    }
    public function storeService(Request $request)
    {
        $validated = $request->validate([
            'image' => 'nullable|image|mimes:jpg,jpeg,png,gif|max:2048',
            'title' => 'required|string|max:255',
            'description' => 'required|string|max:255',
            'location'  => 'required|string|max:255',
            'longitude' => 'nullable|numeric',
            'latitude' => 'nullable|numeric',
            'option' => 'required|array',
            'option.*' => 'in:Offline,Online',
            'days' => 'required|array',
            'days.*' => 'in:Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',
            'time' => 'required|array',
            'time.*' => 'required|date_format:H:i',
            'end_date' => 'required|date|after_or_equal:today',
        ]);

        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('services', 'public');
            $validated['image'] = $imagePath;
        }

        // Convert array to JSON for storage
        $validated['option'] = json_encode($validated['option']);
        $validated['days'] = json_encode($validated['days']);
        $validated['time'] = json_encode($validated['time']);

        //save user_id that create service
        $validated['user_id'] = Auth::id();

        $service = Service::create($validated);

        // Auto-generate service date
        $days = $request->days;
        $endDate = $validated['end_date'] ? Carbon::parse($validated['end_date']) : Carbon::now()->addYear();
        $today = Carbon::now();
        $date = [];

        while ($today->lte($endDate)) {
            if (in_array($today->format('l'), $days)) {
                $date[] = [
                    'date' => $today->format('Y-m-d'),
                    'day' => $today->format('l'),
                ];
            }
            $today->addDay();
        }

        $location = Location::create([
            'service_id' => $service->id,
            'location' => $request->location,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
        ]);

        $schedule = Schedule::create([
            'service_id' => $service->id, 
            'days' => json_encode($days),
            'time' => json_encode($request->time),
            'end_date' => $request->end_date,
            'date' => json_encode($date),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Service created successfully',
            'service' => [
                'id' => $service->id,
                'user' => [
                    'id' => $service->user_id,
                    'name' => $service->assigned->name,
                    'email' => $service->assigned->email,
                ],
                'image' => $service->image ? asset('storage/' . $service->image) : null,
                'title' => $service->title,
                'description' => $service->description,
                'location'  => $location->location,
                'longitude' => $location->longitude,
                'latitude' => $location->latitude,
                'option' => json_decode($service->option),
                'days' => json_decode($schedule->days),
                'time' => json_decode($schedule->time),
                'date' => json_decode($schedule->date),
                'end_date' => $schedule->end_date,
            ],
        ], 201);
    }
    public function editService(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'image' => 'nullable|image|mimes:jpg,jpeg,png,gif|max:2048',
            'title' => 'sometimes|string|max:255',
            'description' => 'sometimes|string|max:255',
            'location' => 'sometimes|string|max:255',
            'longitude' => 'sometimes|numeric',
            'latitude' => 'sometimes|numeric',
            'option' => 'sometimes|array',
            'option.*' => 'in:Offline,Online',
            'days' => 'sometimes|array',
            'days.*' => 'in:Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',
            'time' => 'sometimes|array',
            'time.*' => 'required|date_format:H:i',
            'end_date' => 'sometimes|date|after_or_equal:today',
            'user_id' => 'sometimes|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $service = Service::findOrFail($id);
            $validated = $validator->validated();

            // Handle image
            if ($request->hasFile('image')) {
                $imagePath = $request->file('image')->store('services', 'public');
                $validated['image'] = $imagePath;
            }

            // Encode option, days, and time if provided
            if ($request->has('option')) {
                $validated['option'] = json_encode($validated['option']);
            }

            if ($request->has('days')) {
                $validated['days'] = json_encode($validated['days']);
            }

            if ($request->has('time')) {
                $validated['time'] = json_encode($validated['time']);
            }

            if ($request->has('user_id')) {
                $validated['user_id'] = $request->input('user_id');
            }

            // Update service
            $service->update($validated);

            Location::updateOrCreate(
                ['service_id' => $service->id],
                [
                    'location' => $request->input('location', $service->location->location),
                    'latitude' => $request->input('latitude', $service->location->latitude),
                    'longitude' => $request->input('longitude', $service->location->longitude),
                ]
            );

            // Handle schedule creation/update
            if ($request->has('days') || $request->has('end_date') || $request->has('time')) {
                $days = $request->has('days') ? json_decode($validated['days'], true) : json_decode($service->schedule->days ?? '[]', true);
                $time = $request->has('time') ? json_decode($validated['time'], true) : json_decode($service->schedule->time ?? '[]', true);
                $endDate = $request->has('end_date') ? Carbon::parse($validated['end_date']) : Carbon::parse(optional($service->schedule)->end_date);

                $today = Carbon::now();
                $date = [];

                while ($today->lte($endDate)) {
                    if (in_array($today->format('l'), $days)) {
                        $date[] = [
                            'date' => $today->format('Y-m-d'),
                            'day' => $today->format('l'),
                        ];
                    }
                    $today->addDay();
                }

                Schedule::updateOrCreate(
                    ['service_id' => $service->id],
                    [
                        'days' => json_encode($days),
                        'time' => json_encode($time),
                        'end_date' => $endDate->format('Y-m-d'),
                        'date' => json_encode($date),
                    ]
                );
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Service updated successfully',
                'service' => [
                    'id' => $service->id,
                    'user' => [
                        'id' => $service->user_id,
                        'name' => $service->assigned->name,
                        'email' => $service->assigned->email,
                    ],
                    'image' => $service->image ? asset('storage/' . $service->image) : null,
                    'title' => $service->title,
                    'description' => $service->description,
                    'location' => $service->location->location,
                    'longitude' => $service->location->longitude,
                    'latitude' => $service->location->latitude,
                    'option' => json_decode($service->option ?? '[]', true),
                    'days' => json_decode(optional($service->schedule)->days ?? '[]', true),
                    'time' => json_decode(optional($service->schedule)->time ?? '[]', true),
                    'date' => json_decode(optional($service->schedule)->date ?? '[]', true),
                    'end_date' => optional($service->schedule)->end_date,
                ],
            ], 200);
        } catch (ModelNotFoundException $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Service not found',
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while updating the service.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function deleteService($id)
    {
        $service = Service::find($id);

        if (!$service) {
            return response()->json([
                'status' => 'error', 
                'message' => 'Service not found'
            ], 404);
        }

        $service->delete();

        return response()->json([
            'status' => 'success', 
            'message' => 'Service deleted successfully'
        ], 200);
    }
}
