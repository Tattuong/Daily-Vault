import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../providers/shop_provider.dart';
import '../screens/main_shell.dart';

/// Placeholder banner shown until user removes ads via shop or IAP.
class AdBannerPlaceholder extends StatelessWidget {
  const AdBannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    if (shop.hasRemoveAds) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => MainShell.of(context)?.openShop(),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.onSurfaceVariant.withValues(alpha: 0.08),
                  AppColors.onSurfaceVariant.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.onSurfaceVariant.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ads_click_rounded, size: 18, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                const SizedBox(width: 8),
                Text(
                  AppStrings.t(context, 'adPlaceholder'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
