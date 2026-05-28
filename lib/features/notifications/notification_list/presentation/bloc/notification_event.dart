part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class NotificationLoadRequested extends NotificationEvent {
  const NotificationLoadRequested();
}

class NotificationRefreshRequested extends NotificationEvent {
  const NotificationRefreshRequested();
}

class NotificationMarkReadRequested extends NotificationEvent {
  const NotificationMarkReadRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class NotificationMarkAllReadRequested extends NotificationEvent {
  const NotificationMarkAllReadRequested();
}

class NotificationDeleteRequested extends NotificationEvent {
  const NotificationDeleteRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class NotificationRestoreRequested extends NotificationEvent {
  const NotificationRestoreRequested(this.notification);
  final NotificationEntity notification;
  @override
  List<Object?> get props => [notification];
}

class NotificationFilterChanged extends NotificationEvent {
  const NotificationFilterChanged(this.filter);
  final NotificationFilter filter;
  @override
  List<Object?> get props => [filter];
}

class NotificationReceived extends NotificationEvent {
  const NotificationReceived();
}

enum NotificationFilter { all, unread }

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
  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
    this.filter = NotificationFilter.all,
    this.isRefreshing = false,
  });

  final List<NotificationEntity> notifications;
  final int unreadCount;
  final NotificationFilter filter;
  final bool isRefreshing;

  List<NotificationEntity> get filteredNotifications {
    if (filter == NotificationFilter.unread) {
      return notifications.where((n) => !n.isRead).toList();
    }
    return notifications;
  }

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    NotificationFilter? filter,
    bool? isRefreshing,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      filter: filter ?? this.filter,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [notifications, unreadCount, filter, isRefreshing];
}

class NotificationError extends NotificationState {
  const NotificationError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
