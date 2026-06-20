import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_purchase_sheet.dart';
import '../auth/change_pin_screen.dart';
import '../main_shell.dart';
import '../privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final theme = context.watch<ThemeProvider>();
    final locale = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();

    return AppPageScaffold(
      title: AppStrings.t(context, 'settingsTitle'),
      subtitle: AppStrings.t(context, 'settingsSubtitle'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: CoinBalanceChip(onTap: () => CoinPurchaseSheet.show(context)),
        ),
      ],
      children: [
        AppSectionHeader(AppStrings.t(context, 'securitySection'), icon: Icons.security_rounded),
        if (auth.canUseBiometric)
          AppGlassCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              secondary: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fingerprint_rounded, color: AppColors.accent, size: 20),
              ),
              title: Text(AppStrings.t(context, 'biometricLock'), style: AppTypography.labelBold(size: 14)),
              subtitle: Text(AppStrings.t(context, 'biometricLockDesc'), style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              value: auth.biometricEnabled,
              onChanged: (v) async {
                final ok = await auth.toggleBiometric(v, AppStrings.t(context, 'biometricReason'));
                if (!ok && context.mounted) {
                  AppToast.show(context, title: AppStrings.t(context, 'biometricNotAvailable'));
                }
              },
            ),
          )
        else
          AppSettingTile(
            icon: Icons.fingerprint_rounded,
            title: AppStrings.t(context, 'biometricLock'),
            subtitle: AppStrings.t(context, 'biometricNotAvailable'),
            iconColor: AppColors.onSurfaceVariant,
          ),
        const SizedBox(height: 8),
        AppSettingTile(
          icon: Icons.pin_rounded,
          title: AppStrings.t(context, 'changePin'),
          subtitle: AppStrings.t(context, 'changePinDesc'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePinScreen())),
        ),
        AppSectionHeader(AppStrings.t(context, 'activeCustomization'), icon: Icons.palette_outlined),
        AppSettingTile(
          icon: Icons.palette_outlined,
          title: AppStrings.t(context, 'activeTheme'),
          subtitle: AppStrings.t(context, _themeNameKey(shop.activeThemeId)),
        ),
        const SizedBox(height: 8),
        AppSettingTile(
          icon: Icons.layers_outlined,
          title: AppStrings.t(context, 'activeBackground'),
          subtitle: AppStrings.t(context, _bgNameKey(shop.activeBackgroundId)),
        ),
        const SizedBox(height: 8),
        AppSettingTile(
          icon: Icons.style_outlined,
          title: AppStrings.t(context, 'activeSkin'),
          subtitle: AppStrings.t(context, _skinNameKey(shop.activeSkinId)),
        ),
        AppSectionHeader(AppStrings.t(context, 'appearance'), icon: Icons.dark_mode_outlined),
        AppGlassCard(
          padding: EdgeInsets.zero,
          child: SwitchListTile(
            secondary: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.dark_mode_outlined, color: AppColors.primary, size: 20),
            ),
            title: Text(AppStrings.t(context, 'darkMode'), style: AppTypography.labelBold(size: 14)),
            value: theme.isDarkMode,
            onChanged: (_) => theme.toggleTheme(),
          ),
        ),
        AppSectionHeader(AppStrings.t(context, 'premiumFeatures'), icon: Icons.workspace_premium_outlined),
        if (shop.hasExportData) ...[
          AppSettingTile(
            icon: Icons.file_download_outlined,
            title: AppStrings.t(context, 'exportData'),
            subtitle: AppStrings.t(context, 'exportDataDesc'),
            trailing: const Icon(Icons.share_outlined, color: AppColors.primary),
            onTap: () => _exportData(context, shop),
          ),
          const SizedBox(height: 8),
        ] else
          AppSettingTile(
            icon: Icons.file_download_outlined,
            title: AppStrings.t(context, 'exportData'),
            subtitle: AppStrings.t(context, 'exportLocked'),
            onTap: () => MainShell.of(context)?.openShop(),
          ),
        AppSectionHeader(AppStrings.t(context, 'other'), icon: Icons.more_horiz_rounded),
        AppSettingTile(
          icon: Icons.language_outlined,
          title: AppStrings.t(context, 'language'),
          subtitle: locale.isVietnamese ? AppStrings.t(context, 'vietnamese') : AppStrings.t(context, 'english'),
          onTap: () => _pickLanguage(context, locale),
        ),
        const SizedBox(height: 8),
        AppSettingTile(
          icon: Icons.stars_rounded,
          title: AppStrings.t(context, 'openShop'),
          subtitle: AppStrings.t(context, 'openShopDesc'),
          iconColor: AppColors.coin,
          onTap: () => MainShell.of(context)?.openShop(),
        ),
        const SizedBox(height: 8),
        AppSettingTile(
          icon: Icons.privacy_tip_outlined,
          title: AppStrings.t(context, 'privacyPolicy'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            AppStrings.t(context, 'copyright'),
            style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context, ShopProvider shop) async {
    final text = context.read<VaultProvider>().exportAll((key) => AppStrings.t(context, key));
    if (text.isEmpty) {
      AppToast.show(context, title: AppStrings.t(context, 'exportEmpty'));
      return;
    }
    final branded = shop.hasNoWatermark ? text : '$text\n\n--- Daily Vault ---';
    await Share.share(branded);
    await shop.rewardForShare();
    if (context.mounted) AppToast.show(context, title: AppStrings.t(context, 'exportDone'));
  }

  Future<void> _pickLanguage(BuildContext context, LocaleProvider locale) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Text('🇺🇸', style: TextStyle(fontSize: 22)),
                  title: Text(AppStrings.t(context, 'english')),
                  trailing: !locale.isVietnamese ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                  onTap: () async {
                    await locale.setEnglish();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Text('🇻🇳', style: TextStyle(fontSize: 22)),
                  title: Text(AppStrings.t(context, 'vietnamese')),
                  trailing: locale.isVietnamese ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                  onTap: () async {
                    await locale.setVietnamese();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _themeNameKey(String id) => switch (id) {
        'theme_ocean' => 'shopThemeOcean',
        'theme_midnight' => 'shopThemeMidnight',
        'theme_emerald' => 'shopThemeEmerald',
        'theme_royal' => 'shopThemeRoyal',
        _ => 'themeDefault',
      };

  String _bgNameKey(String id) => switch (id) {
        'bg_vault' => 'shopBgVault',
        'bg_ocean' => 'shopBgOcean',
        'bg_aurora' => 'shopBgAurora',
        'bg_galaxy' => 'shopBgGalaxy',
        _ => 'bgDefault',
      };

  String _skinNameKey(String id) => switch (id) {
        'skin_neon' => 'shopSkinNeon',
        'skin_classic' => 'shopSkinClassic',
        'skin_glass' => 'shopSkinGlass',
        _ => 'skinDefault',
      };
}
