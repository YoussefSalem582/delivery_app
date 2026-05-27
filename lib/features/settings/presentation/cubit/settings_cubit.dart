import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../injection_container.dart';
import 'settings_state.dart';

/// App-wide theme and locale preferences.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required SharedPreferences sharedPreferences})
      : _prefs = sharedPreferences,
        super(
          SettingsState(
            themeMode: _resolveThemeMode(sharedPreferences),
            locale: Locale(
              sharedPreferences.getString(StorageKeys.locale) ?? 'en',
            ),
          ),
        ) {
    sl<ApiClient>().setLocale(state.locale.languageCode);
  }

  final SharedPreferences _prefs;

  static ThemeMode _resolveThemeMode(SharedPreferences prefs) {
    final index = prefs.getInt(StorageKeys.themeMode);
    if (index != null && index >= 0 && index < ThemeMode.values.length) {
      return ThemeMode.values[index];
    }
    final legacy = prefs.getString('theme_mode_legacy');
    return switch (legacy) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  void setThemeMode(ThemeMode mode) {
    _prefs.setInt(StorageKeys.themeMode, mode.index);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> toggleDark(bool isDark) async {
    setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void setLocale(Locale locale) {
    _prefs.setString(StorageKeys.locale, locale.languageCode);
    sl<ApiClient>().setLocale(locale.languageCode);
    emit(state.copyWith(locale: locale));
  }
}
