import 'dart:async';

import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';

typedef TripDataChangedCallback = void Function();
typedef UserDataChangedCallback = void Function(UserEntity user);

class AppDataCoordinator {
  Timer? _debounce;
  TripDataChangedCallback? onTripDataChanged;
  UserDataChangedCallback? onUserDataChanged;

  void notifyTripDataChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      onTripDataChanged?.call();
    });
  }

  void notifyUserDataChanged(UserEntity user) {
    onUserDataChanged?.call(user);
  }

  void dispose() {
    _debounce?.cancel();
  }
}
