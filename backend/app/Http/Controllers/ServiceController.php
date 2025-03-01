<?php

namespace App\Http\Controllers;

use App\Models\Service;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Database\Eloquent\ModelNotFoundException;

class ServiceController extends Controller
{
    public function showService()
    {
        $service = Service::select(
            'id', 
            'image',
            'title', 
            'description', 
            'option', 
            'start_date',
        )->get();
        return response()->json($service);
    }
    public function storeService(Request $request)
    {
        $validated = $request->validate([
            'image' => 'nullable|image|mimes:jpg,jpeg,png,gif|max:2048', 
            'title' => 'required|string|max:255',
            'description' => 'required|string|max:255',
            'option' => 'required|string|in:offline,online',
            'start_date' => 'required|date',
        ]);

        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('services', 'public'); 
            $validated['image'] = $imagePath;
        }

        $service = Service::create($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Service created successfully',
            'service' => [
                'id' => $service->id,
                'image' => $service->image ? asset('storage/' . $service->image) : null, // Full URL for frontend
                'title' => $service->title,
                'description' => $service->description,
                'option' => $service->option,
                'start_date' => $service->start_date,
            ],
        ], 201);
    }
    public function editService(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'image' => 'nullable|image|mimes:jpg,jpeg,png,gif|max:2048',
            'title' => 'sometimes|string|max:255',
            'description' => 'sometimes|string|max:255',
            'option' => 'sometimes|string|in:offline,online',
            'start_date' => 'sometimes|date'
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

            if ($request->hasFile('image')) {
                $imagePath = $request->file('image')->store('images', 'public');
                $validated['image'] = $imagePath;
            } else {
                unset($validated['image']); // Don't update image if none is uploaded
            }

            $service->update($validated);

            return response()->json([
                'status' => 'success',
                'message' => 'Service updated successfully',
                'service' => [
                    'id' => $service->id,
                    'image' => $service->image ? asset('storage/' . $service->image) : null, // Return full URL
                    'title' => $service->title,
                    'description' => $service->description,
                    'option' => $service->option,
                    'start_date' => $service->start_date,
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
}
