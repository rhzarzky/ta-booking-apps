<?php

namespace App\Console\Commands;

use App\Jobs\ProcessExpiredReviewsJob;
use Illuminate\Console\Command;

class ProcessExpiredReviews extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'reviews:process-expired';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Process expired reviews and mark them as declined';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Processing expired reviews...');
        
        try {
            ProcessExpiredReviewsJob::dispatch();
            $this->info('Job dispatched successfully!');
        } catch (\Exception $e) {
            $this->error('Failed to dispatch job: ' . $e->getMessage());
            return 1;
        }
        
        return 0;
    }
} 