<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PaymentGateway extends Model
{
    protected $fillable = [
        'name',
        'is_active',
        'mode',
        'credentials',
        'currency',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'credentials' => 'array',
    ];
}
