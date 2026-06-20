import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../widgets/app_ui.dart';
import 'settings/settings_screen.dart';
import 'shop/shop_screen.dart';
import 'vault/vault_home_screen.dart';
import 'vault/vault_list_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static MainShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainShellState>();

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _index = 0;
  final _shopKey = GlobalKey<ShopScreenState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Lock handled via AuthProvider when returning
    }
  }

  void openShop({ShopRewardsTab tab = ShopRewardsTab.all}) {
    setState(() => _index = 2);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shopKey.currentState?.selectTab(tab);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preset = Theme.of(context).colorScheme;
    final screens = [
      const VaultHomeScreen(),
      const BrowseScreen(),
      ShopScreen(key: _shopKey, embedded: true),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: IndexedStack(index: _index, children: screens),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkSurface : Colors.white).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: preset.primary.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: AppStrings.t(context, 'navHome'),
                    active: _index == 0,
                    onTap: () => setState(() => _index = 0),
                  ),
                  _NavItem(
                    icon: Icons.inventory_2_outlined,
                    activeIcon: Icons.inventory_2_rounded,
                    label: AppStrings.t(context, 'navBrowse'),
                    active: _index == 1,
                    onTap: () => setState(() => _index = 1),
                  ),
                  _NavItem(
                    icon: Icons.stars_outlined,
                    activeIcon: Icons.stars_rounded,
                    label: AppStrings.t(context, 'navShop'),
                    active: _index == 2,
                    onTap: () => setState(() => _index = 2),
                    accent: AppColors.coin,
                  ),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: AppStrings.t(context, 'navSettings'),
                    active: _index == 3,
                    onTap: () => setState(() => _index = 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? accent;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? (accent ?? Theme.of(context).colorScheme.primary) : AppColors.onSurfaceVariant;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(active ? activeIcon : icon, color: color, size: 21),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTypography.labelBold(color: color, size: 8),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
