class StrategyModel {
  final String id;
  final String brandId;
  final String positioningStatement;
  final List<dynamic> targetPersonas;
  final Map<String, dynamic> toneGuidelines;
  final List<dynamic> contentPillars;
  final Map<String, dynamic> funnelMix;
  final Map<String, dynamic> platformPlaybooks;
  final Map<String, dynamic> weeklyCadence;
  final bool isApproved;
  final String version;

  StrategyModel({
    required this.id,
    required this.brandId,
    required this.positioningStatement,
    this.targetPersonas = const [],
    this.toneGuidelines = const {},
    this.contentPillars = const [],
    this.funnelMix = const {},
    this.platformPlaybooks = const {},
    this.weeklyCadence = const {},
    required this.isApproved,
    required this.version,
  });

  factory StrategyModel.fromJson(Map<String, dynamic> json) {
    return StrategyModel(
      id: json['id'] ?? '',
      brandId: json['brand_id'] ?? '',
      positioningStatement: json['positioning_statement'] ?? '',
      targetPersonas: json['target_personas'] ?? [],
      toneGuidelines: json['tone_guidelines'] ?? {},
      contentPillars: json['content_pillars'] ?? [],
      funnelMix: json['funnel_mix'] ?? {},
      platformPlaybooks: json['platform_playbooks'] ?? {},
      weeklyCadence: json['weekly_cadence'] ?? {},
      isApproved: json['is_approved'] ?? false,
      version: json['version'] ?? '1.0',
    );
  }
}
