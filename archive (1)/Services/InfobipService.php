<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class InfobipService
{
    protected $baseUrl;

    protected $apiKey;

    protected $smsSender;

    protected $whatsAppSender;

    public function __construct()
    {
        $this->baseUrl = config('services.infobip.base_url');
        $this->apiKey = config('services.infobip.api_key');
        $this->smsSender = config('services.infobip.sender');
        $this->whatsAppSender = config('services.infobip.whatsapp_sender');
    }

    // إرسال رسالة عامة
    public function sendSMS($phone, $message)
    {
        try {
            Log::info('SMS Request Started', [
                'phone' => $phone,
                'message' => $message,
            ]);

            $payload = [
                'messages' => [
                    [
                        'from' => $this->smsSender,
                        'destinations' => [
                            ['to' => $phone],
                        ],
                        'content' => [
                            'text' => $message,
                            'language' => [
                                'languageCode' => 'AUTODETECT',
                            ],
                            'transliteration' => 'NONE',
                        ],
                    ],
                ],
            ];

            Log::info('SMS Payload', $payload);

            $response = Http::withHeaders([
                'Authorization' => 'App '.$this->apiKey,
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
            ])->post($this->baseUrl.'/sms/3/messages', $payload);

            Log::info('SMS Response Status', [
                'status' => $response->status(),
            ]);

            Log::info('SMS Response Body', $response->json());
            // //////////////////////////////////////////////
            sleep(5);

            $statusResponse = Http::withHeaders([
                'Authorization' => 'App '.$this->apiKey,
                'Accept' => 'application/json',
            ])->get(
                $this->baseUrl.'/sms/1/reports',
                [
                    'messageId' => $response->json('messages.0.messageId'),
                ]
            );

            Log::info('SMS FINAL STATUS', $statusResponse->json());
            // ////////////////////////////////////////////

            if (! $response->successful()) {
                Log::error('SMS Failed', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);
            }

            return $response->json();

        } catch (\Exception $e) {
            Log::error('SMS Exception', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    // إرسال رسالة لرقم الواتساب
    public function sendWhatsApp($phone, $message)
    {
        try {

            $phone = ltrim($phone, '+');
            $messageId = (string) Str::uuid();

            Log::info('WhatsApp OTP Template Request', [
                'phone' => $phone,
            ]);

            $payload = [
                'messages' => [
                    [
                        'from' => $this->whatsAppSender,
                        'to' => $phone,
                        'messageId' => $messageId,

                        'content' => [
                            'templateName' => 'authentication', // اسم القالب عندك
                            'templateData' => [
                                'body' => [
                                    'placeholders' => [
                                        (string) $otp,
                                    ],
                                ],
                            ],
                            'language' => 'ar', // أو ar_AR حسب إعداد القالب
                        ],

                        'callbackData' => 'otp',

                        // اختياري
                        'notifyUrl' => null,
                    ],
                ],
            ];

            Log::info('WhatsApp OTP Template Payload', $payload);

            $response = Http::withHeaders([
                'Authorization' => 'App '.$this->apiKey,
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
            ])->post($this->baseUrl.'/whatsapp/1/message/template', $payload);

            Log::info('WhatsApp Response', $response->json());

            return $response->json();

        } catch (\Throwable $e) {

            Log::error('WhatsApp OTP Template Error', [
                'message' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }
}
