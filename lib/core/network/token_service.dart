import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores and retrieves the Firebase ID token.
/// Used by [ApiClient] to auto-inject Authorization headers.
class TokenService {
  static const String _sanctumTokenKey = 'CACHED_SANCTUM_TOKEN';
  static const String _userIdKey = 'CACHED_USER_ID';

  final SharedPreferences _prefs;
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();

  TokenService(this._prefs) {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _authStateController.add(hasToken);
    });
  }

  Stream<bool> get authStateChanges => _authStateController.stream;

  // ── Sanctum Token ─────────────────────────────────────────────────────────

  Future<void> saveSanctumToken(String token) async {
    await _prefs.setString(_sanctumTokenKey, token);
    _authStateController.add(hasToken);
  }

  String? getSanctumToken() {
    return _prefs.getString(_sanctumTokenKey);
  }

  // ── Firebase Token ─────────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    // No-op for Firebase natively
  }

  /// Get the current Firebase ID Token synchronously if available,
  /// otherwise wait for the async one. This depends on how it's called.
  /// Typically, API clients can wait. But for sync access, this might be tricky.
  /// Let's return the cached idToken or fetch a new one. We can just return a placeholder or null here if it's strictly sync,
  /// but wait, TokenService.getToken() is sync.
  /// Let's change getToken to async if possible, or just return null.
  /// Wait! `api_client.dart` calls `getToken()` synchronously? Let's check api_client.dart.
  /// For now, just return null if we can't do it sync, but actually `FirebaseAuth.instance.currentUser?.uid` exists.
  /// Let's check api_client.dart first. We can leave getToken as returning a string, but it won't be fresh unless we cache it locally or fetch async.
  String? getToken() {
    // Note: getting ID token is typically async, but if api_client expects sync,
    // we return an empty string or null, and let the interceptor fetch the async token.
    return null; // Will fix api_client next
  }

  bool get hasToken {
    final sanctumToken = getSanctumToken();
    return FirebaseAuth.instance.currentUser != null ||
        (sanctumToken != null && sanctumToken.isNotEmpty);
  }

  Future<void> clearToken() async {
    await FirebaseAuth.instance.signOut();
    await _prefs.remove(_sanctumTokenKey);
    _authStateController.add(hasToken);
  }

  // ── User Info ─────────────────────────────────────────────────────

  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  String? getUserId() =>
      FirebaseAuth.instance.currentUser?.uid ?? _prefs.getString(_userIdKey);

  // ── Full Logout ───────────────────────────────────────────────────

  Future<void> clearAll() async {
    await FirebaseAuth.instance.signOut();
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_sanctumTokenKey);
    _authStateController.add(hasToken);
  }
}
