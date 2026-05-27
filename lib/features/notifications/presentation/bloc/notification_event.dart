part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class NotificationLoadRequested extends NotificationEvent {
  const NotificationLoadRequested();
}

class NotificationMarkReadRequested extends NotificationEvent {
  const NotificationMarkReadRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class NotificationReceived extends NotificationEvent {
  const NotificationReceived();
}

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  const NotificationLoaded(this.notifications, this.unreadCount);
  final List<NotificationEntity> notifications;
  final int unreadCount;
  @override
  List<Object?> get props => [notifications, unreadCount];
}
