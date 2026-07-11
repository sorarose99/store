import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'API_BASE_URL', obfuscate: true)
  static final String apiBaseUrl = _Env.apiBaseUrl;

  @EnviedField(varName: 'TABBY_PUBLIC_KEY', obfuscate: true)
  static final String tabbyPublicKey = _Env.tabbyPublicKey;

  @EnviedField(varName: 'TABBY_API_KEY', obfuscate: true)
  static final String tabbyApiKey = _Env.tabbyApiKey;

  @EnviedField(varName: 'TABBY_SECRET_KEY', obfuscate: true)
  static final String tabbySecretKey = _Env.tabbySecretKey;

  @EnviedField(varName: 'TABBY_MERCHANT_CODE', obfuscate: true)
  static final String tabbyMerchantCode = _Env.tabbyMerchantCode;

  @EnviedField(varName: 'TAMARA_API_TOKEN', obfuscate: true)
  static final String tamaraApiToken = _Env.tamaraApiToken;

  @EnviedField(varName: 'TAMARA_NOTIFICATION_TOKEN', obfuscate: true)
  static final String tamaraNotificationToken = _Env.tamaraNotificationToken;

  @EnviedField(varName: 'TAMARA_PUBLIC_KEY', obfuscate: true)
  static final String tamaraPublicKey = _Env.tamaraPublicKey;

  @EnviedField(varName: 'PAYTABS_PROFILE_ID', obfuscate: true)
  static final String paytabsProfileId = _Env.paytabsProfileId;

  @EnviedField(varName: 'PAYTABS_SERVER_KEY', obfuscate: true)
  static final String paytabsServerKey = _Env.paytabsServerKey;

  @EnviedField(varName: 'PAYTABS_CLIENT_KEY', obfuscate: true)
  static final String paytabsClientKey = _Env.paytabsClientKey;
}
