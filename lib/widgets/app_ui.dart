import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/app_theme_preset.dart';
import '../providers/shop_provider.dart';

class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    return GoogleFonts.plusJakartaSansTextTheme(base);
  }

  static TextStyle displayLarge({Color? color}) =>
      GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1, color: color);

  static TextStyle titleLarge({Color? color}) =>
      GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: color);

  static TextStyle labelBold({Color? color, double size = 12}) =>
      GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: FontWeight.w700, color: color);
}

class AppDecorations {
  static BoxDecoration glassCard({
    required bool isDark,
    double radius = 24,
    CardStyle? skin,
  }) {
    final style = skin ?? CardStyle.defaultStyle;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(style.borderRadius > 0 ? style.borderRadius : radius),
      color: style.glassEffect
          ? (isDark ? AppColors.darkSurface.withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.72))
          : (isDark ? AppColors.darkSurface.withValues(alpha: 0.88) : Colors.white.withValues(alpha: 0.94)),
      border: Border.all(
        color: style.borderWidth > 0
            ? style.borderColor.withValues(alpha: isDark ? 0.5 : 0.7)
            : (isDark ? Colors.white : AppColors.primary).withValues(alpha: 0.1),
        width: style.borderWidth > 0 ? style.borderWidth : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: (style.borderWidth > 0 ? style.accentColor : AppColors.primary).withValues(alpha: isDark ? 0.14 : 0.07),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static Widget meshBackground({
    required bool isDark,
    required Widget child,
    LinearGradient? backgroundGradient,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (backgroundGradient != null)
          DecoratedBox(decoration: BoxDecoration(gradient: backgroundGradient))
        else
          ColoredBox(color: isDark ? AppColors.darkBackground : AppColors.background),
        Positioned(top: -100, left: -60, child: GlowOrb(color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.18), size: 280)),
        Positioned(top: 80, right: -80, child: GlowOrb(color: AppColors.accent.withValues(alpha: isDark ? 0.22 : 0.12), size: 220)),
        Positioned(bottom: 120, left: 40, child: GlowOrb(color: AppColors.accentAlt.withValues(alpha: isDark ? 0.15 : 0.08), size: 180)),
        child,
      ],
    );
  }
}

class GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const GlowOrb({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Standard page shell — mesh background, header row, scrollable body.
class AppPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final List<Widget> children;
  final Widget? floatingActionButton;

  const AppPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    required this.children,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shop = context.watch<ShopProvider>();
    final preset = shop.activeTheme;
    final bg = shop.activeBackground;
    final useShopBg = shop.activeBackgroundId != 'bg_default';

    return Scaffold(
      backgroundColor: isDark ? preset.darkBackground : preset.background,
      floatingActionButton: floatingActionButton,
      body: AppDecorations.meshBackground(
        isDark: isDark,
        backgroundGradient: useShopBg ? bg.gradient : null,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: AppTypography.titleLarge()),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(subtitle!, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                          ],
                        ],
                      ),
                    ),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  children: children,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool compact;

  const AppScreenHeader({super.key, required this.title, required this.subtitle, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 12 : 0, compact ? 0 : 0, 16, compact ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge()),
          if (!compact) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, height: 1.35)),
          ],
        ],
      ),
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  final String label;
  final IconData? icon;

  const AppSectionHeader(this.label, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 8, left: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
          ],
          Text(label, style: AppTypography.labelBold(color: AppColors.onSurfaceVariant, size: 13)),
        ],
      ),
    );
  }
}

class AppGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double radius;

  const AppGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skin = context.watch<ShopProvider>().activeCardStyle;
    final effectiveRadius = skin.borderRadius > 0 ? skin.borderRadius : radius;
    final box = Container(
      padding: padding,
      decoration: AppDecorations.glassCard(isDark: isDark, radius: effectiveRadius, skin: skin),
      child: skin.glassEffect
          ? ClipRRect(
              borderRadius: BorderRadius.circular(effectiveRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: child,
              ),
            )
          : child,
    );
    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(effectiveRadius), child: box),
    );
  }
}

class AppSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const AppSettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    return AppGlassCard(
      padding: EdgeInsets.zero,
      radius: 18,
      onTap: onTap,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: AppTypography.labelBold(size: 14)),
        subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)) : null,
        trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)) : null),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 44, color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AppFilterChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? primary : AppColors.onSurfaceVariant.withValues(alpha: 0.25)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class AppFormScreen extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onSave;
  final String saveLabel;
  final List<Widget>? appBarActions;

  const AppFormScreen({
    super.key,
    required this.title,
    required this.children,
    required this.onSave,
    required this.saveLabel,
    this.appBarActions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shop = context.watch<ShopProvider>();
    final useShopBg = shop.activeBackgroundId != 'bg_default';

    return Scaffold(
      body: AppDecorations.meshBackground(
        isDark: isDark,
        backgroundGradient: useShopBg ? shop.activeBackground.gradient : null,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    ),
                    Expanded(child: Text(title, style: AppTypography.titleLarge())),
                    if (appBarActions != null) ...appBarActions!,
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    AppGlassCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(onPressed: onSave, child: Text(saveLabel)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
