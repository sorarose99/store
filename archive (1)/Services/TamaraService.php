<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class TamaraService
{
    protected string $baseUrl;

    protected string $token;

    public function __construct($gateway)
    {
        $this->baseUrl = $gateway->mode == 'sandbox'
            ? 'https://api-sandbox.tamara.co'
            : 'https://api.tamara.co';

        $this->token = $gateway->credentials['api_token'];
    }

    public function createCheckout(array $data)
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer '.$this->token,
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
        ])
            ->timeout(30)
            ->post($this->baseUrl.'/checkout', [

                'order_reference_id' => $data['order_number'],

                'total_amount' => [
                    'amount' => (float) $data['amount'],
                    'currency' => 'SAR',
                ],

                'shipping_amount' => [
                    'amount' => 0,
                    'currency' => 'SAR',
                ],

                'tax_amount' => [
                    'amount' => 0,
                    'currency' => 'SAR',
                ],

                'description' => 'Order #'.$data['order_number'],

                'country_code' => 'SA',

                'payment_type' => 'PAY_BY_INSTALMENTS',

                'instalments' => 3,

                'locale' => 'ar_SA',

                'consumer' => [
                    'first_name' => $data['first_name'],
                    'last_name' => $data['last_name'],
                    'phone_number' => $data['phone'],
                    'email' => $data['email'],
                ],

                'billing_address' => [
                    'first_name' => $data['first_name'],
                    'last_name' => $data['last_name'],
                    'line1' => $data['address'],
                    'city' => $data['city'],
                    'country_code' => 'SA',
                    'phone_number' => $data['phone'],
                ],

                'shipping_address' => [
                    'first_name' => $data['first_name'],
                    'last_name' => $data['last_name'],
                    'line1' => $data['address'],
                    'city' => $data['city'],
                    'country_code' => 'SA',
                    'phone_number' => $data['phone'],
                ],

                'items' => $data['items'],

                'merchant_url' => [
                    'success' => route('orders.success', $data['order_number']),
                    'failure' => route('orders.failed', $data['order_number']),
                    'cancel' => route('payments.tamara.cancel', $data['order_number']),
                    'notification' => route('api-payments.tamara.webhook'),
                ],
            ]);

        return $response->json();
    }
}
