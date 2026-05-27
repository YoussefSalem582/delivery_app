import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:delivery_app/core/architecture/datasources/auth_local_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/cache_metadata_local_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/notification_local_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/order_local_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/pending_sync_local_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/order_remote_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/route_cache_local_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/trip_local_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/trip_remote_datasource.dart';
import 'package:delivery_app/core/architecture/entities/hive_adapters.dart';
import 'package:delivery_app/core/architecture/repositories/auth_repository.dart';
import 'package:delivery_app/core/architecture/repositories/auth_repository_impl.dart';
import 'package:delivery_app/core/architecture/repositories/notification_repository.dart';
import 'package:delivery_app/core/architecture/repositories/notification_repository_impl.dart';
import 'package:delivery_app/core/architecture/repositories/order_repository.dart';
import 'package:delivery_app/core/architecture/repositories/order_repository_impl.dart';
import 'package:delivery_app/core/architecture/repositories/trip_repository.dart';
import 'package:delivery_app/core/architecture/repositories/trip_repository_impl.dart';
import 'package:delivery_app/core/network/dio_client.dart';
import 'package:delivery_app/core/network/fcm_service.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/network/offline_cubit.dart';
import 'package:delivery_app/core/network/route_service.dart';
import 'package:delivery_app/core/utils/map_tile_cache.dart';
import 'package:delivery_app/core/sync/sync_service.dart';
import 'package:delivery_app/core/theme/theme_cubit.dart';
import 'package:delivery_app/core/utils/talker_setup.dart';
import 'package:delivery_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/home/presentation/bloc/map_bloc.dart';
import 'package:delivery_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:delivery_app/features/profile/presentation/bloc/order_bloc.dart';
import 'package:delivery_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:delivery_app/features/trips/presentation/bloc/trip_detail_bloc.dart';
import 'package:delivery_app/features/trips/presentation/bloc/trip_list_bloc.dart';
import 'package:delivery_app/routes/app_router.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final talker = createTalker();
  sl.registerLazySingleton<Talker>(() => talker);

  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton(() => ThemeCubit(sl()));
  sl.registerLazySingleton(() => LocaleCubit(sl()));

  await Hive.initFlutter();
  _registerHiveAdapters();

  final tripsBox = await openTripsBox();
  final ordersBox = await openOrdersBox();
  final userBox = await openUserBox();
  final notificationsBox = await openNotificationsBox();
  final pendingSyncBox = await openPendingSyncBox();
  final cacheMetaBox = await openCacheMetaBox();
  final routeCacheBox = await openRouteCacheBox();

  sl.registerLazySingleton(() => tripsBox);
  sl.registerLazySingleton(() => ordersBox);
  sl.registerLazySingleton(() => userBox);
  sl.registerLazySingleton(() => notificationsBox);
  sl.registerLazySingleton(() => pendingSyncBox);
  sl.registerLazySingleton(() => cacheMetaBox);
  sl.registerLazySingleton(() => routeCacheBox);

  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => NetworkStatus(sl()));
  sl.registerLazySingleton(() => OfflineCubit(sl()));
  sl.registerLazySingleton<Dio>(() => createDioClient(sl<Talker>()));
  sl.registerLazySingleton(() => RouteService(sl(), sl(), sl()));
  await MapTileCache.init();

  sl.registerLazySingleton(() => TripLocalDataSource(sl()));
  sl.registerLazySingleton(() => TripRemoteDataSource(sl()));
  sl.registerLazySingleton(() => OrderLocalDataSource(sl()));
  sl.registerLazySingleton(() => OrderRemoteDataSource(sl()));
  sl.registerLazySingleton(() => AuthLocalDataSource(sl()));
  sl.registerLazySingleton(() => NotificationLocalDataSource(sl()));
  sl.registerLazySingleton(() => PendingSyncLocalDataSource(sl()));
  sl.registerLazySingleton(() => CacheMetadataLocalDataSource(sl()));
  sl.registerLazySingleton(() => RouteCacheLocalDataSource(sl()));

  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(
      local: sl(),
      remote: sl(),
      pendingSync: sl(),
      cacheMetadata: sl(),
      networkStatus: sl(),
      talker: sl(),
    ),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      local: sl(),
      remote: sl(),
      cacheMetadata: sl(),
      networkStatus: sl(),
      talker: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      local: sl(),
      dio: sl(),
      cacheMetadata: sl(),
      networkStatus: sl(),
    ),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(
    () => SyncService(
      tripRepository: sl(),
      orderRepository: sl(),
      authRepository: sl(),
      networkStatus: sl(),
      talker: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => FcmService(notificationRepository: sl(), talker: sl()),
  );

  sl.registerLazySingleton(() => AuthBloc(sl()));
  sl.registerFactory(
    () => TripListBloc(repository: sl(), networkStatus: sl()),
  );
  sl.registerFactory(
    () => TripDetailBloc(
      repository: sl(),
      authRepository: sl(),
      fcmService: sl(),
    ),
  );
  sl.registerFactory(() => RequestRideBloc(repository: sl(), fcmService: sl()));
  sl.registerFactory(() => MapBloc());
  sl.registerFactory(() => TrackingBloc(sl()));
  sl.registerFactory(() => OrderBloc(sl(), sl()));
  sl.registerFactory(
    () => ProfileBloc(
      authRepository: sl(),
      networkStatus: sl(),
    ),
  );
  sl.registerLazySingleton(() => NotificationBloc(sl()));

  sl.registerLazySingleton<AppRouter>(() => AppRouter());

  final fcm = sl<FcmService>();
  fcm.onNotification = (_) {
    sl<NotificationBloc>().add(const NotificationReceived());
  };
}

void _registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(LocationEntityAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(TripStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(TripEntityAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(OrderStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(OrderEntityAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(UserEntityAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(NotificationEntityAdapter());
  }
  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(SyncActionAdapter());
  }
  if (!Hive.isAdapterRegistered(8)) {
    Hive.registerAdapter(PendingSyncEntityAdapter());
  }
  if (!Hive.isAdapterRegistered(9)) {
    Hive.registerAdapter(CacheMetadataEntityAdapter());
  }
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(RouteCacheEntityAdapter());
  }
}
