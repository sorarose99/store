import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';
import '../../domain/usecases/save_fcm_token_usecase.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetProfileUseCase getProfileUseCase;
  final GetDashboardUseCase getDashboardUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final SaveFcmTokenUseCase saveFcmTokenUseCase;

  AccountBloc({
    required this.getProfileUseCase,
    required this.getDashboardUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
    required this.deleteAccountUseCase,
    required this.saveFcmTokenUseCase,
  }) : super(AccountInitial()) {
    on<AccountProfileRequested>(_onAccountProfileRequested);
    on<AccountUpdateProfileRequested>(_onAccountUpdateProfileRequested);
    on<AccountChangePasswordRequested>(_onAccountChangePasswordRequested);
    on<AccountDeleteRequested>(_onAccountDeleteRequested);
    on<AccountSaveFcmRequested>(_onAccountSaveFcmRequested);
  }

  Future<void> _onAccountProfileRequested(
    AccountProfileRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    final profileResult = await getProfileUseCase();
    final dashboardResult = await getDashboardUseCase();

    profileResult.fold(
      (failure) => emit(AccountError(failure.message)),
      (user) {
        dashboardResult.fold(
          (failure) => emit(AccountError(failure.message)),
          (dashboardData) {
            emit(AccountLoaded(
              user: user,
              stats: dashboardData.stats,
              recentOrders: dashboardData.recentOrders,
            ));
          },
        );
      },
    );
  }

  Future<void> _onAccountUpdateProfileRequested(
    AccountUpdateProfileRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountActionLoading());
    final result = await updateProfileUseCase(event.data);
    result.fold(
      (failure) => emit(AccountActionError(message: failure.message)),
      (user) {
        emit(AccountActionSuccess(message: 'the_profile_has_been'.tr()));

        // Since we don't have the old stats here easily (unless we cast state),
        // we should probably just re-fetch the dashboard or emit the old stats if available.
        if (state is AccountLoaded) {
          final currentState = state as AccountLoaded;
          emit(AccountLoaded(
            user: user,
            stats: currentState.stats,
            recentOrders: currentState.recentOrders,
          ));
        } else {
          // Fallback, trigger full reload
          add(const AccountProfileRequested());
        }
      },
    );
  }

  Future<void> _onAccountChangePasswordRequested(
    AccountChangePasswordRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountActionLoading());
    final result =
        await changePasswordUseCase(event.currentPassword, event.newPassword);
    result.fold(
      (failure) => emit(AccountActionError(message: failure.message)),
      (_) => emit(
          AccountActionSuccess(message: 'the_password_has_been_1'.tr())),
    );
  }

  Future<void> _onAccountDeleteRequested(
    AccountDeleteRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountActionLoading());
    final result = await deleteAccountUseCase(event.password);
    result.fold(
      (failure) => emit(AccountActionError(message: failure.message)),
      (_) => emit(
          AccountActionSuccess(message: 'the_account_has_been'.tr())),
    );
  }

  Future<void> _onAccountSaveFcmRequested(
    AccountSaveFcmRequested event,
    Emitter<AccountState> emit,
  ) async {
    final result = await saveFcmTokenUseCase(
        token: event.token, deviceId: 'default_device_id');
    result.fold(
      (failure) {
        // We might not want to emit a full error state for failing to save FCM token,
        // but maybe we can log it or just ignore it.
        // For now, let's just emit a failure if needed, or do nothing.
      },
      (_) {
        // Successfully saved FCM token
      },
    );
  }
}
