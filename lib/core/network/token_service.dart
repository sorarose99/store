import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/entities/user.dart';

/// ─────────────────────────────────────────────────────────────────────────
///  TokenService — Hybrid Auth State Manager
///
///  Stores BOTH the Firebase session AND the Laravel Sanctum token.
///  Also caches the full backend User object so the entire app can access
///  the active user without redundant API calls.
///
///  authUserChanges stream emits:
///    • null  → user is logged out
///    • User  → user is logged in (full backend data)
/// ─────────────────────────────────────────────────────────────────────────
class TokenService {
  static const String _sanctumTokenKey = 'CACHED_SANCTUM_TOKEN';
  static const String _userIdKey       = 'CACHED_USER_ID';
  static const String _cachedUserKey   = 'CACHED_USER_JSON';

  final SharedPreferences _prefs;
  final StreamController<User?> _authUserController =
      StreamController<User?>.broadcast();

  TokenService(this._prefs) {
    // Mirror Firebase auth state changes so the app reacts to external
    // sign-outs (e.g., token revoked by Firebase console).
    fb.FirebaseAuth.instance.authStateChanges().listen((fbUser) {
      if (fbUser == null) {
        // Firebase signed out externally — clear everything.
        _clearLocalUser();
        _authUserController.add(null);
      } else {
        // Firebase still signed in — emit the cached user if available.
        final cached = currentUser;
        _authUserController.add(cached);
      }
    });
  }

  // ── Auth User Stream ───────────────────────────────────────────────────────

  /// Stream of the active [User]. Emits null when logged out.
  /// Listen to this in your root [StreamBuilder] to react to auth changes.
  Stream<User?> get authUserChanges => _authUserController.stream;

  /// Legacy bool stream for backwards compat (wraps authUserChanges).
  Stream<bool> get authStateChanges =>
      _authUserController.stream.map((u) => u != null);

  // ── Current User (sync) ───────────────────────────────────────────────────

  /// Returns the cached backend [User], or null if not logged in.
  User? get currentUser {
    final json = _prefs.getString(_cachedUserKey);
    if (json == null || json.isEmpty) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return _userFromMap(map);
    } catch (_) {
      return null;
    }
  }

  // ── Save / Clear User ─────────────────────────────────────────────────────

  /// Called after every successful login, register, or social sign-in.
  /// Saves the Sanctum token, the user object, and notifies the whole app.
  Future<void> saveAuthSession({
    required String sanctumToken,
    required User user,
  }) async {
    await _prefs.setString(_sanctumTokenKey, sanctumToken);
    await _prefs.setString(_userIdKey, user.id);
    await _prefs.setString(_cachedUserKey, jsonEncode(_userToMap(user)));
    _authUserController.add(user);
  }

  /// Updates the cached user object (e.g. after profile update) without
  /// changing the Sanctum token or Firebase session.
  Future<void> updateCachedUser(User user) async {
    await _prefs.setString(_cachedUserKey, jsonEncode(_userToMap(user)));
    _authUserController.add(user);
  }

  // ── Sanctum Token ─────────────────────────────────────────────────────────

  Future<void> saveSanctumToken(String token) async {
    await _prefs.setString(_sanctumTokenKey, token);
    // Emit current user so the app stays in sync (used during auto-refresh).
    _authUserController.add(currentUser);
  }

  String? getSanctumToken() => _prefs.getString(_sanctumTokenKey);

  // ── Legacy / Compat ───────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {}   // No-op (Firebase native)
  String?      getToken()              => null;    // Use getSanctumToken()

  bool get hasToken {
    final sanctumToken = getSanctumToken();
    final hasSanctum = sanctumToken != null && sanctumToken.isNotEmpty;
    return fb.FirebaseAuth.instance.currentUser != null && hasSanctum;
  }

  Future<void> saveUserId(String userId) async =>
      _prefs.setString(_userIdKey, userId);

  String? getUserId() =>
      fb.FirebaseAuth.instance.currentUser?.uid ?? _prefs.getString(_userIdKey);

  // ── Full Logout ───────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await fb.FirebaseAuth.instance.signOut();
    _clearLocalUser();
    _authUserController.add(null);
  }

  Future<void> clearToken() async => clearAll();

  void _clearLocalUser() {
    _prefs.remove(_sanctumTokenKey);
    _prefs.remove(_userIdKey);
    _prefs.remove(_cachedUserKey);
  }

  // ── Serialization helpers ─────────────────────────────────────────────────

  Map<String, dynamic> _userToMap(User u) => {
    'id':         u.id,
    'uuid':       u.uuid,
    'firstName':  u.firstName,
    'lastName':   u.lastName,
    'email':      u.email,
    'phone':      u.phone,
    'avatar':     u.avatar,
    'gender':     u.gender,
    'birthDate':  u.birthDate,
    'token':      u.token,
  };

  User _userFromMap(Map<String, dynamic> m) => User(
    id:        m['id']?.toString()        ?? '',
    uuid:      m['uuid']?.toString()      ?? '',
    firstName: m['firstName']?.toString() ?? '',
    lastName:  m['lastName']?.toString()  ?? '',
    email:     m['email']?.toString(),
    phone:     m['phone']?.toString(),
    avatar:    m['avatar']?.toString(),
    gender:    m['gender']?.toString(),
    birthDate: m['birthDate']?.toString(),
    token:     m['token']?.toString(),
  );
}
