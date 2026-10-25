class PostModel {
  final String id;
  final String brandId;
  final String? socialAccountId;
  final String platform;
  final String content;
  final List<String> hashtags;
  final List<String> mediaUrls;
  final String? suggestedMediaPrompt;
  final String? pillar;
  final String? funnelStage;
  final String? hookAngle;
  final String? qualityScore;
  final String? criticNotes;
  final String status;
  final String? aiReasoning;
  final String? userFeedback;
  final String? rejectionReason;
  final DateTime? scheduledFor;
  final DateTime? publishedAt;
  final String? platformPostId;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.brandId,
    this.socialAccountId,
    required this.platform,
    required this.content,
    this.hashtags = const [],
    this.mediaUrls = const [],
    this.suggestedMediaPrompt,
    this.pillar,
    this.funnelStage,
    this.hookAngle,
    this.qualityScore,
    this.criticNotes,
    required this.status,
    this.aiReasoning,
    this.userFeedback,
    this.rejectionReason,
    this.scheduledFor,
    this.publishedAt,
    this.platformPostId,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      brandId: json['brand_id'] ?? '',
      socialAccountId: json['social_account_id'],
      platform: json['platform'] ?? 'LINKEDIN',
      content: json['content'] ?? '',
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      mediaUrls: (json['media_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      suggestedMediaPrompt: json['suggested_media_prompt'],
      pillar: json['pillar'],
      funnelStage: json['funnel_stage'],
      hookAngle: json['hook_angle'],
      qualityScore: json['quality_score'],
      criticNotes: json['critic_notes'],
      status: json['status'] ?? 'PENDING_APPROVAL',
      aiReasoning: json['ai_reasoning'],
      userFeedback: json['user_feedback'],
      rejectionReason: json['rejection_reason'],
      scheduledFor: json['scheduled_for'] != null
          ? DateTime.tryParse(json['scheduled_for'])
          : null,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'])
          : null,
      platformPostId: json['platform_post_id'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
