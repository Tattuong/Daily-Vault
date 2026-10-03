import 'package:daily_vault/core/constants/ad_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses real AdMob app and banner units, not Google sample IDs', () {
    expect(AdConstants.androidAppId, 'ca-app-pub-1023100218618748~9626555029');
    expect(AdConstants.androidBannerId, 'ca-app-pub-1023100218618748/9955520215');
    expect(AdConstants.androidAppId.contains('3940256099942544'), isFalse);
    expect(AdConstants.androidBannerId.contains('3940256099942544'), isFalse);
    expect(AdConstants.androidAppId, contains('~'));
    expect(AdConstants.androidBannerId, contains('/'));
    expect(AdConstants.isConfigured, isTrue);
    expect(AdConstants.bannerHeight, 50);
  });
}
