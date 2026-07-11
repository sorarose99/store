<?php

namespace App\Models;

use App\Traits\SanitizesInput;
use Illuminate\Database\Eloquent\Factories\HasFactory;

use Illuminate\Database\Eloquent\Model;

class ContactMessage extends Model
{
    use HasFactory, SanitizesInput;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'type',
        'subject',
        'message',
        'is_read',
        'read_at',
    ];
    protected $sanitize = [
        'name',
        'email',
        'phone',
        'type',
        'subject',
        'message',
    ];

    protected function casts(): array
    {
        return [
            'read_at'  => 'datetime',
            'is_read'  => 'boolean',
        ];
    }
}
