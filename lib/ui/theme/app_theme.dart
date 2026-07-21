import 'package:flutter/material.dart';

class GitPetTheme {
  GitPetTheme._();

  static const _seed = Color(0xFF22D3EE);
  static const _darkNavy = Color(0xFF0F172A);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final generated = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;
    final scheme = isDark
        ? generated.copyWith(
            primary: _seed,
            onPrimary: _darkNavy,
            secondary: const Color(0xFFA78BFA),
            onSecondary: _darkNavy,
            tertiary: const Color(0xFFF472B6),
            onTertiary: _darkNavy,
            surface: _darkNavy,
            onSurface: Colors.white,
            primaryContainer: const Color(0xFFFDE047),
            onPrimaryContainer: _darkNavy,
            secondaryContainer: const Color(0xFF111B33),
            onSecondaryContainer: const Color(0xFFCBD5E1),
          )
        : generated.copyWith(
            primary: const Color(0xFF0891B2),
            onPrimary: Colors.white,
            secondary: const Color(0xFF7C3AED),
            onSecondary: Colors.white,
            tertiary: const Color(0xFFDB2777),
            onTertiary: Colors.white,
            surface: const Color(0xFFF8FAFC),
            onSurface: const Color(0xFF0F172A),
            primaryContainer: const Color(0xFFCFFAFE),
            onPrimaryContainer: const Color(0xFF164E63),
            secondaryContainer: const Color(0xFFEDE9FE),
            onSecondaryContainer: const Color(0xFF4C1D95),
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      dividerTheme: DividerThemeData(color: scheme.appPanelBorder),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: scheme.appOnSurfaceMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.appSoftSurface,
        hintStyle: TextStyle(color: scheme.appOnSurfaceFaint),
        prefixIconColor: scheme.appOnSurfaceSubtle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? scheme.surfaceContainerHighest
            : scheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: isDark ? scheme.onSurface : Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

extension GitPetColorScheme on ColorScheme {
  bool get _isDark => brightness == Brightness.dark;

  Color get appPanelSurface => _isDark
      ? Colors.white.withValues(alpha: 0.06)
      : surfaceContainerHigh.withValues(alpha: 0.88);

  Color get appPanelBorder => _isDark
      ? Colors.white.withValues(alpha: 0.08)
      : outlineVariant.withValues(alpha: 0.76);

  Color get appContentSurface =>
      _isDark ? Colors.black.withValues(alpha: 0.18) : surfaceContainerLow;

  Color get appSoftSurface => _isDark
      ? Colors.white.withValues(alpha: 0.05)
      : surfaceContainerHighest.withValues(alpha: 0.64);

  Color get appSofterSurface => _isDark
      ? Colors.white.withValues(alpha: 0.04)
      : surfaceContainerHighest.withValues(alpha: 0.42);

  Color get appOnSurfaceMuted =>
      onSurface.withValues(alpha: _isDark ? 0.70 : 0.66);

  Color get appOnSurfaceSubtle =>
      onSurface.withValues(alpha: _isDark ? 0.56 : 0.52);

  Color get appOnSurfaceFaint =>
      onSurface.withValues(alpha: _isDark ? 0.38 : 0.36);

  Color get appOnSurfaceDisabled => onSurface.withValues(alpha: 0.24);
}
