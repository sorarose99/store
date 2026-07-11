import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/social_auth_service.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/send_register_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/social_login_usecase.dart';
import '../../domain/entities/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/token_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final SendRegisterOtpUseCase sendRegisterOtpUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final SocialLoginUseCase socialLoginUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.sendRegisterOtpUseCase,
    required this.forgotPasswordUseCase,
    required this.verifyOtpUseCase,
    required this.resetPasswordUseCase,
    required this.socialLoginUseCase,
  }) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterOtpRequested>(_onRegisterOtpRequested);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<VerifyOtpSubmitted>(_onVerifyOtpSubmitted);
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
    on<GoogleSignInSubmitted>(_onGoogleSignInSubmitted);
    on<AppleSignInSubmitted>(_onAppleSignInSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUseCase(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );
    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (user) async {
        if (user.token != null && user.token!.isNotEmpty) {
          final tokenSvc = sl<TokenService>();
          await tokenSvc.saveSanctumToken(user.token!);
        }
        emit(LoginSuccess(user));
      },
    );
  }

  Future<void> _onRegisterOtpRequested(
    RegisterOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await sendRegisterOtpUseCase(
      SendRegisterOtpParams(email: event.email),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(RegisterOtpSendSuccess()),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await registerUseCase(
      RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
        otpCode: event.otpCode,
      ),
    );
    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (user) async {
        if (user.token != null && user.token!.isNotEmpty) {
          final tokenSvc = sl<TokenService>();
          await tokenSvc.saveSanctumToken(user.token!);
        }
        emit(RegisterSuccess(user));
      },
    );
  }

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await forgotPasswordUseCase(
      ForgotPasswordParams(email: event.email),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(ForgotPasswordSuccess()),
    );
  }

  Future<void> _onVerifyOtpSubmitted(
    VerifyOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await verifyOtpUseCase(
      VerifyOtpParams(
        email: event.email,
        otpCode: event.otpCode,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(OtpVerificationSuccess(user)),
    );
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await resetPasswordUseCase(
      ResetPasswordParams(
        email: event.email,
        otpCode: event.otpCode,
        newPassword: event.newPassword,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(ResetPasswordSuccess()),
    );
  }

  Future<void> _onGoogleSignInSubmitted(
    GoogleSignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final googleRes = await SocialAuthService.signInWithGoogle();
    await googleRes.fold(
      (failure) async => emit(AuthError(failure.message)),
      (result) async {
        if (result.userCredential.user != null) {
          try {
            final firebaseUser = result.userCredential.user!;
            final name = firebaseUser.displayName ?? '';
            final email = firebaseUser.email ?? '';
            final uid = firebaseUser.uid;
            final token = result.providerToken;

            // Sync with backend to get Sanctum token
            final authDataSource = sl<AuthRemoteDataSource>();
            final sanctumToken = await authDataSource.socialLogin(
              provider: 'google',
              token: token,
              email: email,
              name: name,
            );

            // Save token
            final tokenSvc = sl<TokenService>();
            await tokenSvc.saveSanctumToken(sanctumToken);

            emit(SocialLoginSuccess(
              User(
                id: uid,
                uuid: uid,
                firstName: name,
                lastName: '',
                email: email,
                token: sanctumToken,
              ),
            ));
          } catch (e) {
            emit(AuthError('Backend sync failed: $e'));
          }
        } else {
          emit(const AuthError('Google Sign-In failed'));
        }
      },
    );
  }

  Future<void> _onAppleSignInSubmitted(
    AppleSignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final appleRes = await SocialAuthService.signInWithApple();
    await appleRes.fold(
      (failure) async => emit(AuthError(failure.message)),
      (result) async {
        if (result.userCredential.user != null) {
          try {
            final firebaseUser = result.userCredential.user!;
            final name = firebaseUser.displayName ?? '';
            final email = firebaseUser.email ?? '';
            final uid = firebaseUser.uid;
            final token = result.providerToken;

            // Sync with backend to get Sanctum token
            final authDataSource = sl<AuthRemoteDataSource>();
            final sanctumToken = await authDataSource.socialLogin(
              provider: 'apple',
              token: token,
              email: email,
              name: name,
            );

            // Save token
            final tokenSvc = sl<TokenService>();
            await tokenSvc.saveSanctumToken(sanctumToken);

            emit(SocialLoginSuccess(
              User(
                id: uid,
                uuid: uid,
                firstName: name,
                lastName: '',
                email: email,
                token: sanctumToken,
              ),
            ));
          } catch (e) {
            emit(AuthError('Backend sync failed: $e'));
          }
        } else {
          emit(const AuthError('Apple Sign-In failed'));
        }
      },
    );
  }
}
