class KnowledgeItemModel {
  final String id;
  final String brandId;
  final String sourceType;
  final String title;
  final String contentPreview;
  final String? summary;
  final DateTime createdAt;

  KnowledgeItemModel({
    required this.id,
    required this.brandId,
    required this.sourceType,
    required this.title,
    required this.contentPreview,
    this.summary,
    required this.createdAt,
  });

  factory KnowledgeItemModel.fromJson(Map<String, dynamic> json) {
    return KnowledgeItemModel(
      id: json['id'] ?? '',
      brandId: json['brand_id'] ?? '',
      sourceType: json['source_type'] ?? 'DOCUMENT_UPLOAD',
      title: json['title'] ?? '',
      contentPreview: json['content_preview'] ?? '',
      summary: json['summary'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
