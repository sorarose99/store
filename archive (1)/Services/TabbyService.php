<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class TabbyService
{
    protected string $baseUrl = 'https://api.tabby.ai'; // UAE/Kuwait
    // protected string $baseUrl = 'https://api.tabby.sa'; // KSA

    protected string $secretKey;

    protected string $merchant_code;

    public function __construct($gateway)
    {
        // التأكد من جلب المفتاح السري بشكل صحيح
        $this->secretKey = $gateway->credentials['secret_key'] ?? '';
        $this->merchant_code = $gateway->credentials['merchant_code'] ?? '';
    }

    /**
     * إنشاء جلسة دفع جديدة
     */
    public function createPayment(array $orderData)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer '.$this->secretKey,
                'Content-Type' => 'application/json',
            ])->post($this->baseUrl.'/api/v2/checkout', [
                'payment' => [
                    'amount' => number_format($orderData['amount'], 2, '.', ''),
                    'currency' => $orderData['currency'],
                    'description' => 'Order #'.$orderData['order_number'],
                    'buyer' => [
                        'phone' => $orderData['phone'],
                        'email' => $orderData['email'],
                        'name' => $orderData['name'],
                    ],
                    'shipping_address' => [
                        'address' => $orderData['address'] ?? 'N/A',
                        'city' => $orderData['city'] ?? 'N/A',
                        'country' => $orderData['country'],
                        'zip' => $orderData['zip'] ?? '00000',
                    ],
                    'order' => [
                        'reference_id' => $orderData['order_number'],
                        'items' => $orderData['items'],
                    ],
                    'buyer_history' => [
                        'registered_since' => $orderData['buyer_history']['registered_since'],
                        'loyalty_level' => (int) $orderData['buyer_history']['loyalty_level'],
                    ],
                    'order_history' => $orderData['order_history'] ?? [],
                ],
                'lang' => app()->getLocale(),
                'merchant_code' => $this->merchant_code,
                'merchant_urls' => [
                    'success' => route('orders.success', $orderData['order_number']),
                    'cancel' => route('payments.tabby.cancel', $orderData['order_number']),
                    'failure' => route('orders.failed', $orderData['order_number']),
                ],
            ]);
            /*
            Log::info('Tabby API Response', [
                'status' => $response->status(),
                'body' => $response->json(),
                'successful' => $response->successful(),
            ]);
            */

            return $response;
        } catch (\Exception $e) {
            Log::error('Tabby Service Exception', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return null;
        }
    }

    /**
     * التحقق من حالة الدفع وجلب البيانات (Retrieve Payment)
     */
    public function retrievePayment($paymentId)
    {

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer '.$this->secretKey,
            ])->get($this->baseUrl."/api/v2/payments/{$paymentId}");

            return $response->json();
        } catch (\Exception $e) {
            Log::error('Tabby Retrieve Payment Exception', ['message' => $e->getMessage()]);

            return null;
        }
    }

    /**
     * عمل Capture للعملية المصرحة لتحويل الأموال لحسابك
     */
    public function capturePayment($paymentId, $amount)
    {

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer '.$this->secretKey,
                'Content-Type' => 'application/json',
            ])->post($this->baseUrl."/api/v2/payments/{$paymentId}/captures", [
                'amount' => number_format($amount, 2, '.', ''),
            ]);

            // ✅ تحقق من نجاح الطلب
            if (! $response->successful()) {
                Log::error('Tabby Capture HTTP Error', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                    'payment_id' => $paymentId,
                    'amount' => $amount,
                ]);

                return null;
            }

            $result = $response->json();

            // ✅ تحقق من أن الـ Capture تم بنجاح
            if (isset($result['status']) && in_array($result['status'], ['CLOSED', 'CAPTURED', 'COMPLETED'])) {
                return $result;
            }

            // ✅ إذا كان الـ Capture فشل، سجل الخطأ
            Log::error('Tabby Capture Failed', [
                'response' => $result,
                'payment_id' => $paymentId,
            ]);

            return $result;

        } catch (\Exception $e) {
            Log::error('Tabby Capture Payment Exception', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'payment_id' => $paymentId,
            ]);

            return null;
        }
    }

    /**
     * تسجيل Webhook في نظام تابي
     */
    public function registerWebhook(string $webhookUrl, bool $isTest = false)
    {
        Log::error('start registerWebhook ', [
            'webhookUrl' => $webhookUrl,
        ]);
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer '.$this->secretKey,
                'Content-Type' => 'application/json',
                'X-Merchant-Code' => $this->merchant_code,
            ])->post($this->baseUrl.'/api/v1/webhooks', [
                'url' => $webhookUrl,
                'is_test' => $isTest,
                'code' => $this->merchant_code,
            ]);

            return $response;
        } catch (\Exception $e) {
            Log::error('Tabby Webhook Registration Exception', [
                'message' => $e->getMessage(),
            ]);

            return null;
        }
    }
}
