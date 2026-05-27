import 'package:hive/hive.dart';
import 'package:delivery_app/core/cache/entities/pending_sync_entity.dart';
import 'package:delivery_app/core/utils/constants.dart';

class PendingSyncLocalDataSource {
  PendingSyncLocalDataSource(this._box);

  final Box<PendingSyncEntity> _box;

  List<PendingSyncEntity> getAll() {
    return _box.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> enqueue(PendingSyncEntity item) async {
    await _box.put(item.id, item);
  }

  Future<void> enqueueOrReplace(PendingSyncEntity item) async {
    await _box.put(item.id, item);
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}

Future<Box<PendingSyncEntity>> openPendingSyncBox() async {
  return Hive.openBox<PendingSyncEntity>(AppConstants.pendingSyncBox);
}
