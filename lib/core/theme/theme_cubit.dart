import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app/core/utils/constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(ThemeMode.system) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final value = _prefs.getString(AppConstants.themeKey);
    emit(
      switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    await _prefs.setString(
      AppConstants.themeKey,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
  }

  Future<void> toggleDark(bool isDark) async {
    await setTheme(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}

class LocaleCubit extends Cubit<String> {
  LocaleCubit(this._prefs) : super('en') {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    emit(_prefs.getString(AppConstants.localeKey) ?? 'en');
  }

  Future<void> setLocale(String code) async {
    emit(code);
    await _prefs.setString(AppConstants.localeKey, code);
  }
}

class ThemeState extends Equatable {
  const ThemeState(this.mode);
  final ThemeMode mode;
  @override
  List<Object?> get props => [mode];
}
