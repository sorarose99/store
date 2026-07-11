import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;

  NotificationsBloc({required this.getNotificationsUseCase})
      : super(NotificationsInitial()) {
    on<NotificationsRequested>(_onNotificationsRequested);
  }

  Future<void> _onNotificationsRequested(
    NotificationsRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    final result = await getNotificationsUseCase();
    result.fold(
      (failure) => emit(NotificationsError(failure.message)),
      (notifications) =>
          emit(NotificationsLoaded(notifications: notifications)),
    );
  }
}
