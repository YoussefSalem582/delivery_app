import 'package:delivery_app/core/constants/storage_keys.dart';
import 'package:delivery_app/features/driver/shared/domain/entities/app_mode.dart';
import 'package:delivery_app/features/driver/shared/domain/usecases/switch_app_mode_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SwitchAppModeUseCase', () {
    test('persists app mode to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final useCase = SwitchAppModeUseCase(sharedPreferences: prefs);

      final result = await useCase(
        const SwitchAppModeParams(mode: AppMode.driver),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected success'),
        (mode) => expect(mode, AppMode.driver),
      );
      expect(
        prefs.getString(StorageKeys.appMode),
        AppMode.driver.storageKey,
      );
    });
  });
}
