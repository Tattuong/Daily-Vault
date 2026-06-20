import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/app_ui.dart';

class AppThemePreset {
  final String id;
  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color darkBackground;
  final Color darkSurface;
  final LinearGradient headerGradient;
  final LinearGradient balanceGradient;

  const AppThemePreset({
    required this.id,
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.darkBackground,
    required this.darkSurface,
    required this.headerGradient,
    required this.balanceGradient,
  });

  ThemeData lightTheme() => _buildTheme(
        brightness: Brightness.light,
        scaffold: background,
        surfaceColor: surface,
        onSurface: AppColors.onSurface,
      );

  ThemeData darkTheme() => _buildTheme(
        brightness: Brightness.dark,
        scaffold: darkBackground,
        surfaceColor: darkSurface,
        onSurface: const Color(0xFFF1F5F9),
      );

  ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffold,
    required Color surfaceColor,
    required Color onSurface,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryLight,
              secondary: primary,
              tertiary: AppColors.accent,
              surface: surfaceColor,
              onSurface: onSurface,
              onPrimary: AppColors.onPrimary,
            )
          : ColorScheme.light(
              primary: primary,
              secondary: primaryLight,
              tertiary: AppColors.accent,
              surface: surfaceColor,
              onPrimary: AppColors.onPrimary,
              onSurface: onSurface,
            ),
      textTheme: AppTypography.textTheme(brightness),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.titleLarge(color: onSurface),
        iconTheme: IconThemeData(color: onSurface),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? primaryLight : primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSurface : AppColors.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? primaryLight : primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: primary.withValues(alpha: 0.15)),
      ),
    );
  }
}

class AppThemePresets {
  AppThemePresets._();

  static const AppThemePreset defaultPreset = AppThemePreset(
    id: 'theme_default',
    primary: AppColors.primary,
    primaryLight: AppColors.primaryLight,
    background: AppColors.background,
    surface: AppColors.surface,
    darkBackground: AppColors.darkBackground,
    darkSurface: AppColors.darkSurface,
    headerGradient: AppColors.headerGradient,
    balanceGradient: AppColors.heroGradient,
  );

  static const AppThemePreset ocean = AppThemePreset(
    id: 'theme_ocean',
    primary: Color(0xFF0284C7),
    primaryLight: Color(0xFF38BDF8),
    background: Color(0xFFF0F9FF),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF0C1929),
    darkSurface: Color(0xFF1A3050),
    headerGradient: LinearGradient(colors: [Color(0xFF0369A1), Color(0xFF0284C7), Color(0xFF38BDF8)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF14B8A6)]),
  );

  static const AppThemePreset midnight = AppThemePreset(
    id: 'theme_midnight',
    primary: Color(0xFF0EA5E9),
    primaryLight: Color(0xFF38BDF8),
    background: Color(0xFFF0F9FF),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF0C1929),
    darkSurface: Color(0xFF1A3050),
    headerGradient: LinearGradient(colors: [Color(0xFF0369A1), Color(0xFF0EA5E9), Color(0xFF38BDF8)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)]),
  );

  static const AppThemePreset emerald = AppThemePreset(
    id: 'theme_emerald',
    primary: Color(0xFF059669),
    primaryLight: Color(0xFF34D399),
    background: Color(0xFFECFDF5),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF0D2824),
    darkSurface: Color(0xFF1A4038),
    headerGradient: LinearGradient(colors: [Color(0xFF047857), Color(0xFF059669), Color(0xFF34D399)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF059669), Color(0xFF14B8A6)]),
  );

  static const AppThemePreset royal = AppThemePreset(
    id: 'theme_royal',
    primary: Color(0xFF7C3AED),
    primaryLight: Color(0xFFA78BFA),
    background: Color(0xFFF5F3FF),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF2A1030),
    darkSurface: Color(0xFF451A50),
    headerGradient: LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF7C3AED), Color(0xFFA78BFA)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF6366F1)]),
  );

  static const Map<String, AppThemePreset> byId = {
    'theme_default': defaultPreset,
    'theme_ocean': ocean,
    'theme_midnight': midnight,
    'theme_emerald': emerald,
    'theme_royal': royal,
  };

  static AppThemePreset get(String? id) => byId[id] ?? defaultPreset;
}

class AppBackground {
  final String id;
  final LinearGradient gradient;

  const AppBackground({required this.id, required this.gradient});

  static const AppBackground defaultBg = AppBackground(
    id: 'bg_default',
    gradient: AppColors.heroGradient,
  );

  static const AppBackground vault = AppBackground(
    id: 'bg_vault',
    gradient: LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF2563EB), Color(0xFF14B8A6)]),
  );

  static const AppBackground ocean = AppBackground(
    id: 'bg_ocean',
    gradient: LinearGradient(colors: [Color(0xFF4338CA), Color(0xFF6366F1), Color(0xFF2DD4BF)]),
  );

  static const AppBackground aurora = AppBackground(
    id: 'bg_aurora',
    gradient: LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF6366F1), Color(0xFF2DD4BF)]),
  );

  static const AppBackground galaxy = AppBackground(
    id: 'bg_galaxy',
    gradient: LinearGradient(colors: [Color(0xFF1E1B4B), Color(0xFF4338CA), Color(0xFF818CF8)]),
  );

  static const Map<String, AppBackground> byId = {
    'bg_default': defaultBg,
    'bg_vault': vault,
    'bg_ocean': ocean,
    'bg_aurora': aurora,
    'bg_galaxy': galaxy,
  };

  static AppBackground get(String? id) => byId[id] ?? defaultBg;
}

class CardStyle {
  final String id;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color accentColor;
  final bool glassEffect;

  const CardStyle({
    required this.id,
    this.borderRadius = 20,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.accentColor = AppColors.primary,
    this.glassEffect = false,
  });

  static const CardStyle defaultStyle = CardStyle(id: 'skin_default');

  static const CardStyle neon = CardStyle(
    id: 'skin_neon',
    borderRadius: 22,
    borderWidth: 2,
    borderColor: Color(0xFF2DD4BF),
    accentColor: Color(0xFF2DD4BF),
  );

  static const CardStyle classic = CardStyle(
    id: 'skin_classic',
    borderRadius: 16,
    borderWidth: 1.5,
    borderColor: Color(0xFFFBBF24),
    accentColor: Color(0xFFFB7185),
  );

  static const CardStyle glass = CardStyle(
    id: 'skin_glass',
    borderRadius: 24,
    borderWidth: 1,
    borderColor: Colors.white54,
    accentColor: Color(0xFF818CF8),
    glassEffect: true,
  );

  static const Map<String, CardStyle> byId = {
    'skin_default': defaultStyle,
    'skin_neon': neon,
    'skin_classic': classic,
    'skin_glass': glass,
  };

  static CardStyle get(String? id) => byId[id] ?? defaultStyle;
}
