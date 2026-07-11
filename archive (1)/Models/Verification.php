<?php

namespace App\Models;

use App\Traits\SanitizesInput;
use Illuminate\Database\Eloquent\Model;

class Verification extends Model
{
    use SanitizesInput;

    protected $fillable = [
        'target',
        'type',
        'code',
        'expires_at',
        'attempts',
    ];

    protected $sanitize = [
        'code',
        'attempts',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'expires_at' => 'datetime',
    ];
}
