class IapConstants {
  IapConstants._();

  static const String productPrefix = 'dv';

  static const String remoteConfigUrl = 'https://api2.blwsmartware.net/N206.json';

  static const Duration configTimeout = Duration(seconds: 10);

  static const List<String> coinPackIds = [
    'dv_pack_1',
    'dv_pack_2',
    'dv_pack_3',
    'dv_pack_4',
    'dv_pack_5',
    'dv_pack_6',
    'dv_pack_7',
    'dv_pack_8',
    'dv_pack_9',
    'dv_pack_10',
  ];

  static const String removeAdsProductId = 'dv_remove_ads';

  static List<String> get allProductIds => [...coinPackIds, removeAdsProductId];

  static const List<int> coinPackAmounts = [
    50, 100, 200, 350, 500, 750, 1000, 1500, 2200, 3000,
  ];

  static int coinsForProduct(String productId) {
    final index = coinPackIds.indexOf(productId);
    if (index < 0) return 0;
    return coinPackAmounts[index];
  }

  static bool isRemoveAdsProduct(String productId) => productId == removeAdsProductId;

  static const int freePasswordLimit = 10;
  static const int freeNoteLimit = 5;
  static const int freeDocumentLimit = 3;

  static const int dailyLoginReward = 10;
  static const int addPasswordReward = 3;
  static const int maxAddPasswordRewardsPerDay = 10;
  static const int addNoteReward = 2;
  static const int maxAddNoteRewardsPerDay = 15;
  static const int addDocumentReward = 5;
  static const int maxAddDocumentRewardsPerDay = 3;
  static const int shareVaultReward = 5;
  static const int maxShareRewardsPerDay = 3;
}
