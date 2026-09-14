import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/app_theme_preset.dart';
import '../../models/vault_item.dart';
import '../../providers/shop_provider.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/app_ui.dart';
import '../main_shell.dart';
import 'vault_item_form_screen.dart';

class VaultListScreen extends StatelessWidget {
  final VaultItemType type;

  const VaultListScreen({super.key, required this.type});

  String get _titleKey => switch (type) {
        VaultItemType.password => 'passwordsTitle',
        VaultItemType.note => 'notesTitle',
        VaultItemType.document => 'documentsTitle',
      };

  String get _subtitleKey => switch (type) {
        VaultItemType.password => 'passwordsSubtitle',
        VaultItemType.note => 'notesSubtitle',
        VaultItemType.document => 'documentsSubtitle',
      };

  List<VaultItem> _items(VaultProvider vault) => switch (type) {
        VaultItemType.password => vault.passwords,
        VaultItemType.note => vault.notes,
        VaultItemType.document => vault.documents,
      };

  IconData get _icon => switch (type) {
        VaultItemType.password => Icons.key_rounded,
        VaultItemType.note => Icons.note_alt_outlined,
        VaultItemType.document => Icons.insert_drive_file_outlined,
      };

  Color get _color => switch (type) {
        VaultItemType.password => AppColors.password,
        VaultItemType.note => AppColors.note,
        VaultItemType.document => AppColors.document,
      };

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultProvider>();
    final hasUnlimited = context.select<ShopProvider, bool>((s) => s.hasUnlimitedItems);
    final bgId = context.select<ShopProvider, String>((s) => s.activeBackgroundId);
    final items = _items(vault);
    final limit = vault.limitFor(type);
    final atLimit = !hasUnlimited && items.length >= limit;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addItem(context, atLimit),
        icon: const Icon(Icons.add_rounded),
        label: Text(AppStrings.t(context, 'addItem')),
      ),
      body: AppDecorations.meshBackground(
        context: context,
        backgroundGradient: bgId != 'bg_default' ? AppBackground.get(bgId).gradient : null,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.t(context, _titleKey), style: AppTypography.titleLarge()),
                          Text(
                            AppStrings.t(context, _subtitleKey),
                            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (atLimit)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: AppGlassCard(
                    onTap: () => MainShell.of(context)?.openShop(),
                    padding: const EdgeInsets.all(12),
                    radius: 14,
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.warning),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppStrings.t(context, 'limitReached').replaceAll('{limit}', '$limit'),
                            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: items.isEmpty
                    ? AppEmptyState(
                        icon: _icon,
                        message: AppStrings.t(context, 'listEmpty'),
                        actionLabel: AppStrings.t(context, 'listEmptyAction'),
                        onAction: () => _addItem(context, false),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final item = items[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AppGlassCard(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => VaultItemFormScreen(item: item)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(_icon, color: _color, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.title, style: AppTypography.labelBold(size: 14)),
                                        if (item.username != null)
                                          Text(item.username!, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                                        if (item.fileName != null)
                                          Text(item.fileName!, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                                  if (item.favorite) const Icon(Icons.star_rounded, color: AppColors.coin, size: 18),
                                  Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addItem(BuildContext context, bool atLimit) {
    if (atLimit) {
      MainShell.of(context)?.openShop();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VaultItemFormScreen(type: type)),
    );
  }
}

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String _filter = 'all';

  List<VaultItem> _filtered(VaultProvider vault) {
    var items = List<VaultItem>.from(vault.items)..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (vault.searchQuery.isNotEmpty) {
      final q = vault.searchQuery.toLowerCase();
      items = items.where((i) => i.title.toLowerCase().contains(q)).toList();
    }
    return switch (_filter) {
      'password' => items.where((i) => i.type == VaultItemType.password).toList(),
      'note' => items.where((i) => i.type == VaultItemType.note).toList(),
      'document' => items.where((i) => i.type == VaultItemType.document).toList(),
      'favorite' => items.where((i) => i.favorite).toList(),
      _ => items,
    };
  }

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultProvider>();
    final items = _filtered(vault);

    return AppPageScaffold(
      title: AppStrings.t(context, 'browseTitle'),
      subtitle: AppStrings.t(context, 'browseSubtitle'),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              AppFilterChip(label: AppStrings.t(context, 'filterAll'), selected: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
              AppFilterChip(label: AppStrings.t(context, 'filterPasswords'), selected: _filter == 'password', onTap: () => setState(() => _filter = 'password')),
              AppFilterChip(label: AppStrings.t(context, 'filterNotes'), selected: _filter == 'note', onTap: () => setState(() => _filter = 'note')),
              AppFilterChip(label: AppStrings.t(context, 'filterDocuments'), selected: _filter == 'document', onTap: () => setState(() => _filter = 'document')),
              AppFilterChip(label: AppStrings.t(context, 'filterFavorites'), selected: _filter == 'favorite', onTap: () => setState(() => _filter = 'favorite')),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          AppEmptyState(icon: Icons.inventory_2_outlined, message: AppStrings.t(context, 'browseEmpty'))
        else
          ...items.map((item) {
            final color = switch (item.type) {
              VaultItemType.password => AppColors.password,
              VaultItemType.note => AppColors.note,
              VaultItemType.document => AppColors.document,
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppGlassCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VaultItemFormScreen(item: item)),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                      child: Icon(
                        switch (item.type) {
                          VaultItemType.password => Icons.key_rounded,
                          VaultItemType.note => Icons.note_alt_outlined,
                          VaultItemType.document => Icons.insert_drive_file_outlined,
                        },
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(item.title, style: AppTypography.labelBold(size: 14))),
                    if (item.favorite) const Icon(Icons.star_rounded, color: AppColors.coin, size: 18),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
