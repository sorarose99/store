import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String otpCode;

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.otpCode,
  });

  @override
  List<Object?> get props => [name, email, password, otpCode];
}

class RegisterOtpRequested extends AuthEvent {
  final String email;

  const RegisterOtpRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordSubmitted extends AuthEvent {
  final String email;

  const ForgotPasswordSubmitted({required this.email});

  @override
  List<Object?> get props => [email];
}

class VerifyOtpSubmitted extends AuthEvent {
  final String email;
  final String otpCode;

  const VerifyOtpSubmitted({required this.email, required this.otpCode});

  @override
  List<Object?> get props => [email, otpCode];
}

class ResetPasswordSubmitted extends AuthEvent {
  final String email;
  final String otpCode;
  final String newPassword;

  const ResetPasswordSubmitted({
    required this.email,
    required this.otpCode,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, otpCode, newPassword];
}

class GoogleSignInSubmitted extends AuthEvent {
  const GoogleSignInSubmitted();
}

class AppleSignInSubmitted extends AuthEvent {
  const AppleSignInSubmitted();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
