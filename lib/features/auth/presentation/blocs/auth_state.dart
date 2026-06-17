import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class LoginSuccess extends AuthState {
  final User user;
  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class RegisterSuccess extends AuthState {
  final User user;
  const RegisterSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class ForgotPasswordSuccess extends AuthState {}

class OtpVerificationSuccess extends AuthState {
  final User user;
  const OtpVerificationSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class ResetPasswordSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
