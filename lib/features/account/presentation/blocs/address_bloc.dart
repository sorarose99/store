import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/address_repository.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository addressRepository;

  AddressBloc({required this.addressRepository}) : super(AddressInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<AddAddress>(_onAddAddress);
    on<UpdateAddress>(_onUpdateAddress);
    on<DeleteAddress>(_onDeleteAddress);
  }

  Future<void> _onLoadAddresses(
    LoadAddresses event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    final result = await addressRepository.getAddresses();
    result.fold(
      (failure) => emit(AddressError(failure.message)),
      (addresses) => emit(AddressLoaded(addresses)),
    );
  }

  Future<void> _onAddAddress(
    AddAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressActionLoading());
    final result = await addressRepository.addAddress(event.address);
    result.fold(
      (failure) => emit(AddressActionError(failure.message)),
      (newAddress) {
        emit(AddressActionSuccess('address_added_successfully'.tr()));
        add(LoadAddresses());
      },
    );
  }

  Future<void> _onUpdateAddress(
    UpdateAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressActionLoading());
    final result =
        await addressRepository.updateAddress(event.id, event.address);
    result.fold(
      (failure) => emit(AddressActionError(failure.message)),
      (updatedAddress) {
        emit(AddressActionSuccess('the_address_has_been'.tr()));
        add(LoadAddresses());
      },
    );
  }

  Future<void> _onDeleteAddress(
    DeleteAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressActionLoading());
    final result = await addressRepository.deleteAddress(event.id);
    result.fold(
      (failure) => emit(AddressActionError(failure.message)),
      (_) {
        emit(AddressActionSuccess('the_address_has_been_1'.tr()));
        add(LoadAddresses());
      },
    );
  }
}
