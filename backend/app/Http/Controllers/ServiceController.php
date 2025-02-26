<?php

namespace App\Http\Controllers;

use App\Models\Service;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Database\Eloquent\ModelNotFoundException;

class ServiceController extends Controller
{
    public function index()
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
    public function store(Request $request)
    {
        $validated = $request->validate([
            'image' => 'nullable|string',
            'title' => 'required|string|max:255',
            'description' => 'required|string|max:255',
            'option' => 'required|string|in:offline,online',
            'start_date' => 'required|date',
        ]);

        $service = Service::create($validated);
        return response()->json([
            'status' => 'success',
            'message' => 'service service created successfully',
            'service' => [
                'id' => $service->id,
                'image' => $service->image,
                'title' => $service->title,
                'description' => $service->description,
                'option' => $service->option,
                'start_date' => $service->start_date,
            ],
        ], 200);
    }
    public function edit(Request $request)
    {
        $validate = Validator::make($request->all(), [
            'image' => 'sometimes|string',
            'title' => 'sometimes|string|max: 255',
            'description' => 'sometimes|string|max: 255',
            'option' => 'sometimes|string|in:offline,online',
            'start_date' => 'sometimes|date'
        ]);

        if ($validate->fails()) {
            return response()->json([
                'status' => 'error',
                'error' => $validate->errors(),
            ], 422);
        }

        try {
            $service = Service::findOrFail();
            
        } catch (ModelNotFoundException $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Service not found',
            ], 404);
        }
    }
}
