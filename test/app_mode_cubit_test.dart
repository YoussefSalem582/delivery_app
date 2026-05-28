import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/core/constants/storage_keys.dart';
import 'package:delivery_app/features/driver/shared/domain/entities/app_mode.dart';
import 'package:delivery_app/features/driver/shared/domain/usecases/switch_app_mode_usecase.dart';
import 'package:delivery_app/features/driver/shared/presentation/cubit/app_mode_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppModeCubit', () {
    SwitchAppModeUseCase buildUseCase(SharedPreferences prefs) =>
        SwitchAppModeUseCase(sharedPreferences: prefs);

    test('restores driver mode from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        StorageKeys.appMode: AppMode.driver.storageKey,
      });
      final prefs = await SharedPreferences.getInstance();
      final cubit = AppModeCubit(
        sharedPreferences: prefs,
        switchAppMode: buildUseCase(prefs),
      );

      expect(cubit.state.mode, AppMode.driver);
      expect(cubit.state.isDriver, isTrue);

      await cubit.close();
    });

    test('persists mode when toggled via SwitchAppModeUseCase', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = AppModeCubit(
        sharedPreferences: prefs,
        switchAppMode: buildUseCase(prefs),
      );

      await cubit.setMode(AppMode.driver);
      expect(cubit.state.mode, AppMode.driver);
      expect(prefs.getString(StorageKeys.appMode), AppMode.driver.storageKey);

      await cubit.resetToPassenger();
      expect(cubit.state.mode, AppMode.passenger);

      await cubit.close();
    });
  });
}
