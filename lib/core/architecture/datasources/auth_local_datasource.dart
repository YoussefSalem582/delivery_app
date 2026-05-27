import 'package:hive/hive.dart';
import 'package:delivery_app/core/architecture/entities/user_entity.dart';
import 'package:delivery_app/core/utils/constants.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._box);

  final Box<UserEntity> _box;
  static const _currentUserKey = 'current_user';

  UserEntity? getCurrentUser() => _box.get(_currentUserKey);

  Future<void> saveUser(UserEntity user) async {
    await _box.put(_currentUserKey, user);
  }

  Future<void> clearUser() async {
    await _box.delete(_currentUserKey);
  }
}

Future<Box<UserEntity>> openUserBox() async {
  return Hive.openBox<UserEntity>(AppConstants.userBox);
}
