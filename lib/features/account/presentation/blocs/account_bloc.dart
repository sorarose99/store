import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/token_service.dart';
import '../../../auth/domain/entities/user.dart' as auth_user;
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';
import '../../domain/usecases/save_fcm_token_usecase.dart';
import '../../domain/usecases/send_contact_message_usecase.dart';
import 'account_event.dart';
import 'account_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountLoaded? lastLoadedState;

  final GetProfileUseCase getProfileUseCase;
  final GetDashboardUseCase getDashboardUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final SaveFcmTokenUseCase saveFcmTokenUseCase;
  final SendContactMessageUseCase sendContactMessageUseCase;

  AccountBloc({
    required this.getProfileUseCase,
    required this.getDashboardUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
    required this.deleteAccountUseCase,
    required this.saveFcmTokenUseCase,
    required this.sendContactMessageUseCase,
  }) : super(AccountInitial()) {
    on<AccountProfileRequested>(_onAccountProfileRequested);
    on<AccountUpdateProfileRequested>(_onAccountUpdateProfileRequested);
    on<AccountChangePasswordRequested>(_onAccountChangePasswordRequested);
    on<AccountDeleteRequested>(_onAccountDeleteRequested);
    on<AccountSaveFcmRequested>(_onAccountSaveFcmRequested);
    on<AccountSendContactRequested>(_onAccountSendContactRequested);
  }

  Future<void> _onAccountProfileRequested(
    AccountProfileRequested event,
    Emitter<AccountState> emit,
  ) async {
    // Dedup: skip if a fetch is already in-flight
    if (state is AccountLoading) return;

    // Guard: only call authenticated endpoints when user is logged in
    if (!sl<TokenService>().hasToken) {
      emit(const AccountError('يرجى تسجيل الدخول أولاً'));
      return;
    }

    emit(AccountLoading());
    final profileResult = await getProfileUseCase();
    final dashboardResult = await getDashboardUseCase();

    profileResult.fold(
      (failure) => emit(AccountError(failure.message)),
      (user) {
        // Sync to TokenService cached user details
        final current = sl<TokenService>().currentUser;
        if (current != null) {
          final nameParts = user.name.split(' ');
          final updatedUser = auth_user.User(
            id: current.id,
            uuid: current.uuid,
            firstName: nameParts.isNotEmpty ? nameParts.first : '',
            lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
            email: user.email,
            phone: user.phone,
            avatar: user.avatar,
            gender: user.gender,
            birthDate: user.dateOfBirth.toIso8601String(),
            token: current.token,
          );
          sl<TokenService>().updateCachedUser(updatedUser);
        }

        dashboardResult.fold(
          (failure) => emit(AccountError(failure.message)),
          (dashboardData) {
            final loadedState = AccountLoaded(
              user: user,
              stats: dashboardData.stats,
              recentOrders: dashboardData.recentOrders,
            );
            lastLoadedState = loadedState;
            emit(loadedState);
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

        // Sync to TokenService cached user details
        final current = sl<TokenService>().currentUser;
        if (current != null) {
          final nameParts = user.name.split(' ');
          final updatedUser = auth_user.User(
            id: current.id,
            uuid: current.uuid,
            firstName: nameParts.isNotEmpty ? nameParts.first : '',
            lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
            email: user.email,
            phone: user.phone,
            avatar: user.avatar,
            gender: user.gender,
            birthDate: user.dateOfBirth.toIso8601String(),
            token: current.token,
          );
          sl<TokenService>().updateCachedUser(updatedUser);
        }

        if (state is AccountLoaded) {
          final currentState = state as AccountLoaded;
          final updatedState = AccountLoaded(
            user: user,
            stats: currentState.stats,
            recentOrders: currentState.recentOrders,
          );
          lastLoadedState = updatedState;
          emit(updatedState);
        } else if (lastLoadedState != null) {
          final updatedState = AccountLoaded(
            user: user,
            stats: lastLoadedState!.stats,
            recentOrders: lastLoadedState!.recentOrders,
          );
          lastLoadedState = updatedState;
          emit(updatedState);
        } else {
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

    final user = FirebaseAuth.instance.currentUser;
    final isEmailUser = user == null || user.providerData.any((p) => p.providerId == 'password');

    if (isEmailUser) {
      // 1. Email Users: Must validate password on Laravel backend first.
      final result = await deleteAccountUseCase(event.password);
      await result.fold(
        (failure) async {
          emit(AccountActionError(message: failure.message));
        },
        (_) async {
          // Backend deletion succeeded, now wipe Firebase.
          try {
            if (user != null) await user.delete();
          } catch (_) {
            try {
              await FirebaseAuth.instance.signOut();
            } catch (_) {}
          }
          emit(AccountActionSuccess(message: 'the_account_has_been'.tr()));
        },
      );
    } else {
      // 2. Social Users (Google/Apple): Bypass Laravel password check entirely.
      // Use Firebase's native delete option directly.
      try {
        await user!.delete();
        emit(AccountActionSuccess(message: 'the_account_has_been'.tr()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          // Social user session is too old to delete securely.
          // They must sign out and sign back in with Google to perform this sensitive action.
          emit(AccountActionError(message: 'Session expired. Please sign out, sign in with Google/Apple again, and retry.'));
        } else {
          emit(AccountActionError(message: e.message ?? 'Deletion failed'));
        }
      } catch (e) {
        emit(AccountActionError(message: 'Deletion failed. Please try again.'));
      }
    }
  }

  Future<void> _onAccountSaveFcmRequested(
    AccountSaveFcmRequested event,
    Emitter<AccountState> emit,
  ) async {
    final result = await saveFcmTokenUseCase(
        token: event.token, deviceId: 'default_device_id');
    result.fold((failure) {}, (_) {});
  }

  Future<void> _onAccountSendContactRequested(
    AccountSendContactRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountActionLoading());
    final result = await sendContactMessageUseCase({
      'name': event.name,
      'email': event.email,
      'phone': event.phone,
      'type': event.type,
      'subject': event.subject,
      'message': event.message,
    });
    result.fold(
      (failure) => emit(AccountActionError(message: failure.message)),
      (_) => emit(const AccountActionSuccess(message: 'تم إرسال رسالتك بنجاح')),
    );
  }
}
