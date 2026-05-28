import 'package:dartz/dartz.dart';
import 'package:delivery_app/core/constants/storage_keys.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/driver/shared/domain/entities/app_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwitchAppModeParams {
  const SwitchAppModeParams({required this.mode});

  final AppMode mode;
}

class SwitchAppModeUseCase extends UseCase<AppMode, SwitchAppModeParams> {
  SwitchAppModeUseCase({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  @override
  Future<Either<Failure, AppMode>> call(SwitchAppModeParams params) async {
    await _sharedPreferences.setString(
      StorageKeys.appMode,
      params.mode.storageKey,
    );
    return Right(params.mode);
  }
}
