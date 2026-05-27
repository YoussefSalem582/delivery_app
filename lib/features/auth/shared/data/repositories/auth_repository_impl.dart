import 'package:dio/dio.dart';
import 'package:delivery_app/features/auth/shared/data/datasources/auth_local_datasource.dart';
import 'package:delivery_app/core/cache/datasources/cache_metadata_local_datasource.dart';
import 'package:delivery_app/core/constants/app_constants.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';
import 'package:delivery_app/features/auth/shared/domain/repositories/auth_repository.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/utils/cache_freshness.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthLocalDataSource local,
    required Dio dio,
    required CacheMetadataLocalDataSource cacheMetadata,
    required NetworkStatus networkStatus,
  })  : _local = local,
        _dio = dio,
        _cacheMetadata = cacheMetadata,
        _networkStatus = networkStatus;

  final AuthLocalDataSource _local;
  final Dio _dio;
  final CacheMetadataLocalDataSource _cacheMetadata;
  final NetworkStatus _networkStatus;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    UserEntity user;
    if (await _networkStatus.isOnline) {
      try {
        final response = await _dio.get<dynamic>(ApiEndpoints.profile);
        user = UserEntity.fromJson(response.data as Map<String, dynamic>)
            .copyWith(email: email, isLoggedIn: true);
        await _cacheMetadata.markFetched(CacheKeys.profile);
      } on DioException {
        user = UserEntity(
          id: 'local-user',
          name: 'Demo User',
          email: email,
          phone: '+201000000000',
          walletBalance: 250,
          isLoggedIn: true,
        );
      }
    } else {
      user = UserEntity(
        id: 'local-user',
        name: 'Demo User',
        email: email,
        phone: '+201000000000',
        walletBalance: 250,
        isLoggedIn: true,
      );
    }

    await _local.saveUser(user);
    return user;
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await login(email: email, password: password);
    final registered = user.copyWith(name: name, email: email);
    await _local.saveUser(registered);
    return registered;
  }

  @override
  Future<void> logout() => _local.clearUser();

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }

  @override
  Future<UserEntity?> getCurrentUser() async => _local.getCurrentUser();

  @override
  UserEntity? get cachedUser => _local.getCurrentUser();

  @override
  bool isLoggedIn() {
    final user = _local.getCurrentUser();
    return user?.isLoggedIn ?? false;
  }

  @override
  Future<UserEntity> getProfile({bool forceRefresh = false}) async {
    final cached = _local.getCurrentUser();
    final lastFetched = _cacheMetadata.getLastFetched(CacheKeys.profile);

    if (cached != null &&
        !forceRefresh &&
        (!await _networkStatus.isOnline ||
            CacheFreshness.isFresh(lastFetched))) {
      return cached;
    }

    if (await _networkStatus.isOnline) {
      try {
        final response = await _dio.get<dynamic>(ApiEndpoints.profile);
        final user = UserEntity.fromJson(response.data as Map<String, dynamic>)
            .copyWith(isLoggedIn: cached?.isLoggedIn ?? true);
        await _local.saveUser(user);
        await _cacheMetadata.markFetched(CacheKeys.profile);
        return user;
      } on DioException {
        if (cached != null) return cached;
      }
    }

    return cached ??
        UserEntity(
          id: 'guest',
          name: 'Guest',
          email: AppConstants.guestEmail,
          phone: '',
          walletBalance: 0,
          isLoggedIn: false,
        );
  }

  @override
  Future<UserEntity> updateWalletBalance(double amount) async {
    final user = await getProfile();
    final updated = user.copyWith(walletBalance: user.walletBalance + amount);
    await _local.saveUser(updated);
    return updated;
  }

  @override
  Future<UserEntity> updateProfile({required String name}) async {
    final user = await getProfile();
    final updated = user.copyWith(name: name);
    await _local.saveUser(updated);
    return updated;
  }
}
