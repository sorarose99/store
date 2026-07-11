import 'package:equatable/equatable.dart';

abstract class ApiValidationState extends Equatable {
  const ApiValidationState();

  @override
  List<Object> get props => [];
}

class ApiValidationInitial extends ApiValidationState {}

class ApiValidationLoading extends ApiValidationState {}

class ApiValidationSuccess extends ApiValidationState {}

class ApiValidationFailure extends ApiValidationState {
  final String message;

  const ApiValidationFailure({required this.message});

  @override
  List<Object> get props => [message];
}
