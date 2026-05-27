import 'package:hive/hive.dart';

enum SyncAction {
  createTrip,
  updateTripStatus,
}

class PendingSyncEntity extends HiveObject {
  PendingSyncEntity({
    required this.id,
    required this.action,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
  });

  final String id;
  final SyncAction action;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;

  PendingSyncEntity copyWith({int? retryCount}) {
    return PendingSyncEntity(
      id: id,
      action: action,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
