<?php

namespace App\Models;

use App\Traits\SanitizesInput;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ShippingRate extends Model
{
    use HasFactory, SanitizesInput;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'zone_id',
        'weight_from',
        'weight_to',
        'cost',
    ];
    protected $sanitize = [
        'weight_from',
        'weight_to',
        'cost',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'weight_from' => 'decimal:2',
        'weight_to' => 'decimal:2',
        'cost' => 'decimal:2',
    ];

    /**
     * العلاقات
     */

    // منطقة الشحن
    public function zone()
    {
        return $this->belongsTo(ShippingZone::class);
    }

}