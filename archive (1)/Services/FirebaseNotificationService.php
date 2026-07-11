<?php

namespace App\Services;

use Google\Auth\Credentials\ServiceAccountCredentials;
use Illuminate\Support\Facades\Http;

class FirebaseNotificationService
{
    protected $projectId;

    protected $credentialsPath;

    public function __construct()
    {
        $this->projectId = config('services.firebase.project_id');
        $this->credentialsPath = config('services.firebase.credentials');
    }

    protected function getAccessToken()
    {
        $scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

        $credentials = new ServiceAccountCredentials($scopes, $this->credentialsPath);

        $token = $credentials->fetchAuthToken();

        return $token['access_token'];
    }

    public function send($token, $title, $body, array $data = [])
    {
        $accessToken = $this->getAccessToken();

        $url = "https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send";

        $payload = [
            'message' => [
                'token' => $token,

                // مهم جداً: إشعار للـ Web
                'webpush' => [
                    'headers' => [
                        'Urgency' => 'high',
                    ],
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                        'icon' => asset('img/kdx-logo.jpeg'),
                        'requireInteraction' => true,
                        'vibrate' => [200, 100, 200],
                    ],
                    'fcm_options' => [
                        'link' => $data['click_action'] ?? '/',
                    ],
                ],

                // إشعار للأندرويد
                'android' => [
                    'priority' => 'high',
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                        'icon' => asset('img/kdx-logo.jpeg'),
                        'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    ],
                ],

                // إشعار للآيفون
                'apns' => [
                    'headers' => [
                        'apns-priority' => '10',
                    ],
                    'payload' => [
                        'aps' => [
                            'alert' => [
                                'title' => $title,
                                'body' => $body,
                            ],
                            'sound' => 'default',
                        ],
                    ],
                ],

                // البيانات الإضافية
                'data' => collect($data)->map(fn ($value) => (string) $value)->toArray(),
            ],
        ];

        $response = Http::withToken($accessToken)
            ->withHeaders([
                'Content-Type' => 'application/json',
            ])
            ->post($url, $payload);

        $result = $response->json();

        return $result;
    }
}
