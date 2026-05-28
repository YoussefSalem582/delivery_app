import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'core/api/api_client.dart';
import 'core/cache/datasources/cache_metadata_local_datasource.dart';
import 'core/cache/datasources/pending_sync_local_datasource.dart';
import 'core/cache/datasources/route_cache_local_datasource.dart';
import 'core/cache/entities/hive_adapters.dart';
import 'core/network/connectivity_cubit.dart';
import 'core/network/connectivity_service.dart';
import 'core/network/fcm_service.dart';
import 'core/network/network_status.dart';
import 'core/network/route_service.dart';
import 'core/sync/sync_service.dart';
import 'core/utils/map_tile_cache.dart';
import 'core/utils/talker_setup.dart';
import 'features/auth/shared/data/datasources/auth_local_datasource.dart';
import 'features/auth/shared/data/repositories/auth_repository_impl.dart';
import 'features/auth/shared/domain/repositories/auth_repository.dart';
import 'features/auth/shared/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/shared/domain/usecases/get_cached_user_usecase.dart';
import 'features/auth/shared/domain/usecases/login_usecase.dart';
import 'features/auth/shared/domain/usecases/logout_usecase.dart';
import 'features/auth/shared/domain/usecases/register_usecase.dart';
import 'features/auth/shared/presentation/bloc/auth_bloc.dart';
import 'features/home/map_view/presentation/bloc/map_bloc.dart';
import 'features/notifications/notification_list/presentation/bloc/notification_bloc.dart';
import 'features/notifications/shared/data/datasources/notification_local_datasource.dart';
import 'features/notifications/shared/data/repositories/notification_repository_impl.dart';
import 'features/notifications/shared/domain/repositories/notification_repository.dart';
import 'features/profile/orders/presentation/bloc/order_bloc.dart';
import 'features/profile/profile_view/presentation/bloc/profile_bloc.dart';
import 'features/profile/shared/data/datasources/order_local_datasource.dart';
import 'features/profile/shared/data/datasources/order_remote_datasource.dart';
import 'features/profile/shared/data/repositories/order_repository_impl.dart';
import 'features/profile/shared/domain/repositories/order_repository.dart';
import 'features/profile/shared/domain/usecases/get_profile_usecase.dart';
import 'features/profile/shared/domain/usecases/order_usecases.dart';
import 'features/notifications/shared/domain/usecases/notification_usecases.dart';
import 'features/trips/shared/domain/usecases/estimate_fare_usecase.dart';
import 'features/trips/shared/domain/usecases/trip_usecases.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/trips/shared/data/datasources/chat_local_datasource.dart';
import 'features/trips/shared/data/datasources/driver_remote_datasource.dart';
import 'features/trips/shared/data/datasources/driver_review_remote_datasource.dart';
import 'features/trips/shared/data/datasources/trip_local_datasource.dart';
import 'features/trips/shared/data/datasources/trip_remote_datasource.dart';
import 'features/trips/shared/data/repositories/chat_repository_impl.dart';
import 'features/trips/shared/data/repositories/driver_repository_impl.dart';
import 'features/trips/shared/data/repositories/trip_repository_impl.dart';
import 'features/trips/shared/domain/repositories/chat_repository.dart';
import 'features/trips/shared/domain/repositories/driver_repository.dart';
import 'features/trips/shared/domain/repositories/trip_repository.dart';
import 'features/trips/shared/domain/usecases/chat_usecases.dart';
import 'features/trips/shared/domain/usecases/get_driver_reviews_usecase.dart';
import 'features/trips/shared/domain/usecases/get_driver_for_trip_usecase.dart';
import 'features/trips/driver_chat/presentation/bloc/driver_chat_bloc.dart';
import 'features/trips/driver_call/presentation/bloc/driver_call_bloc.dart';
import 'features/trips/driver_profile/presentation/bloc/driver_profile_bloc.dart';
import 'features/trips/trip_detail/presentation/bloc/trip_detail_bloc.dart';
import 'features/trips/trip_list/presentation/bloc/trip_list_bloc.dart';
import 'features/trips/tracking/presentation/bloc/tracking_bloc.dart';

final sl = GetIt.instance;

Timer? _tripsCacheSyncDebounce;

void notifyTripsCacheChanged() {
  _tripsCacheSyncDebounce?.cancel();
  _tripsCacheSyncDebounce = Timer(const Duration(milliseconds: 250), () {
    sl<TripListBloc>().add(const TripListCacheSyncRequested());
  });
}

Future<void> initDependencies() async {
  // ─── External ────────────────────────────────────────────────
  final talker = createTalker();
  sl.registerLazySingleton<Talker>(() => talker);

  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // ─── Logger / API ────────────────────────────────────────────
  sl.registerLazySingleton<ApiClient>(() => ApiClient(talker: sl()));
  sl.registerLazySingleton<Dio>(() => sl<ApiClient>().dio);

  // ─── Settings ────────────────────────────────────────────────
  sl.registerLazySingleton(() => SettingsCubit(sharedPreferences: sl()));

  // ─── Hive ────────────────────────────────────────────────────
  await Hive.initFlutter();
  _registerHiveAdapters();

  final tripsBox = await openTripsBox();
  final ordersBox = await openOrdersBox();
  final userBox = await openUserBox();
  final notificationsBox = await openNotificationsBox();
  final pendingSyncBox = await openPendingSyncBox();
  final cacheMetaBox = await openCacheMetaBox();
  final routeCacheBox = await openRouteCacheBox();
  final chatMessagesBox = await openChatMessagesBox();

  sl.registerLazySingleton(() => tripsBox);
  sl.registerLazySingleton(() => ordersBox);
  sl.registerLazySingleton(() => userBox);
  sl.registerLazySingleton(() => notificationsBox);
  sl.registerLazySingleton(() => pendingSyncBox);
  sl.registerLazySingleton(() => cacheMetaBox);
  sl.registerLazySingleton(() => routeCacheBox);
  sl.registerLazySingleton(() => chatMessagesBox);

  // ─── Connectivity ────────────────────────────────────────────
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => NetworkStatus(sl()));
  sl.registerLazySingleton(() => ConnectivityService(sl()));
  final connectivityService = sl<ConnectivityService>();
  await connectivityService.init();
  sl.registerLazySingleton(
    () => ConnectivityCubit(service: sl<ConnectivityService>()),
  );

  // ─── Map / route services ────────────────────────────────────
  sl.registerLazySingleton(
    () => RouteService(sl(), sl(), sl()),
  );
  await MapTileCache.init();

  // ─── Data sources ────────────────────────────────────────────
  sl.registerLazySingleton(() => TripLocalDataSource(sl()));
  sl.registerLazySingleton(() => TripRemoteDataSource(sl()));
  sl.registerLazySingleton(() => DriverRemoteDataSource(sl()));
  sl.registerLazySingleton(() => DriverReviewRemoteDataSource(sl()));
  sl.registerLazySingleton(() => ChatLocalDataSource(sl()));
  sl.registerLazySingleton(() => OrderLocalDataSource(sl()));
  sl.registerLazySingleton(() => OrderRemoteDataSource(sl()));
  sl.registerLazySingleton(() => AuthLocalDataSource(sl()));
  sl.registerLazySingleton(() => NotificationLocalDataSource(sl()));
  sl.registerLazySingleton(() => PendingSyncLocalDataSource(sl()));
  sl.registerLazySingleton(() => CacheMetadataLocalDataSource(sl()));
  sl.registerLazySingleton(() => RouteCacheLocalDataSource(sl()));

  // ─── Repositories ────────────────────────────────────────────
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
  sl.registerLazySingleton<DriverRepository>(
    () => DriverRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(local: sl()),
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

  // ─── Use cases ───────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedUserUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => RefreshProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetTripsUseCase(sl()));
  sl.registerLazySingleton(() => RefreshTripsUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedTripsUseCase(sl()));
  sl.registerLazySingleton(() => GetTripDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedTripDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetDriverForTripUseCase(sl()));
  sl.registerLazySingleton(() => GetDriverReviewsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTripStatusUseCase(sl()));
  sl.registerLazySingleton(() => RequestTripUseCase(sl()));
  sl.registerLazySingleton(() => EstimateFareUseCase());
  sl.registerLazySingleton(() => GetChatMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendChatMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => RefreshOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadNotificationCountUseCase(sl()));

  // ─── Services ────────────────────────────────────────────────
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

  // ─── BLoCs ───────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => AuthBloc(
      getCachedUser: sl(),
      login: sl(),
      register: sl(),
      logout: sl(),
      forgotPassword: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => TripListBloc(
      getCachedTrips: sl(),
      getTrips: sl(),
      refreshTrips: sl(),
      networkStatus: sl(),
    ),
  );
  sl.registerFactory(
    () => TripDetailBloc(
      getCachedTripDetail: sl(),
      getTripDetail: sl(),
      updateTripStatus: sl(),
      authRepository: sl(),
      fcmService: sl(),
      onTripsChanged: notifyTripsCacheChanged,
    ),
  );
  sl.registerFactory(
    () => RequestRideBloc(
      requestTrip: sl(),
      fcmService: sl(),
      onTripsChanged: notifyTripsCacheChanged,
    ),
  );
  sl.registerFactory(() => MapBloc());
  sl.registerFactory(
    () => TrackingBloc(
      routeService: sl(),
      getTripDetail: sl(),
      getDriverForTrip: sl(),
      updateTripStatus: sl(),
      authRepository: sl(),
      fcmService: sl(),
      onTripsChanged: notifyTripsCacheChanged,
    ),
  );
  sl.registerFactory(
    () => DriverChatBloc(
      getTripDetail: sl(),
      getChatMessages: sl(),
      sendChatMessage: sl(),
    ),
  );
  sl.registerFactory(
    () => DriverCallBloc(getTripDetail: sl()),
  );
  sl.registerFactory(
    () => DriverProfileBloc(
      getTripDetail: sl(),
      getDriverForTrip: sl(),
      getDriverReviews: sl(),
    ),
  );
  sl.registerFactory(
    () => OrderBloc(
      getCachedOrders: sl(),
      getOrders: sl(),
      refreshOrders: sl(),
      networkStatus: sl(),
    ),
  );
  sl.registerFactory(
    () => ProfileBloc(
      getProfile: sl(),
      refreshProfile: sl(),
      authRepository: sl(),
      networkStatus: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => NotificationBloc(
      getNotifications: sl(),
      markNotificationRead: sl(),
      getUnreadCount: sl(),
    ),
  );

  final fcm = sl<FcmService>();
  fcm.onNotification = (_) {
    sl<NotificationBloc>().add(const NotificationReceived());
    notifyTripsCacheChanged();
  };

  sl<SyncService>().onTripsChanged = notifyTripsCacheChanged;
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
