<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Wishlist extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'product_id',
    ];

    /**
     * العلاقات
     */

    // المستخدم
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // المنتج
    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}