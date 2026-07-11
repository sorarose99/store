<?php

namespace App\Mail;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class OrderPaidMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(public Order $order) {}

    /**
     * Build the message.
     */
    public function build()
    {
        return $this->from(
            config('services.billing.email'),
            config('app.name')
        )
            ->subject(__('user_interface.confirm_order').' - '.$this->order->order_number)
            ->view('emails.order-paid');
    }
}
