<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class SendOtpMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(public string $otp) {}

    /**
     * Build the message.
     */
    public function build()
    {
        return $this->from(
            config('services.no-reply.email'),
            config('app.name')
        )
            ->subject(__('user_interface.otp'))
            ->view('emails.send-otp');
    }
}
