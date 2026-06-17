import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String phoneNumber;
  final String password;

  const LoginSubmitted({required this.phoneNumber, required this.password});

  @override
  List<Object?> get props => [phoneNumber, password];
}

class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, phoneNumber, password];
}

class ForgotPasswordSubmitted extends AuthEvent {
  final String phoneNumber;

  const ForgotPasswordSubmitted({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOtpSubmitted extends AuthEvent {
  final String phoneNumber;
  final String otpCode;

  const VerifyOtpSubmitted({required this.phoneNumber, required this.otpCode});

  @override
  List<Object?> get props => [phoneNumber, otpCode];
}

class ResetPasswordSubmitted extends AuthEvent {
  final String phoneNumber;
  final String newPassword;

  const ResetPasswordSubmitted({required this.phoneNumber, required this.newPassword});

  @override
  List<Object?> get props => [phoneNumber, newPassword];
}
