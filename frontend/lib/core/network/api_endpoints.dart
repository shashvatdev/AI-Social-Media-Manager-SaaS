class ApiEndpoints {
  // Base URL (Default local development, easily switchable to production URL)
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Auth
  static const String signup = '$baseUrl/auth/signup';
  static const String login = '$baseUrl/auth/login';
  static const String me = '$baseUrl/auth/me';

  // Brands
  static const String brands = '$baseUrl/brands';
  static String brandDetail(String id) => '$baseUrl/brands/$id';
  static String scrapeUrl(String id) => '$baseUrl/brands/$id/scrape-url';
  static String uploadDocs(String id) => '$baseUrl/brands/$id/upload-docs';
  static String brandKnowledge(String id) => '$baseUrl/brands/$id/knowledge';
  static String generateStrategy(String id) => '$baseUrl/brands/$id/strategy/generate';
  static String getStrategy(String id) => '$baseUrl/brands/$id/strategy';
  static String updateStrategy(String id) => '$baseUrl/brands/$id/strategy';
  static String brandAnalytics(String id) => '$baseUrl/brands/$id/analytics';
  static String exportReport(String id) => '$baseUrl/brands/$id/export';
  static String queryBrain(String id) => '$baseUrl/brands/$id/brain/query';

  // Posts
  static const String posts = '$baseUrl/posts';
  static const String generatePosts = '$baseUrl/posts/generate';
  static String approvePost(String id) => '$baseUrl/posts/$id/approve';
  static String rejectPost(String id) => '$baseUrl/posts/$id/reject';
  static String requestChanges(String id) => '$baseUrl/posts/$id/request-changes';
  static String editPost(String id) => '$baseUrl/posts/$id/edit';
  static String publishNow(String id) => '$baseUrl/posts/$id/publish-now';

  // Social Media Accounts
  static const String socialAccounts = '$baseUrl/social/accounts';
  static const String connectSocial = '$baseUrl/social/connect';
  static String disconnectSocial(String id) => '$baseUrl/social/accounts/$id';
  static String oauthAuthorize(String platform, String brandId) =>
      '$baseUrl/social/oauth/$platform/authorize?brand_id=$brandId';
}
