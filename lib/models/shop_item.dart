import 'package:flutter/material.dart';

enum ShopItemType {
  theme,
  background,
  skin,
  feature,
  removeAds,
}

enum ShopItemCategory {
  themes,
  backgrounds,
  skins,
  features,
  premium,
}

class ShopItem {
  final String id;
  final String nameKey;
  final String descKey;
  final int price;
  final ShopItemType type;
  final ShopItemCategory category;
  final IconData icon;
  final bool oneTime;

  const ShopItem({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.price,
    required this.type,
    required this.category,
    required this.icon,
    this.oneTime = true,
  });
}

class ShopCatalog {
  ShopCatalog._();

  static const String defaultThemeId = 'theme_default';
  static const String defaultBackgroundId = 'bg_default';
  static const String defaultSkinId = 'skin_default';

  static const List<ShopItem> items = [
    ShopItem(
      id: 'remove_ads',
      nameKey: 'shopRemoveAds',
      descKey: 'shopRemoveAdsDesc',
      price: 500,
      type: ShopItemType.removeAds,
      category: ShopItemCategory.premium,
      icon: Icons.block_outlined,
    ),
    ShopItem(
      id: 'theme_ocean',
      nameKey: 'shopThemeOcean',
      descKey: 'shopThemeOceanDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.water_outlined,
    ),
    ShopItem(
      id: 'theme_midnight',
      nameKey: 'shopThemeMidnight',
      descKey: 'shopThemeMidnightDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.nightlight_round,
    ),
    ShopItem(
      id: 'theme_emerald',
      nameKey: 'shopThemeEmerald',
      descKey: 'shopThemeEmeraldDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.forest_outlined,
    ),
    ShopItem(
      id: 'theme_royal',
      nameKey: 'shopThemeRoyal',
      descKey: 'shopThemeRoyalDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.diamond_outlined,
    ),
    ShopItem(
      id: 'bg_vault',
      nameKey: 'shopBgVault',
      descKey: 'shopBgVaultDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.shield_outlined,
    ),
    ShopItem(
      id: 'bg_ocean',
      nameKey: 'shopBgOcean',
      descKey: 'shopBgOceanDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.waves_outlined,
    ),
    ShopItem(
      id: 'bg_aurora',
      nameKey: 'shopBgAurora',
      descKey: 'shopBgAuroraDesc',
      price: 200,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.auto_awesome_outlined,
    ),
    ShopItem(
      id: 'bg_galaxy',
      nameKey: 'shopBgGalaxy',
      descKey: 'shopBgGalaxyDesc',
      price: 200,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.nightlight_outlined,
    ),
    ShopItem(
      id: 'skin_neon',
      nameKey: 'shopSkinNeon',
      descKey: 'shopSkinNeonDesc',
      price: 200,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.bolt_rounded,
    ),
    ShopItem(
      id: 'skin_classic',
      nameKey: 'shopSkinClassic',
      descKey: 'shopSkinClassicDesc',
      price: 150,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.inventory_2_outlined,
    ),
    ShopItem(
      id: 'skin_glass',
      nameKey: 'shopSkinGlass',
      descKey: 'shopSkinGlassDesc',
      price: 180,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.blur_on_outlined,
    ),
    ShopItem(
      id: 'feat_unlimited_items',
      nameKey: 'shopFeatUnlimitedItems',
      descKey: 'shopFeatUnlimitedItemsDesc',
      price: 300,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.all_inclusive_rounded,
    ),
    ShopItem(
      id: 'feat_export_data',
      nameKey: 'shopFeatExport',
      descKey: 'shopFeatExportDesc',
      price: 200,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.file_download_outlined,
    ),
    ShopItem(
      id: 'feat_custom_folders',
      nameKey: 'shopFeatCustomFolders',
      descKey: 'shopFeatCustomFoldersDesc',
      price: 250,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.folder_special_outlined,
    ),
    ShopItem(
      id: 'feat_secure_sharing',
      nameKey: 'shopFeatSecureSharing',
      descKey: 'shopFeatSecureSharingDesc',
      price: 350,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.lock_person_outlined,
    ),
    ShopItem(
      id: 'feat_no_watermark',
      nameKey: 'shopFeatNoWatermark',
      descKey: 'shopFeatNoWatermarkDesc',
      price: 150,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.image_not_supported_outlined,
    ),
  ];

  static ShopItem? find(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
