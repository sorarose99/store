/// ─────────────────────────────────────────────────────────────────
///  KDX Store — API Endpoint Constants
///
///  All endpoints match routes in /routes/api.php on the server.
///  Change [baseUrl] to switch between dev and production.
/// ─────────────────────────────────────────────────────────────────
class ApiEndpoints {
  ApiEndpoints._();

  // ── Base URL ─────────────────────────────────────────────────────
  /// 🌐 Change this one constant to switch environments:
  static const String baseUrl = 'https://kdx-sa.com/api';

  /// 🖼️ Media Base URL resolver
  static String mediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('/')) {
      return 'https://kdx-sa.com$path';
    }
    return 'https://kdx-sa.com/$path';
  }

  // ── Auth (/api-auth/) ─────────────────────────────────────────────
  static const String sendRegisterOtp = '/api-auth/register/send-otp';
  static const String register = '/api-auth/register';
  static const String login = '/api-auth/login';
  static const String socialLogin = '/api-auth/social-login';
  static const String logout = '/api-auth/logout';
  static const String sendForgotOtp = '/api-auth/forgot-password/send-otp';
  static const String resetPassword = '/api-auth/forgot-password/reset';

  // ── Home ─────────────────────────────────────────────────────────
  static const String home = '/';

  // ── Shop ─────────────────────────────────────────────────────────
  static const String shop = '/shop';
  static const String categories = '/categories';

  /// Usage: ApiEndpoints.category('shoes')
  static String category(String slug) => '/shop?category_name=$slug';

  /// Usage: ApiEndpoints.categoryDetails('shoes')
  static String categoryDetails(String slug) => '/shop/category/$slug';

  /// Usage: ApiEndpoints.categoryProducts('men, jackets')
  static String categoryProducts(String main, String sub) =>
      '/shop/category/$main/$sub/products';

  /// Usage: ApiEndpoints.product('cool-sneaker')
  static String product(String slug) => '/shop/product/$slug';

  /// Usage: ApiEndpoints.productReviews('cool-sneaker')
  static String productReviews(String slug) => '/shop/product/$slug/reviews';

  // ── Cart (/cart/) ─────────────────────────────────────────────────
  static const String cart = '/cart';
  static const String cartAdd = '/cart/add';
  static const String cartClear = '/cart/clear';
  static const String cartCount = '/cart/count';
  static const String cartCheckout = '/cart/checkout';
  static const String cartCoupon = '/cart/coupon';
  static const String cartRemoveCoupon = '/cart/remove-coupon';
  static const String cartShippingZone = '/cart/update-shipping-zone';

  /// Usage: ApiEndpoints.cartUpdate(42)
  static String cartUpdate(String productId) => '/cart/update/$productId';
  static String cartRemove(String productId) => '/cart/remove/$productId';
  static String cartBreakdown(String productId) => '/cart/breakdown/$productId';

  // ── Account (/account/) ──────────────────────────────────────────
  static const String myAccount = '/account';
  static const String profile = '/account/profile';
  static const String changePassword = '/account/change-password';
  static const String deleteAccount = '/account/destroy';
  static const String notifications = '/account/notifications';

  // ── Addresses (/addresses/) ──────────────────────────────────────
  static const String addresses = '/addresses';
  static const String addressStore = '/addresses/store';

  static String addressEdit(String id) => '/addresses/$id/edit';
  static String addressUpdate(String id) => '/addresses/$id/update';
  static String addressDelete(String id) => '/addresses/$id/destroy';

  // ── Wishlist (/wishlist/) ─────────────────────────────────────────
  static const String wishlist = '/wishlist';
  static const String wishlistToggle = '/wishlist/toggle';

  // ── Orders (/orders/) ─────────────────────────────────────────────
  static const String orders = '/orders';
  static const String addReview = '/orders/reviews';

  static String orderDetail(String num) => '/orders/$num';
  static String cancelOrder(String num) => '/orders/$num/cancel';
  static String orderInvoice(String num) => '/orders/$num/invoice';

  // ── Payments (/payments/) ─────────────────────────────────────────
  static const String paytabsPay = '/payments/paytabs/pay';
  static const String paytabsCallback = '/payments/paytabs/callback';
  static const String tabbyWebhook = '/payments/tabby/webhook';

  // ── SMS / OTP (/sms/) ─────────────────────────────────────────────
  static const String smsSend = '/sms/send';
  static const String otpSend = '/sms/otp/send';
  static const String otpVerify = '/sms/otp/verify';

  // ── Firebase ──────────────────────────────────────────────────────
  static const String saveFcmToken = '/api-save-fcm-token';
}
