import 'package:equatable/equatable.dart';
import '../../domain/entities/delivery_option.dart';

abstract class DeliveryOptionsState extends Equatable {
  const DeliveryOptionsState();

  @override
  List<Object?> get props => [];
}

class DeliveryOptionsInitial extends DeliveryOptionsState {}

class DeliveryOptionsLoading extends DeliveryOptionsState {}

class DeliveryOptionsLoaded extends DeliveryOptionsState {
  final List<DeliveryOption> options;
  final DeliveryOption? selectedOption;

  const DeliveryOptionsLoaded({
    required this.options,
    this.selectedOption,
  });

  DeliveryOptionsLoaded copyWith({
    List<DeliveryOption>? options,
    DeliveryOption? selectedOption,
  }) {
    return DeliveryOptionsLoaded(
      options: options ?? this.options,
      selectedOption: selectedOption ?? this.selectedOption,
    );
  }

  @override
  List<Object?> get props => [options, selectedOption];
}

class DeliveryOptionsError extends DeliveryOptionsState {
  final String message;

  const DeliveryOptionsError(this.message);

  @override
  List<Object?> get props => [message];
}
