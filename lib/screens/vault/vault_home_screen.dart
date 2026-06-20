import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/vault_item.dart';
import '../../providers/shop_provider.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/ad_banner_placeholder.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_purchase_sheet.dart';
import 'vault_item_form_screen.dart';
import 'vault_list_screen.dart';

class VaultHomeScreen extends StatelessWidget {
  const VaultHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultProvider>();
    final shop = context.watch<ShopProvider>();

    return AppPageScaffold(
      title: AppStrings.t(context, 'homeTitle'),
      subtitle: AppStrings.t(context, 'homeSubtitle'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: CoinBalanceChip(onTap: () => CoinPurchaseSheet.show(context)),
        ),
      ],
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: AppStrings.t(context, 'searchHint'),
            prefixIcon: const Icon(Icons.search_rounded),
          ),
          onChanged: vault.setSearchQuery,
        ),
        const SizedBox(height: 16),
        AppSectionHeader(AppStrings.t(context, 'quickAdd'), icon: Icons.add_circle_outline_rounded),
        _CategoryGrid(),
        if (vault.recentItems.isNotEmpty) ...[
          AppSectionHeader(AppStrings.t(context, 'recentItems'), icon: Icons.schedule_rounded),
          ...vault.recentItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RecentItemTile(item: item),
              )),
        ],
        if (vault.items.isEmpty)
          AppEmptyState(
            icon: Icons.shield_outlined,
            message: AppStrings.t(context, 'homeEmpty'),
          ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultProvider>();

    final categories = [
      _Cat(VaultItemType.password, Icons.key_rounded, AppColors.password, 'categoryPasswords', 'categoryPasswordsDesc'),
      _Cat(VaultItemType.note, Icons.note_alt_outlined, AppColors.note, 'categoryNotes', 'categoryNotesDesc'),
      _Cat(VaultItemType.document, Icons.folder_copy_outlined, AppColors.document, 'categoryDocuments', 'categoryDocumentsDesc'),
    ];

    return GridView.count(
      crossAxisCount: 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3.2,
      mainAxisSpacing: 10,
      children: categories.map((cat) {
        final count = vault.countOf(cat.type);
        return AppGlassCard(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VaultListScreen(type: cat.type)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(cat.icon, color: cat.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.t(context, cat.titleKey), style: AppTypography.labelBold(size: 15)),
                    Text(
                      AppStrings.t(context, cat.descKey),
                      style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$count', style: AppTypography.labelBold(size: 18, color: cat.color)),
                  Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RecentItemTile extends StatelessWidget {
  final VaultItem item;

  const _RecentItemTile({required this.item});

  IconData get _icon => switch (item.type) {
        VaultItemType.password => Icons.key_rounded,
        VaultItemType.note => Icons.note_alt_outlined,
        VaultItemType.document => Icons.insert_drive_file_outlined,
      };

  Color get _color => switch (item.type) {
        VaultItemType.password => AppColors.password,
        VaultItemType.note => AppColors.note,
        VaultItemType.document => AppColors.document,
      };

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VaultItemFormScreen(item: item)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(_icon, color: _color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.title, style: AppTypography.labelBold(size: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (item.favorite) const Icon(Icons.star_rounded, color: AppColors.coin, size: 18),
        ],
      ),
    );
  }
}

class _Cat {
  final VaultItemType type;
  final IconData icon;
  final Color color;
  final String titleKey;
  final String descKey;

  const _Cat(this.type, this.icon, this.color, this.titleKey, this.descKey);
}
