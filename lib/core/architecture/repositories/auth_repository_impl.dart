import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:delivery_app/core/architecture/datasources/auth_local_datasource.dart';
import 'package:delivery_app/core/architecture/entities/user_entity.dart';
import 'package:delivery_app/core/architecture/repositories/auth_repository.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthLocalDataSource local,
    required Dio dio,
    required Connectivity connectivity,
  })  : _local = local,
        _dio = dio,
        _connectivity = connectivity;

  final AuthLocalDataSource _local;
  final Dio _dio;
  final Connectivity _connectivity;

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    UserEntity user;
    if (await _isOnline()) {
      try {
        final response = await _dio.get<dynamic>(ApiEndpoints.profile);
        user = UserEntity.fromJson(response.data as Map<String, dynamic>)
            .copyWith(email: email, isLoggedIn: true);
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
  Future<void> logout() => _local.clearUser();

  @override
  Future<UserEntity?> getCurrentUser() async => _local.getCurrentUser();

  @override
  bool isLoggedIn() {
    final user = _local.getCurrentUser();
    return user?.isLoggedIn ?? false;
  }

  @override
  Future<UserEntity> getProfile({bool forceRefresh = false}) async {
    final cached = _local.getCurrentUser();
    if (cached != null && !forceRefresh && !await _isOnline()) {
      return cached;
    }

    if (await _isOnline()) {
      try {
        final response = await _dio.get<dynamic>(ApiEndpoints.profile);
        final user = UserEntity.fromJson(response.data as Map<String, dynamic>)
            .copyWith(isLoggedIn: true);
        await _local.saveUser(user);
        return user;
      } on DioException {
        if (cached != null) return cached;
      }
    }

    return cached ??
        UserEntity(
          id: 'guest',
          name: 'Guest',
          email: 'guest@delivery.app',
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
}
