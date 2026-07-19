import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/social_auth_service.dart';
import '../../../../core/network/token_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// ─────────────────────────────────────────────────────────────────
///  AuthBloc — Hybrid Firebase + Laravel Sanctum Authentication
///
///  EMAIL flow:
///    1. backend /api-auth/login                  → full UserModel + Sanctum token
///    2. TokenService.saveAuthSession(token, user) → persists user, notifies app
///
///  REGISTER flow:
///    1. backend /api-auth/register/send-otp      → OTP to email
///    2. backend /api-auth/register               → creates backend user
///    3. backend /api-auth/login                  → full UserModel + token
///    4. TokenService.saveAuthSession(token, user) → persists user, notifies app
///
///  SOCIAL flow (Google / Apple):
///    1. SocialAuthService.signInWithGoogle/Apple → Firebase session
///    2. backend /auth/firebase-sync              → Sanctum token
///    3. backend /account/profile                 → full backend UserModel
///    4. TokenService.saveAuthSession(token, user) → persists user, notifies app
///
///  LOGOUT:
///    1. backend /api-auth/logout                 → revoke Sanctum token
///    2. TokenService.clearAll()                  → Firebase signOut + clear prefs
///    → authUserChanges emits null → StreamBuilder rebuilds to LoginPage
/// ─────────────────────────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final fb.FirebaseAuth _firebaseAuth;
  final AuthRemoteDataSource _authRemoteDataSource;
  final TokenService _tokenService;

  AuthBloc({
    fb.FirebaseAuth? firebaseAuth,
    required AuthRemoteDataSource authRemoteDataSource,
    required TokenService tokenService,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _authRemoteDataSource = authRemoteDataSource,
        _tokenService = tokenService,
        super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterOtpRequested>(_onRegisterOtpRequested);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<VerifyOtpSubmitted>(_onVerifyOtpSubmitted);
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
    on<GoogleSignInSubmitted>(_onGoogleSignInSubmitted);
    on<AppleSignInSubmitted>(_onAppleSignInSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  // ── Email / Password Login ─────────────────────────────────────
  //
  //  BACKEND ONLY FLOW:
  //    1. backend /api-auth/login               → full UserModel + Sanctum token
  //    2. TokenService.saveAuthSession()        → persists user, notifies app
  // ──────────────────────────────────────────────────────────────
  String _extractErrorMessage(dynamic e) {
    if (e is fb.FirebaseAuthException) return _mapFirebaseError(e);
    if (e is ServerException) return e.message ?? 'server_error';
    if (e is UnauthorizedException) return e.message ?? 'error_invalid_credentials';
    if (e is ValidationException) return e.message ?? 'validation_error';
    if (e is ConnectionException) return e.message ?? 'error_connection';
    if (e is NotFoundException) return e.message ?? 'not_found';
    try {
      final dynamic msg = (e as dynamic).message;
      if (msg != null && msg.toString().isNotEmpty) {
        return msg.toString();
      }
    } catch (_) {}
    return e.toString();
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Step 1: Get full backend UserModel + Sanctum token
      final userModel = await _authRemoteDataSource.login(
        email: event.email.trim(),
        password: event.password,
      );

      final sanctumToken = userModel.token;
      if (sanctumToken == null || sanctumToken.isEmpty) {
        emit(const AuthError('backend_sync_failed'));
        return;
      }

      // Step 2: Persist full user + token, notify whole app
      await _tokenService.saveAuthSession(
        sanctumToken: sanctumToken,
        user: userModel,
      );

      emit(LoginSuccess(userModel));
    } catch (e) {
      developer.log('Login error: $e', name: 'AuthBloc');
      emit(AuthError(_extractErrorMessage(e)));
    }
  }

  // ── Register: Step 1 — Send Backend OTP ───────────────────────
  Future<void> _onRegisterOtpRequested(
    RegisterOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRemoteDataSource.sendRegisterOtp(email: event.email.trim());
      emit(const RegisterOtpSendSuccess());
    } catch (e) {
      developer.log('Send register OTP error: $e', name: 'AuthBloc');
      String msg = _extractErrorMessage(e);

      // If the email is already in use (possibly an unverified ghost account),
      // we automatically fallback to the forgot password flow to recover it.
      if (msg.contains('already been taken') ||
          msg.contains('already in use') ||
          msg.contains('has already been taken')) {
        try {
          await _authRemoteDataSource.sendForgotOtp(email: event.email.trim());
          emit(const RegisterOtpSendSuccess(isRecoveryFallback: true));
          return;
        } catch (_) {
          // If the fallback fails, emit the original email in use error
          emit(const AuthError('error_email_in_use'));
          return;
        }
      }

      emit(AuthError(msg));
    }
  }

  // ── Register: Step 2 — Create on backend ──────────
  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Step 2a: Register on backend (validates OTP, creates DB record)
      await _authRemoteDataSource.register(
        name: event.name.trim(),
        email: event.email.trim(),
        password: event.password,
        passwordConfirmation: event.password,
        otpCode: event.otpCode,
      );

      // Step 2b: Get full backend UserModel + Sanctum token via login
      final userModel = await _authRemoteDataSource.login(
        email: event.email.trim(),
        password: event.password,
      );

      final sanctumToken = userModel.token;
      if (sanctumToken == null || sanctumToken.isEmpty) {
        emit(const AuthError('backend_sync_failed'));
        return;
      }

      // Step 2c: Persist full user + token, notify whole app
      await _tokenService.saveAuthSession(
        sanctumToken: sanctumToken,
        user: userModel,
      );

      emit(RegisterSuccess(userModel));
    } catch (e) {
      developer.log('Register error: $e', name: 'AuthBloc');
      emit(AuthError(_extractErrorMessage(e)));
    }
  }

  // ── Forgot Password — sends backend OTP ───────────────────────
  //  On success the UI navigates to OtpVerificationPage(isPasswordReset: true).
  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRemoteDataSource.sendForgotOtp(email: event.email.trim());
      emit(ForgotPasswordSuccess());
    } catch (e) {
      developer.log('Forgot password error: $e', name: 'AuthBloc');
      emit(AuthError(_extractErrorMessage(e)));
    }
  }

  // ── OTP Verify (client-side pass-through) ─────────────────────
  //  Backend OTP validation happens during the reset step.
  //  This handler simply advances the UI state.
  Future<void> _onVerifyOtpSubmitted(
    VerifyOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(OtpVerificationSuccess(User(
      id: '',
      uuid: '',
      firstName: '',
      lastName: '',
      email: event.email,
      token: null,
    )));
  }

  // ── Reset Password — uses backend OTP ─────────────────────────
  //  The OTP comes from the Laravel backend.
  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Validate OTP and reset via backend
      await _authRemoteDataSource.resetPassword(
        email: event.email,
        otpCode: event.otpCode,
        newPassword: event.newPassword,
        passwordConfirmation: event.newPassword,
      );

      emit(ResetPasswordSuccess());
    } catch (e) {
      developer.log('Reset password error: $e', name: 'AuthBloc');
      emit(AuthError(_extractErrorMessage(e)));
    }
  }

  // ── Logout ─────────────────────────────────────────────────────
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRemoteDataSource.logout();
    } catch (_) {}
    // clearAll() → Firebase signOut + clears Sanctum token + cached user
    // → authUserChanges emits null → StreamBuilder in main.dart shows LoginPage
    await _tokenService.clearAll();
    emit(AuthInitial());
  }

  // ── Google Sign-In ─────────────────────────────────────────────
  //  DUAL AUTH FLOW (social):
  //    1. Firebase signIn via SocialAuthService
  //    2. /auth/firebase-sync  → Sanctum token
  //    3. /account/profile     → full backend UserModel
  //    4. TokenService.saveAuthSession() → persists user, notifies app
  // ──────────────────────────────────────────────────────────────
  Future<void> _onGoogleSignInSubmitted(
    GoogleSignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await SocialAuthService.signInWithGoogle();
    await result.fold(
      (failure) async {
        if (failure.message.contains('cancelled')) {
          emit(AuthInitial());
        } else {
          emit(AuthError(failure.message));
        }
      },
      (socialResult) async {
        final firebaseUser = socialResult.userCredential.user;
        if (firebaseUser == null) {
          emit(const AuthError('google_sign_in_failed'));
          return;
        }
        final user = await _syncSocialAndGetUser(firebaseUser);
        if (user == null) {
          await _firebaseAuth.signOut();
          emit(const AuthError('backend_sync_failed'));
          return;
        }
        emit(SocialLoginSuccess(user));
      },
    );
  }

  // ── Apple Sign-In ──────────────────────────────────────────────
  Future<void> _onAppleSignInSubmitted(
    AppleSignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await SocialAuthService.signInWithApple();
    await result.fold(
      (failure) async {
        if (failure.message.contains('cancelled')) {
          emit(AuthInitial());
        } else {
          emit(AuthError(failure.message));
        }
      },
      (socialResult) async {
        final firebaseUser = socialResult.userCredential.user;
        if (firebaseUser == null) {
          emit(const AuthError('apple_sign_in_failed'));
          return;
        }
        final user = await _syncSocialAndGetUser(firebaseUser);
        if (user == null) {
          await _firebaseAuth.signOut();
          emit(const AuthError('backend_sync_failed'));
          return;
        }
        emit(SocialLoginSuccess(user));
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  /// Syncs a social Firebase user with the backend and returns the full
  /// backend [UserModel]. Saves auth session so the whole app is notified.
  Future<User?> _syncSocialAndGetUser(fb.User firebaseUser) async {
    try {
      final idToken = await firebaseUser.getIdToken();
      if (idToken == null || idToken.isEmpty) return null;

      // Determine provider
      String provider = 'google';
      if (firebaseUser.providerData.isNotEmpty) {
        final provId = firebaseUser.providerData.first.providerId;
        if (provId.contains('apple')) provider = 'apple';
      }

      // Step 1: Get Sanctum token from backend firebase-sync endpoint
      final sanctumToken = await _authRemoteDataSource.socialLogin(
        provider: provider,
        token: idToken,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        firebaseUid: firebaseUser.uid,
      );

      // Temporarily save the token so /account/profile call below is authenticated
      await _tokenService.saveSanctumToken(sanctumToken);

      // Step 2: Fetch the full backend user (real backend id, avatar, etc.)
      UserModel backendUser;
      try {
        backendUser = await _authRemoteDataSource.getProfile();
        // Override token field since getProfile response doesn't include it
        backendUser = UserModel(
          id: backendUser.id,
          uuid: backendUser.uuid,
          firstName: backendUser.firstName,
          lastName: backendUser.lastName,
          email: backendUser.email,
          phone: backendUser.phone,
          avatar: backendUser.avatar,
          gender: backendUser.gender,
          birthDate: backendUser.birthDate,
          token: sanctumToken,
        );
      } catch (_) {
        // If profile fetch fails, build user from Firebase data as fallback
        final nameParts = (firebaseUser.displayName ?? '').trim().split(' ');
        backendUser = UserModel(
          id: firebaseUser.uid,
          uuid: firebaseUser.uid,
          firstName: nameParts.isNotEmpty ? nameParts.first : '',
          lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
          email: firebaseUser.email ?? '',
          token: sanctumToken,
        );
      }

      // Step 3: Persist full user + token — notifies whole app
      await _tokenService.saveAuthSession(
        sanctumToken: sanctumToken,
        user: backendUser,
      );

      return backendUser;
    } catch (e) {
      developer.log('Social sync failed: $e', name: 'AuthBloc');
      return null;
    }
  }

  String _mapFirebaseError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-email':
        return 'invalid_credentials';
      case 'email-already-in-use':
        return 'email_already_registered';
      case 'weak-password':
        return 'weak_password';
      case 'too-many-requests':
        return 'too_many_requests';
      case 'network-request-failed':
        return 'network_error';
      case 'user-disabled':
        return 'account_disabled';
      default:
        developer.log(
          'Unhandled Firebase error: ${e.code} — ${e.message}',
          name: 'AuthBloc',
        );
        return 'server_error';
    }
  }
}
