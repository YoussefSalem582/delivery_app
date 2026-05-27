import 'package:delivery_app/core/architecture/datasources/pending_sync_local_datasource.dart';
import 'package:delivery_app/core/architecture/entities/pending_sync_entity.dart';
import 'package:delivery_app/core/architecture/entities/hive_adapters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Box<PendingSyncEntity> box;
  late PendingSyncLocalDataSource dataSource;

  setUpAll(() {
    Hive.init('test_pending_sync');
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(SyncActionAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(PendingSyncEntityAdapter());
    }
  });

  setUp(() async {
    box = await Hive.openBox<PendingSyncEntity>(
      'pending_sync_test_${DateTime.now().microsecondsSinceEpoch}',
    );
    dataSource = PendingSyncLocalDataSource(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  test('enqueueOrReplace replaces item with same id', () async {
    await dataSource.enqueueOrReplace(
      PendingSyncEntity(
        id: 'status:trip-1',
        action: SyncAction.updateTripStatus,
        payload: {'tripId': 'trip-1', 'status': 'requested'},
        createdAt: DateTime(2026, 5, 1),
      ),
    );
    await dataSource.enqueueOrReplace(
      PendingSyncEntity(
        id: 'status:trip-1',
        action: SyncAction.updateTripStatus,
        payload: {'tripId': 'trip-1', 'status': 'completed'},
        createdAt: DateTime(2026, 5, 2),
      ),
    );

    final all = dataSource.getAll();
    expect(all.length, 1);
    expect(all.first.payload['status'], 'completed');
  });
}
