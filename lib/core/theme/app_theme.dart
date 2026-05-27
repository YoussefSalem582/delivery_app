import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark ? _darkScheme : _lightScheme;
    final textTheme = _textTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NoktaSpacing.radiusLg),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHigh
            : NoktaColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, NoktaSpacing.buttonHeight),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
          ),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: NoktaSpacing.bottomNavHeight,
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainerLowest,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            size: 24,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(NoktaSpacing.radiusSheet),
          ),
        ),
        showDragHandle: false,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: colorScheme.surfaceContainerLowest,
        foregroundColor: colorScheme.primary,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
    );
  }

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: NoktaColors.primary,
    onPrimary: NoktaColors.onPrimary,
    primaryContainer: NoktaColors.primaryContainer,
    onPrimaryContainer: NoktaColors.onPrimaryContainer,
    secondary: NoktaColors.secondary,
    onSecondary: NoktaColors.onSecondary,
    secondaryContainer: NoktaColors.secondaryContainer,
    onSecondaryContainer: NoktaColors.onSecondaryContainer,
    tertiary: NoktaColors.tertiary,
    onTertiary: NoktaColors.onTertiary,
    tertiaryContainer: NoktaColors.tertiaryContainer,
    onTertiaryContainer: NoktaColors.onTertiaryContainer,
    error: NoktaColors.error,
    onError: NoktaColors.onError,
    errorContainer: NoktaColors.errorContainer,
    onErrorContainer: NoktaColors.onErrorContainer,
    surface: NoktaColors.surface,
    onSurface: NoktaColors.onSurface,
    onSurfaceVariant: NoktaColors.onSurfaceVariant,
    outline: NoktaColors.outline,
    outlineVariant: NoktaColors.outlineVariant,
    inverseSurface: NoktaColors.inverseSurface,
    onInverseSurface: Color(0xFFEFF1F4),
    inversePrimary: NoktaColors.inversePrimary,
    surfaceContainerHighest: NoktaColors.surfaceContainerHighest,
    surfaceContainerHigh: NoktaColors.surfaceContainerHigh,
    surfaceContainer: NoktaColors.surfaceContainer,
    surfaceContainerLow: NoktaColors.surfaceContainerLow,
    surfaceContainerLowest: NoktaColors.surfaceContainerLowest,
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: NoktaColors.primaryContainer,
    onPrimary: NoktaColors.onPrimary,
    primaryContainer: NoktaColors.primary,
    onPrimaryContainer: NoktaColors.onPrimaryContainer,
    secondary: NoktaColors.secondaryContainer,
    onSecondary: NoktaColors.onSecondaryContainer,
    secondaryContainer: NoktaColors.secondary,
    onSecondaryContainer: NoktaColors.secondaryContainer,
    tertiary: NoktaColors.tertiaryFixedDim,
    onTertiary: Color(0xFF271900),
    tertiaryContainer: NoktaColors.tertiaryContainer,
    onTertiaryContainer: NoktaColors.onTertiaryContainer,
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: NoktaColors.errorContainer,
    surface: NoktaColors.darkSurface,
    onSurface: Color(0xFFE2E8F0),
    onSurfaceVariant: Color(0xFF94A3B8),
    outline: Color(0xFF64748B),
    outlineVariant: Color(0xFF334155),
    inverseSurface: Color(0xFFE2E8F0),
    onInverseSurface: NoktaColors.darkSurface,
    inversePrimary: NoktaColors.primary,
    surfaceContainerHighest: Color(0xFF1E293B),
    surfaceContainerHigh: Color(0xFF1A2332),
    surfaceContainer: Color(0xFF162032),
    surfaceContainerLow: Color(0xFF131B2A),
    surfaceContainerLowest: Color(0xFF0F172A),
  );

  static TextTheme _textTheme(ColorScheme colorScheme) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 48,
        height: 56 / 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 48,
        color: colorScheme.onSurface,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01 * 32,
        color: colorScheme.onSurface,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: colorScheme.onPrimary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
