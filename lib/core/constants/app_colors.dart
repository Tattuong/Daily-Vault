import 'package:flutter/material.dart';

/// Daily Vault — deep navy, teal & gold palette for a secure vault feel.
class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E40AF);

  static const Color accent = Color(0xFF14B8A6);
  static const Color accentAlt = Color(0xFF6366F1);

  static const Color background = Color(0xFFF0F4FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE8EEF7);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF64748B);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color coin = Color(0xFFFBBF24);

  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF151F33);

  static const Color password = Color(0xFF2563EB);
  static const Color note = Color(0xFF14B8A6);
  static const Color document = Color(0xFF6366F1);
  static const Color secure = Color(0xFF22C55E);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A5F), Color(0xFF2563EB), Color(0xFF60A5FA)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF14B8A6)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFFFBBF24)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1220), Color(0xFF1E3A5F), Color(0xFF2563EB)],
  );

  static const List<Color> categoryPalette = [
    Color(0xFF2563EB),
    Color(0xFF14B8A6),
    Color(0xFF6366F1),
    Color(0xFFFBBF24),
    Color(0xFF22C55E),
    Color(0xFF8B5CF6),
    Color(0xFF60A5FA),
    Color(0xFF64748B),
  ];
}

extension AppBrand on BuildContext {
  Color get brand => Theme.of(this).colorScheme.primary;
  Color get canvasBg => Theme.of(this).scaffoldBackgroundColor;
  Color get panel => Theme.of(this).colorScheme.surface;

  LinearGradient get brandGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(this).colorScheme.primary,
          Theme.of(this).colorScheme.secondary,
        ],
      );
}
