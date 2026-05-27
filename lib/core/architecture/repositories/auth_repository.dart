import 'package:delivery_app/core/architecture/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String email, required String password});
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  UserEntity? get cachedUser;
  Future<UserEntity> getProfile({bool forceRefresh = false});
  Future<UserEntity> updateWalletBalance(double amount);
  bool isLoggedIn();
}
