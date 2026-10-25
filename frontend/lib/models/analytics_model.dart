class AnalyticsModel {
  final String brandId;
  final int totalPosts;
  final int publishedCount;
  final int scheduledCount;
  final int pendingApprovalCount;
  final int rejectedCount;
  final double approvalRate;
  final double avgQualityScore;
  final Map<String, int> pillarDistribution;
  final Map<String, int> platformDistribution;
  final Map<String, int> funnelDistribution;

  AnalyticsModel({
    required this.brandId,
    required this.totalPosts,
    required this.publishedCount,
    required this.scheduledCount,
    required this.pendingApprovalCount,
    required this.rejectedCount,
    required this.approvalRate,
    required this.avgQualityScore,
    required this.pillarDistribution,
    required this.platformDistribution,
    required this.funnelDistribution,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    Map<String, int> parseMap(dynamic map) {
      if (map is Map) {
        return map.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
      }
      return {};
    }

    return AnalyticsModel(
      brandId: json['brand_id'] ?? '',
      totalPosts: (json['total_posts'] as num?)?.toInt() ?? 0,
      publishedCount: (json['published_count'] as num?)?.toInt() ?? 0,
      scheduledCount: (json['scheduled_count'] as num?)?.toInt() ?? 0,
      pendingApprovalCount: (json['pending_approval_count'] as num?)?.toInt() ?? 0,
      rejectedCount: (json['rejected_count'] as num?)?.toInt() ?? 0,
      approvalRate: (json['approval_rate'] as num?)?.toDouble() ?? 100.0,
      avgQualityScore: (json['avg_quality_score'] as num?)?.toDouble() ?? 9.5,
      pillarDistribution: parseMap(json['pillar_distribution']),
      platformDistribution: parseMap(json['platform_distribution']),
      funnelDistribution: parseMap(json['funnel_distribution']),
    );
  }
}
