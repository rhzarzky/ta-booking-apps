<?php

namespace App\Jobs;

use App\Services\BookingCompletionService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ProcessExpiredReviewsJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * Create a new job instance.
     */
    public function __construct()
    {
        //
    }

    /**
     * Execute the job.
     */
    public function handle(BookingCompletionService $completionService): void
    {
        try {
            $processedCount = $completionService->processExpiredReviews();
            
            Log::info("ProcessExpiredReviewsJob completed", [
                'processed_count' => $processedCount
            ]);
            
        } catch (\Exception $e) {
            Log::error("ProcessExpiredReviewsJob failed: " . $e->getMessage());
            throw $e;
        }
    }
} 