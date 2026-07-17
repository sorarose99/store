import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/social_auth_service.dart';
import '../../../../core/network/token_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// ─────────────────────────────────────────────────────────────────
///  AuthBloc — Combined Firebase & Sanctum Backend Authentication
///
///  Authenticates user sessions in Firebase, then synchronizes
///  with the legacy Laravel/Sanctum backend to cache a Sanctum API token.
///  This allows wishlist and cart features to function correctly.
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
  }

  /// Synchronizes a signed-in Firebase user with the Laravel backend
  /// by calling the socialLogin API with the Firebase ID token.
  Future<String?> _syncWithBackend(fb.User firebaseUser) async {
    try {
      final token = await firebaseUser.getIdToken();
      if (token == null || token.isEmpty) return null;

      final name = firebaseUser.displayName ?? '';
      final email = firebaseUser.email ?? '';
      
      // Determine provider name (google, apple, etc.)
      String provider = 'google';
      if (firebaseUser.providerData.isNotEmpty) {
        final provId = firebaseUser.providerData.first.providerId;
        if (provId.contains('apple')) {
          provider = 'apple';
        }
      }

      final sanctumToken = await _authRemoteDataSource.socialLogin(
        provider: provider,
        token: token,
        name: name,
        email: email,
      );
      
      await _tokenService.saveSanctumToken(sanctumToken);
      await _tokenService.saveUserId(firebaseUser.uid);
      return sanctumToken;
    } catch (e) {
      developer.log('Backend sync failed: $e', name: 'AuthBloc');
      return null;
    }
  }

  // ── Email / Password Login ─────────────────────────────────────
  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        emit(const AuthError('login_failed'));
        return;
      }

      // Sync with the legacy backend
      final sanctumToken = await _syncWithBackend(firebaseUser);
      if (sanctumToken == null) {
        await _firebaseAuth.signOut();
        emit(const AuthError('backend_sync_failed'));
        return;
      }

      emit(LoginSuccess(_userFromFirebase(firebaseUser, token: sanctumToken)));
    } on fb.FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (e) {
      developer.log('Login error: $e', name: 'AuthBloc');
      emit(const AuthError('server_error'));
    }
  }

  // ── Register: Step 1 — No OTP needed with Firebase ────────────
  /// We skip the backend OTP step entirely.
  /// Instead we go directly to RegisterSubmitted.
  Future<void> _onRegisterOtpRequested(
    RegisterOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(RegisterOtpSendSuccess());
  }

  // ── Register: Create Account with Firebase ─────────────────────
  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        emit(const AuthError('register_failed'));
        return;
      }

      // Set the display name from the form
      if (event.name.trim().isNotEmpty) {
        await firebaseUser.updateDisplayName(event.name.trim());
        await firebaseUser.reload();
      }

      final updatedUser = _firebaseAuth.currentUser ?? firebaseUser;

      // Sync with the legacy backend
      final sanctumToken = await _syncWithBackend(updatedUser);
      if (sanctumToken == null) {
        await _firebaseAuth.signOut();
        emit(const AuthError('backend_sync_failed'));
        return;
      }

      // Send verification email (non-blocking)
      try {
        await updatedUser.sendEmailVerification();
      } catch (_) {
        // Ignore email sending failures
      }

      emit(RegisterSuccess(_userFromFirebase(updatedUser, token: sanctumToken)));
    } on fb.FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (e) {
      developer.log('Register error: $e', name: 'AuthBloc');
      emit(const AuthError('server_error'));
    }
  }

  // ── Forgot Password — Firebase sends reset email ───────────────
  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: event.email.trim(),
      );
      emit(ForgotPasswordSuccess());
    } on fb.FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (e) {
      developer.log('Forgot password error: $e', name: 'AuthBloc');
      emit(const AuthError('server_error'));
    }
  }

  // ── OTP Verify ───────────────────────────────────────────────
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

  // ── Reset Password ────────────────────────────────────────────
  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.confirmPasswordReset(
        code: event.otpCode,
        newPassword: event.newPassword,
      );
      emit(ResetPasswordSuccess());
    } on fb.FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (e) {
      emit(const AuthError('server_error'));
    }
  }

  // ── Google Sign-In ─────────────────────────────────────────────
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

        // Sync with backend
        final sanctumToken = await _syncWithBackend(firebaseUser);
        if (sanctumToken == null) {
          await _firebaseAuth.signOut();
          emit(const AuthError('backend_sync_failed'));
          return;
        }

        emit(SocialLoginSuccess(_userFromFirebase(firebaseUser, token: sanctumToken)));
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

        // Sync with backend
        final sanctumToken = await _syncWithBackend(firebaseUser);
        if (sanctumToken == null) {
          await _firebaseAuth.signOut();
          emit(const AuthError('backend_sync_failed'));
          return;
        }

        emit(SocialLoginSuccess(_userFromFirebase(firebaseUser, token: sanctumToken)));
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  User _userFromFirebase(fb.User firebaseUser, {String? token}) {
    final nameParts = (firebaseUser.displayName ?? '').trim().split(' ');
    return User(
      id: firebaseUser.uid,
      uuid: firebaseUser.uid,
      firstName: nameParts.isNotEmpty ? nameParts.first : '',
      lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
      email: firebaseUser.email ?? '',
      token: token ?? _tokenService.getSanctumToken(),
    );
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
        developer.log('Unhandled Firebase error: ${e.code} — ${e.message}', name: 'AuthBloc');
        return 'server_error';
    }
  }
}
