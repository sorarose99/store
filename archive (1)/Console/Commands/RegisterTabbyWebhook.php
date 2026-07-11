<?php

namespace App\Console\Commands;

use App\Models\PaymentGateway;
use App\Services\TabbyService;
use Illuminate\Console\Command;

class RegisterTabbyWebhook extends Command
{
    protected $signature = 'tabby:register-webhook';

    protected $description = 'Register Tabby webhook';

    public function handle()
    {
        $gateway = PaymentGateway::where('name', 'tabby')->where('is_active', 1)->first();

        if (! $gateway) {
            $this->error('❌ Tabby gateway not found or inactive');
            return 1;
        }

        // عرض بيانات البوابة للتحقق
        $this->info('📋 Gateway Information:');
        $this->line('Merchant Code: ' . ($gateway->credentials['merchant_code'] ?? '❌ NOT SET'));
        $this->line('Secret Key: ' . (isset($gateway->credentials['secret_key']) ? '✅ SET' : '❌ NOT SET'));
        $this->line('---');

        $tabbyService = new TabbyService($gateway);
        
        // استخدم الرابط المباشر بدلاً من route
        $webhookUrl = route('api-payments.tabby.webhook');
        $isTest = config('app.env') !== 'production';
        
        $this->info('📡 Registering webhook:');
        $this->line('URL: ' . $webhookUrl);
        $this->line('Test Mode: ' . ($isTest ? 'Yes' : 'No'));
        $this->line('---');

        $response = $tabbyService->registerWebhook($webhookUrl, $isTest);

        if (!$response) {
            $this->error('❌ No response from Tabby (connection error)');
            return 1;
        }

        $this->info('📊 Response:');
        $this->line('Status Code: ' . $response->status());
        $this->line('Body:');
        $this->line(json_encode($response->json(), JSON_PRETTY_PRINT));
        $this->line('---');

        if ($response->successful()) {
            $this->info('✅ Webhook registered successfully');
            return 0;
        } else {
            $this->error('❌ Failed to register webhook');
            $this->error('Status Code: ' . $response->status());
            $this->error('Error Message: ' . ($response->json()['message'] ?? $response->body()));
            return 1;
        }
    }
}