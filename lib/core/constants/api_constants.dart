class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://squa-api.blwsmartware.net/api/v1';
  static const String gameCode = 'com.dailyvaultmng.dailyvault';
  static const Duration timeout = Duration(seconds: 12);

  static const String accessTokenKey = 'dv_access_token';
  static const String refreshTokenKey = 'dv_refresh_token';
  static const String userCacheKey = 'dv_auth_user';
  static const String pendingVerifyKey = 'dv_pending_purchase_verify';
}
