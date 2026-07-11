<?php

namespace App\Models;

use App\Traits\SanitizesInput;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    use HasFactory, SanitizesInput;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'type',
        'audience',
        'related_id',
        'title',
        'message',
        'user_id',
        'is_read',
        'read_at',
    ];

    protected $sanitize = [
        'type',
        'audience',
        'title',
        'message',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'read_at' => 'datetime',
        'is_read' => 'boolean',
    ];

}
