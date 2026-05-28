import 'package:dartz/dartz.dart';

import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase
    extends UseCase<List<NotificationEntity>, NoParams> {
  GetNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(NoParams params) async {
    try {
      final items = await _repository.getNotifications();
      return Right(items);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

class MarkNotificationReadParams {
  const MarkNotificationReadParams(this.id);

  final String id;
}

class MarkNotificationReadUseCase
    extends UseCase<void, MarkNotificationReadParams> {
  MarkNotificationReadUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, void>> call(MarkNotificationReadParams params) async {
    try {
      await _repository.markAsRead(params.id);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

class GetUnreadNotificationCountUseCase extends UseCase<int, NoParams> {
  GetUnreadNotificationCountUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    return Right(_repository.unreadCount);
  }
}

class MarkAllNotificationsReadUseCase extends UseCase<void, NoParams> {
  MarkAllNotificationsReadUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await _repository.markAllAsRead();
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

class DeleteNotificationParams {
  const DeleteNotificationParams(this.id);

  final String id;
}

class AddNotificationUseCase extends UseCase<void, NotificationEntity> {
  AddNotificationUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, void>> call(NotificationEntity params) async {
    try {
      await _repository.addNotification(params);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

class DeleteNotificationUseCase
    extends UseCase<void, DeleteNotificationParams> {
  DeleteNotificationUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeleteNotificationParams params) async {
    try {
      await _repository.deleteNotification(params.id);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
