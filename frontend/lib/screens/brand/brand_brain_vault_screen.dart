import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/brand_provider.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/editorial_badge.dart';

class BrandBrainVaultScreen extends StatefulWidget {
  const BrandBrainVaultScreen({super.key});

  @override
  State<BrandBrainVaultScreen> createState() => _BrandBrainVaultScreenState();
}

class _BrandBrainVaultScreenState extends State<BrandBrainVaultScreen> {
  final _urlScrapeController = TextEditingController();

  @override
  void dispose() {
    _urlScrapeController.dispose();
    super.dispose();
  }

  Future<void> _handleFilePick(String brandId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'md'],
      );

      if (result != null && result.files.single.path != null) {
        if (!mounted) return;
        final path = result.files.single.path!;
        final name = result.files.single.name;
        final provider = context.read<BrandProvider>();
        final success = await provider.uploadDocument(brandId, path, name);

        if (!mounted) return;
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Document "$name" parsed and added to Brand Brain!'),
              backgroundColor: AppColors.emeraldSuccess,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.crimsonReject),
      );
    }
  }

  Future<void> _handleScrape(String brandId) async {
    final url = _urlScrapeController.text.trim();
    final provider = context.read<BrandProvider>();
    final success = await provider.scrapeWebsite(brandId, url: url.isNotEmpty ? url : null);

    if (!mounted) return;
    if (success) {
      _urlScrapeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Website scraped & synthesized into brand memory!'),
          backgroundColor: AppColors.emeraldSuccess,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandProvider = context.watch<BrandProvider>();
    final activeBrand = brandProvider.activeBrand;

    if (activeBrand == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hub_outlined, color: AppColors.marigold, size: 48),
              const SizedBox(height: 16),
              Text('No Active Brand Selected', style: AppTextStyles.displayTitle),
              const SizedBox(height: 8),
              Text('Please onboard a brand to access the Brand Brain Vault.',
                  style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.marigold,
      backgroundColor: AppColors.surfaceAubergine,
      onRefresh: () => brandProvider.fetchKnowledge(activeBrand.id),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KNOWLEDGE REPOSITORY', style: AppTextStyles.labelCaption),
                    const SizedBox(height: 4),
                    Text('Brand Brain Vault.', style: AppTextStyles.displayTitle),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAubergine,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.borderAubergine),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_special_rounded, color: AppColors.marigold, size: 14),
                      const SizedBox(width: 6),
                      Text('${brandProvider.knowledgeItems.length} ASSETS',
                          style: AppTextStyles.badgeText.copyWith(color: AppColors.iceSilver)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Card 1: Live Website Scraper
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceAubergine,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderAubergine),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.deepAubergine,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.language_rounded, color: AppColors.marigold, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Live Website Crawler', style: AppTextStyles.headlineSans),
                            Text('Auto-extracts headings, value props & voice', style: AppTextStyles.labelCaption),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _urlScrapeController,
                    style: AppTextStyles.bodyBold,
                    decoration: InputDecoration(
                      hintText: activeBrand.websiteUrl ?? 'https://yourbrand.io',
                      prefixIcon: const Icon(Icons.link_rounded, color: AppColors.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: GlowingButton(
                      text: 'Crawl & Ingest Website',
                      isLoading: brandProvider.isLoading,
                      onPressed: () => _handleScrape(activeBrand.id),
                      icon: Icons.radar_rounded,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 20),

            // Card 2: Document Uploader (PDF / TXT)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceAubergine,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderAubergine),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.deepAubergine,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.upload_file_rounded, color: AppColors.marigold, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Upload Guidelines & Docs', style: AppTextStyles.headlineSans),
                        const SizedBox(height: 2),
                        Text('PDF, TXT, Markdown (Whitepapers, ICP decks)', style: AppTextStyles.labelCaption),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GlowingButton(
                    text: 'Upload',
                    isSecondary: true,
                    onPressed: () => _handleFilePick(activeBrand.id),
                    icon: Icons.add_rounded,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 32),

            // Section 3: Ingested Knowledge Vault
            Text('INGESTED BRAIN ASSETS', style: AppTextStyles.labelCaption),
            const SizedBox(height: 12),

            if (brandProvider.knowledgeItems.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAubergine.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderAubergine),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.auto_stories_outlined, color: AppColors.textTertiary, size: 40),
                    const SizedBox(height: 12),
                    Text('Brain Vault is Empty', style: AppTextStyles.bodyBold),
                    const SizedBox(height: 4),
                    Text('Crawl your website or upload documents above to feed your AI Content Lead real facts.',
                        style: AppTextStyles.labelCaption, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: brandProvider.knowledgeItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = brandProvider.knowledgeItems[index];
                  final isWeb = item.sourceType == 'WEBSITE_SCRAPE';

                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAubergine,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderAubergine),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isWeb ? Icons.language_rounded : Icons.description_outlined,
                              color: isWeb ? AppColors.marigold : AppColors.iceSilver,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.title,
                                style: AppTextStyles.bodyBold,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            EditorialBadge(
                              label: isWeb ? 'CRAWLER' : 'DOCUMENT',
                              backgroundColor: AppColors.deepAubergine,
                              textColor: AppColors.iceSilver,
                            ),
                          ],
                        ),
                        if (item.summary != null) ...[
                          const SizedBox(height: 10),
                          Text(item.summary!, style: AppTextStyles.labelCaption.copyWith(color: AppColors.textSecondary)),
                        ],
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.darkCanvas,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.contentPreview,
                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, color: AppColors.textTertiary),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
