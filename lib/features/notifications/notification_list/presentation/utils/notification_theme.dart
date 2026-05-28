import 'package:flutter/material.dart';

/// Theme-aware colors for the notifications inbox (light + dark).
class NotificationTheme {
  NotificationTheme(this._scheme, this._isDark);

  factory NotificationTheme.of(BuildContext context) {
    final theme = Theme.of(context);
    return NotificationTheme(
      theme.colorScheme,
      theme.brightness == Brightness.dark,
    );
  }

  final ColorScheme _scheme;
  final bool _isDark;

  bool get isDark => _isDark;

  Color get scaffoldBackground => _scheme.surfaceContainer;

  Color cardBackground({required bool isRead}) {
    if (isRead) return _scheme.surfaceContainerLow;
    return _isDark
        ? _scheme.surfaceContainerHigh
        : _scheme.surfaceContainerLowest;
  }

  Color cardBorder({required bool isRead}) {
    if (isRead) {
      return _scheme.outlineVariant.withValues(alpha: _isDark ? 0.55 : 1);
    }
    return _isDark
        ? _scheme.inversePrimary.withValues(alpha: 0.45)
        : _scheme.primary.withValues(alpha: 0.35);
  }

  List<BoxShadow>? cardShadow({required bool isRead}) {
    if (isRead || !_isDark) return null;
    return [
      BoxShadow(
        color: _scheme.primary.withValues(alpha: 0.14),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  Color get unreadAccent => _isDark ? _scheme.inversePrimary : _scheme.primary;

  Color get unreadIndicator => unreadAccent;

  Color iconBackground({required bool isRead}) {
    if (isRead) {
      return _isDark ? _scheme.surfaceContainerHighest : _scheme.surfaceContainer;
    }
    return _isDark
        ? _scheme.primary.withValues(alpha: 0.18)
        : _scheme.primaryContainer.withValues(alpha: 0.2);
  }

  Color iconForeground({required bool isRead}) {
    if (isRead) {
      return _scheme.onSurfaceVariant;
    }
    return _isDark ? _scheme.inversePrimary : _scheme.primary;
  }

  Color titleColor({required bool isRead}) {
    if (!_isDark) return _scheme.onSurface;
    return isRead
        ? _scheme.onSurface.withValues(alpha: 0.92)
        : _scheme.onSurface;
  }

  Color get bodyColor => _scheme.onSurfaceVariant;

  Color get timestampColor =>
      _isDark ? _scheme.onSurfaceVariant : _scheme.outline;

  Color get chevronColor =>
      _isDark ? _scheme.onSurfaceVariant : _scheme.outline;

  Color get sectionHeader =>
      _isDark ? _scheme.onSurface.withValues(alpha: 0.7) : _scheme.onSurfaceVariant;

  Color get appBarTitle => _isDark ? _scheme.onSurface : _scheme.primary;

  Color get appBarAction =>
      _isDark ? _scheme.inversePrimary : _scheme.primary;

  Color get emptyIconTint =>
      _isDark ? _scheme.inversePrimary.withValues(alpha: 0.55) : _scheme.outline;

  Color? get emptyIconBackground =>
      _isDark ? _scheme.primary.withValues(alpha: 0.12) : null;

  Color get filterBarBackground => _scheme.surfaceContainerLow;

  double get filterBarBorderAlpha => _isDark ? 0.35 : 0.4;

  Color get swipeDeleteBackground =>
      _isDark ? _scheme.error.withValues(alpha: 0.22) : _scheme.errorContainer;

  Color get swipeDeleteIcon =>
      _isDark ? _scheme.error : _scheme.onErrorContainer;

  Color get inkSplash =>
      _scheme.primary.withValues(alpha: _isDark ? 0.14 : 0.08);
}
