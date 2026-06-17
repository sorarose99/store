import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _tokenKey = 'CACHED_AUTH_TOKEN';

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheToken(String token) async {
    await sharedPreferences.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(_tokenKey);
  }

  @override
  Future<void> clear() async {
    await sharedPreferences.remove(_tokenKey);
  }
}
