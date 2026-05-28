import 'package:delivery_app/core/constants/storage_keys.dart';
import 'package:delivery_app/features/driver/shared/domain/entities/app_mode.dart';
import 'package:delivery_app/features/driver/shared/domain/usecases/switch_app_mode_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_mode_state.dart';

class AppModeCubit extends Cubit<AppModeState> {
  AppModeCubit({
    required SharedPreferences sharedPreferences,
    required SwitchAppModeUseCase switchAppMode,
  }) : _sharedPreferences = sharedPreferences,
       _switchAppMode = switchAppMode,
       super(const AppModeState(mode: AppMode.passenger)) {
    _restore();
  }

  final SharedPreferences _sharedPreferences;
  final SwitchAppModeUseCase _switchAppMode;

  void _restore() {
    final stored = _sharedPreferences.getString(StorageKeys.appMode);
    if (stored == AppMode.driver.storageKey) {
      emit(const AppModeState(mode: AppMode.driver));
    }
  }

  Future<void> setMode(AppMode mode) async {
    final result = await _switchAppMode(SwitchAppModeParams(mode: mode));
    result.fold(
      (_) {},
      (saved) => emit(AppModeState(mode: saved)),
    );
  }

  Future<void> toggleDriverMode(bool enabled) async {
    await setMode(enabled ? AppMode.driver : AppMode.passenger);
  }

  Future<void> resetToPassenger() => setMode(AppMode.passenger);
}
