<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;

use App\Models\Wishlist;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class WishlistController extends Controller
{
    /**
     * عرض صفحة المفضلة
     */
    public function index()
    {
        $user = Auth::user();

        $wishlists = Wishlist::where('user_id', $user->id)
            ->with([
                'product' => function ($q) {
                    $q->select(
                        'id',
                        'name_ar',
                        'name_en',
                        'slug',
                        'price',
                        'sale_price',
                        'new',
                        'featured'
                    )->with([
                        'images' => function ($q) {
                            $q->select('id', 'product_id', 'path', 'is_primary');
                        }
                    ])->withCount('reviews')
                        ->withAvg('reviews', 'rating');
                }
            ])
            ->latest('created_at')
            ->paginate(15);
        return response()->json([
            'success' => true,
            'wishlists' => $wishlists,
        ]);
    }

    //اضافة او ازالة المنتج من المفضلة
    public function toggle(Request $request)
    {
        if (!Auth::check()) {
            return response()->json([
                'status' => 'error',
                'message' => __('messages.please_login_first')
            ], 401);
        }

        $request->validate([
            'product_id' => 'required|exists:products,id'
        ]);

        $user = Auth::user();

        // If the product is already in wishlist it will be removed, otherwise it will be added
        $result = $user->wishlistProducts()->toggle($request->product_id);

        if (count($result['attached'])) {
            return response()->json([
                'status' => 'added',
                'message' => __('messages.product_added_to_wishlist')
            ]);
        }

        return response()->json([
            'status' => 'removed',
            'message' => __('messages.product_removed_from_wishlist')
        ]);
    }
}
