import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/core/architecture/entities/notification_entity.dart';
import 'package:delivery_app/core/architecture/repositories/notification_repository.dart';

part 'notification_event.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(this._repository) : super(const NotificationInitial()) {
    on<NotificationLoadRequested>(_onLoad);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationReceived>(_onReceived);
  }

  final NotificationRepository _repository;

  Future<void> _onLoad(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    final items = await _repository.getNotifications();
    emit(NotificationLoaded(items, _repository.unreadCount));
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await _repository.markAsRead(event.id);
    final items = await _repository.getNotifications();
    emit(NotificationLoaded(items, _repository.unreadCount));
  }

  Future<void> _onReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    final items = await _repository.getNotifications();
    emit(NotificationLoaded(items, _repository.unreadCount));
  }
}
