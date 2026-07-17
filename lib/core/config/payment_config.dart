import 'env.dart';

/// Payment gateway public configuration (safe for mobile).
/// Secret keys / server keys must NEVER be stored here.
class PaymentConfig {
  PaymentConfig._();

  static String get tabbyPublicKey => Env.tabbyPublicKey;
  static String get tabbyMerchantCode => Env.tabbyMerchantCode.isNotEmpty ? Env.tabbyMerchantCode : 'KDFW';

  static String get tamaraPublicKey => Env.tamaraPublicKey;

  static String get paytabsProfileId => Env.paytabsProfileId;
  static String get paytabsClientKey => Env.paytabsClientKey;

  static String get storeBaseUrl =>
      Env.apiBaseUrl.replaceAll(RegExp(r'/api$'), '');

  static bool get isTabbyConfigured =>
      tabbyPublicKey.isNotEmpty && tabbyMerchantCode.isNotEmpty;
}
