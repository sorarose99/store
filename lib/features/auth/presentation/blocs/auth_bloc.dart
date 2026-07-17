import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/social_auth_service.dart';
import '../../domain/entities/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// ─────────────────────────────────────────────────────────────────
///  AuthBloc — Firebase-Only Authentication
///
///  All auth operations (login, register, forgot-password, social)
///  are handled directly by Firebase Auth. The Laravel/Sanctum
///  backend is NOT used for authentication.
///
///  Shopping features (cart, orders, wishlist) still call the
///  backend using the Firebase ID token as a Bearer token.
/// ─────────────────────────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final fb.FirebaseAuth _firebaseAuth;

  AuthBloc({fb.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
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

      emit(LoginSuccess(_userFromFirebase(firebaseUser)));
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
    // Firebase doesn't need a prior OTP step — emit success so the
    // UI navigates to the name/password step (OtpVerificationPage
    // will be repurposed or skipped — see register_page.dart).
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

      // Send verification email (non-blocking)
      try {
        await firebaseUser.sendEmailVerification();
      } catch (_) {
        // Not critical — ignore
      }

      emit(RegisterSuccess(_userFromFirebase(_firebaseAuth.currentUser ?? firebaseUser)));
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

  // ── OTP Verify — not used for Firebase email flow ─────────────
  /// Kept for compatibility. With Firebase, this step is skipped.
  Future<void> _onVerifyOtpSubmitted(
    VerifyOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    // Not used in Firebase flow — emit a placeholder success
    emit(OtpVerificationSuccess(User(
      id: '',
      uuid: '',
      firstName: '',
      lastName: '',
      email: event.email,
      token: null,
    )));
  }

  // ── Reset Password — Firebase handles via email link ──────────
  /// Firebase reset is email-link based (no OTP code entry needed).
  /// This handler remains for UI compatibility but is effectively
  /// replaced by sendPasswordResetEmail in _onForgotPasswordSubmitted.
  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Confirm the password reset using the code Firebase sent via email
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
    result.fold(
      (failure) {
        // User cancelled — go back to initial silently
        if (failure.message.contains('cancelled')) {
          emit(AuthInitial());
        } else {
          emit(AuthError(failure.message));
        }
      },
      (socialResult) {
        final firebaseUser = socialResult.userCredential.user;
        if (firebaseUser == null) {
          emit(const AuthError('google_sign_in_failed'));
          return;
        }
        // No backend sync needed — Firebase user session is enough
        emit(SocialLoginSuccess(_userFromFirebase(firebaseUser)));
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
    result.fold(
      (failure) {
        if (failure.message.contains('cancelled')) {
          emit(AuthInitial());
        } else {
          emit(AuthError(failure.message));
        }
      },
      (socialResult) {
        final firebaseUser = socialResult.userCredential.user;
        if (firebaseUser == null) {
          emit(const AuthError('apple_sign_in_failed'));
          return;
        }
        emit(SocialLoginSuccess(_userFromFirebase(firebaseUser)));
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  User _userFromFirebase(fb.User firebaseUser) {
    final nameParts = (firebaseUser.displayName ?? '').trim().split(' ');
    return User(
      id: firebaseUser.uid,
      uuid: firebaseUser.uid,
      firstName: nameParts.isNotEmpty ? nameParts.first : '',
      lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
      email: firebaseUser.email ?? '',
      token: null, // No Sanctum token needed
    );
  }

  /// Maps Firebase error codes to translation keys used in error_handler.dart.
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
