class BrandModel {
  final String id;
  final String? userId;
  final String name;
  final String? websiteUrl;
  final String? industry;
  final String? tagline;
  final String? mission;
  final String? targetAudience;
  final String? toneOfVoice;
  final List<String> contentPillars;
  final List<String> bannedWords;

  BrandModel({
    required this.id,
    this.userId,
    required this.name,
    this.websiteUrl,
    this.industry,
    this.tagline,
    this.mission,
    this.targetAudience,
    this.toneOfVoice,
    this.contentPillars = const [],
    this.bannedWords = const [],
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] ?? '',
      userId: json['user_id'],
      name: json['name'] ?? '',
      websiteUrl: json['website_url'],
      industry: json['industry'],
      tagline: json['tagline'],
      mission: json['mission'],
      targetAudience: json['target_audience'],
      toneOfVoice: json['tone_of_voice'],
      contentPillars: (json['content_pillars'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      bannedWords: (json['banned_words'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
