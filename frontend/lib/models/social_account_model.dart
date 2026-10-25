class SocialAccountModel {
  final String id;
  final String brandId;
  final String platform;
  final String accountHandle;
  final String? accountName;
  final String? avatarUrl;
  final bool isActive;

  SocialAccountModel({
    required this.id,
    required this.brandId,
    required this.platform,
    required this.accountHandle,
    this.accountName,
    this.avatarUrl,
    required this.isActive,
  });

  factory SocialAccountModel.fromJson(Map<String, dynamic> json) {
    return SocialAccountModel(
      id: json['id'] ?? '',
      brandId: json['brand_id'] ?? '',
      platform: json['platform'] ?? 'LINKEDIN',
      accountHandle: json['account_handle'] ?? '',
      accountName: json['account_name'],
      avatarUrl: json['avatar_url'],
      isActive: json['is_active'] ?? true,
    );
  }
}
