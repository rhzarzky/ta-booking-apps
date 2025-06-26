<?php

namespace App\Services;

use Google\Auth\Credentials\ServiceAccountCredentials;
use GuzzleHttp\Client;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FCMService
{
    protected $accessToken;
    protected $fcmUrl;
    protected $projectId;

    public function __construct()
    {
        $this->projectId = config('services.fcm.project_id');
        $this->fcmUrl = "https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send";
        $this->accessToken = $this->getAccessToken();
    }

    private function getAccessToken()
    {
        try {
            $serviceAccountPath = storage_path('app/' . config('services.fcm.service_account_path'));

            if (!file_exists($serviceAccountPath)) {
                Log::error("Firebase service account file not found: " . $serviceAccountPath);
                return null;
            }

            $credentials = new ServiceAccountCredentials(
                'https://www.googleapis.com/auth/firebase.messaging',
                json_decode(file_get_contents($serviceAccountPath), true)
            );

            $token = $credentials->fetchAuthToken();

            return $token['access_token'] ?? null;
        } catch (\Exception $e) {
            Log::error("Error getting Firebase access token: " . $e->getMessage());
            return null;
        }
    }

    public function sendPushNotification($token, $title, $body, $data = [])
    {
        $success = false;
        
        if (!$this->accessToken) {
            Log::error("Cannot send FCM notification: No access token available");
        } else {
            $message = [
                'message' => [
                    'token' => $token,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                    ],
                    'data' => array_map('strval', $data), // FCM data harus berupa string
                    'android' => [
                        'priority' => 'high',
                        'notification' => [
                            'sound' => 'default',
                            'channel_id' => 'appointment_channel',
                        ]
                    ],
                ]
            ];

            try {
                $response = Http::withHeaders([
                    'Authorization' => 'Bearer ' . $this->accessToken,
                    'Content-Type' => 'application/json',
                ])->post($this->fcmUrl, $message);

                if (!$response->successful()) {
                    Log::error('FCM notification failed to send', [
                        'response_body' => $response->body(),
                        'status_code' => $response->status(),
                    ]);
                } else {
                    Log::info('FCM notification sent successfully', [
                        'to' => $token,
                        'title' => $title,
                        'response_status' => $response->status(),
                    ]);
                    $success = true;
                }
            } catch (\Exception $e) {
                Log::error("Error sending FCM notification: " . $e->getMessage());
            }
        }
        
        return $success;
    }
}
