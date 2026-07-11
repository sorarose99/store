<?php

namespace App\Mail;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class OrderStatusMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(public Order $order) {}

    public function build()
    {
        return $this->from(
            config('services.no-reply.email'),
            config('app.name')
        )
            ->subject('تحديث حالة الطلب'.' - '.$this->order->order_number)
            ->view('emails.order-status');
    }
}
