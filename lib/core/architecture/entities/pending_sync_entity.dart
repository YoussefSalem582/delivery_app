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
  });

  final String id;
  final SyncAction action;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
}
