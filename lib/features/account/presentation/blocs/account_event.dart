import 'package:equatable/equatable.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class AccountProfileRequested extends AccountEvent {
  const AccountProfileRequested();
}

class AccountUpdateProfileRequested extends AccountEvent {
  final Map<String, dynamic> data;

  const AccountUpdateProfileRequested(this.data);

  @override
  List<Object?> get props => [data];
}

class AccountChangePasswordRequested extends AccountEvent {
  final String currentPassword;
  final String newPassword;

  const AccountChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class AccountDeleteRequested extends AccountEvent {
  final String password;

  const AccountDeleteRequested({required this.password});

  @override
  List<Object?> get props => [password];
}

class AccountSaveFcmRequested extends AccountEvent {
  final String token;
  final String deviceId;
  final String? platform;
  final String? deviceName;

  const AccountSaveFcmRequested({
    required this.token,
    required this.deviceId,
    this.platform,
    this.deviceName,
  });

  @override
  List<Object?> get props => [token, deviceId, platform, deviceName];
}
