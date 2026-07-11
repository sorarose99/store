<?php

namespace App\Models;

use App\Traits\SanitizesInput;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ShippingZone extends Model
{
    use HasFactory, SanitizesInput;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'country_code',
        'shipping_provider',
        'default_address',
        'tax_rate',
        'status',
    ];
    protected $sanitize = [
        'name',
        'country_code',
        'shipping_provider',
        'default_address',
        'tax_rate',
    ];


    /**
     * العلاقات
     */

    // أسعار الشحن
    public function rates()
    {
        return $this->hasMany(ShippingRate::class);
    }

}
