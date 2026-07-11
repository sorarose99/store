import 'package:equatable/equatable.dart';
import '../../domain/entities/account_entities.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final UserEntity user;
  final DashboardStatsEntity stats;
  final List<OrderEntity> recentOrders;

  const AccountLoaded({
    required this.user,
    required this.stats,
    required this.recentOrders,
  });

  @override
  List<Object?> get props => [user, stats, recentOrders];
}

class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountActionLoading extends AccountState {}

class AccountActionSuccess extends AccountState {
  final String message;

  const AccountActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AccountActionError extends AccountState {
  final String message;

  const AccountActionError({required this.message});

  @override
  List<Object?> get props => [message];
}
