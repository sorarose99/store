<?php

namespace App\Mail;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class NewOrderAdminMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(public Order $order) {}

    public function build()
    {
        return $this->from(
            config('services.billing.email'),
            config('app.name')
        )
        ->subject('طلب جديد - ' . $this->order->order_number)
        ->view('emails.new-order-admin');
    }
}