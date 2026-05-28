import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/notifications/shared/domain/entities/notification_entity.dart';
import 'package:delivery_app/features/notifications/shared/domain/usecases/notification_usecases.dart';

part 'notification_event.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({
    required GetNotificationsUseCase getNotifications,
    required MarkNotificationReadUseCase markNotificationRead,
    required MarkAllNotificationsReadUseCase markAllRead,
    required DeleteNotificationUseCase deleteNotification,
    required AddNotificationUseCase addNotification,
    required GetUnreadNotificationCountUseCase getUnreadCount,
  })  : _getNotifications = getNotifications,
        _markNotificationRead = markNotificationRead,
        _markAllRead = markAllRead,
        _deleteNotification = deleteNotification,
        _addNotification = addNotification,
        _getUnreadCount = getUnreadCount,
        super(const NotificationInitial()) {
    on<NotificationLoadRequested>(_onLoad);
    on<NotificationRefreshRequested>(_onRefresh);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationMarkAllReadRequested>(_onMarkAllRead);
    on<NotificationDeleteRequested>(_onDelete);
    on<NotificationRestoreRequested>(_onRestore);
    on<NotificationFilterChanged>(_onFilterChanged);
    on<NotificationReceived>(_onReceived);
  }

  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markNotificationRead;
  final MarkAllNotificationsReadUseCase _markAllRead;
  final DeleteNotificationUseCase _deleteNotification;
  final AddNotificationUseCase _addNotification;
  final GetUnreadNotificationCountUseCase _getUnreadCount;

  NotificationFilter _currentFilter = NotificationFilter.all;

  Future<void> _emitLoaded(Emitter<NotificationState> emit) async {
    final result = await _getNotifications(const NoParams());
    final countResult = await _getUnreadCount(const NoParams());
    result.fold(
      (Failure failure) => emit(NotificationError(failure.message)),
      (items) {
        final unreadCount = countResult.getOrElse(() => 0);
        emit(
          NotificationLoaded(
            notifications: items,
            unreadCount: unreadCount,
            filter: _currentFilter,
          ),
        );
      },
    );
  }

  Future<void> _onLoad(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    await _emitLoaded(emit);
  }

  Future<void> _onRefresh(
    NotificationRefreshRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is NotificationLoaded) {
      emit(current.copyWith(isRefreshing: true));
    }
    await _emitLoaded(emit);
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await _markNotificationRead(MarkNotificationReadParams(event.id));
    await _emitLoaded(emit);
  }

  Future<void> _onMarkAllRead(
    NotificationMarkAllReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await _markAllRead(const NoParams());
    await _emitLoaded(emit);
  }

  Future<void> _onDelete(
    NotificationDeleteRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await _deleteNotification(DeleteNotificationParams(event.id));
    await _emitLoaded(emit);
  }

  Future<void> _onRestore(
    NotificationRestoreRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await _addNotification(event.notification);
    await _emitLoaded(emit);
  }

  void _onFilterChanged(
    NotificationFilterChanged event,
    Emitter<NotificationState> emit,
  ) {
    _currentFilter = event.filter;
    final current = state;
    if (current is NotificationLoaded) {
      emit(current.copyWith(filter: event.filter));
    }
  }

  Future<void> _onReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    await _emitLoaded(emit);
  }
}
