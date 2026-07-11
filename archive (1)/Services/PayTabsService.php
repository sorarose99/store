<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class PayTabsService
{
    protected string $baseUrl = 'https://secure.paytabs.sa';

    protected string $profileId;

    protected string $serverKey;

    public function __construct($gateway)
    {
        $this->profileId = $gateway->credentials['profile_id'];
        $this->serverKey = $gateway->credentials['server_key'];
    }

    public function createPayment(array $orderData)
    {
        $response = Http::withHeaders([
            'Authorization' => $this->serverKey,
            'Content-Type' => 'application/json',
        ])->post($this->baseUrl.'/payment/request', [
            'profile_id' => $this->profileId,
            'tran_type' => 'sale',
            'tran_class' => 'ecom',
            'cart_id' => $orderData['order_number'],
            'cart_description' => 'Order '.$orderData['order_number'],
            'cart_currency' => $orderData['currency'],
            'cart_amount' => $orderData['amount'],
            'callback' => route('payments.paytabs.callback'),
            'return' => route('payments.paytabs.return'),
            'customer_details' => [
                'name' => $orderData['name'],
                'email' => $orderData['email'],
                'phone' => $orderData['phone'],
                'street1' => $orderData['address'],
                'city' => $orderData['city'],
                'state' => $orderData['city'],
                'country' => $orderData['country'],
                'zip' => $orderData['zip'],
            ],
        ]);

        return $response->json();
    }

}
