import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/brand_provider.dart';
import '../../widgets/glowing_button.dart';

class BrandSetupScreen extends StatefulWidget {
  const BrandSetupScreen({super.key});

  @override
  State<BrandSetupScreen> createState() => _BrandSetupScreenState();
}

class _BrandSetupScreenState extends State<BrandSetupScreen> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _industryController = TextEditingController();
  final _toneController = TextEditingController();
  final _audienceController = TextEditingController();
  final _pillarsController = TextEditingController();
  final _bannedWordsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _industryController.dispose();
    _toneController.dispose();
    _audienceController.dispose();
    _pillarsController.dispose();
    _bannedWordsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brand name is required')),
      );
      return;
    }

    final pillars = _pillarsController.text
        .split(',')
        .map((p) => p.trim())
        .filter((p) => p.isNotEmpty)
        .toList();

    final banned = _bannedWordsController.text
        .split(',')
        .map((b) => b.trim())
        .filter((b) => b.isNotEmpty)
        .toList();

    final provider = context.read<BrandProvider>();
    final brand = await provider.createBrand(
      name: name,
      websiteUrl: _urlController.text.trim().isNotEmpty ? _urlController.text.trim() : null,
      industry: _industryController.text.trim().isNotEmpty ? _industryController.text.trim() : null,
      toneOfVoice: _toneController.text.trim().isNotEmpty ? _toneController.text.trim() : null,
      targetAudience: _audienceController.text.trim().isNotEmpty ? _audienceController.text.trim() : null,
      contentPillars: pillars,
      bannedWords: banned,
    );

    if (!mounted) return;

    if (brand != null) {
      // Auto-trigger website scraper if URL provided
      if (brand.websiteUrl != null && brand.websiteUrl!.isNotEmpty) {
        provider.scrapeWebsite(brand.id);
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Brand "${brand.name}" onboarded successfully!'),
          backgroundColor: AppColors.emeraldSuccess,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrandProvider>();

    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      appBar: AppBar(
        title: Text('Onboard Brand', style: AppTextStyles.displaySub),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FOUNDER & BRAND DNA', style: AppTextStyles.labelCaption),
            const SizedBox(height: 8),
            Text('Define your business parameters. The AI Content Lead will follow these rules.',
                style: AppTextStyles.bodyMedium),

            const SizedBox(height: 28),

            // Brand Name
            Text('BRAND NAME *', style: AppTextStyles.labelCaption),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: AppTextStyles.bodyBold,
              decoration: const InputDecoration(hintText: 'e.g. Acme AI, FinPulse'),
            ),

            const SizedBox(height: 20),

            // Website URL
            Text('WEBSITE URL (FOR AUTO-SCRAPING)', style: AppTextStyles.labelCaption),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              style: AppTextStyles.bodyBold,
              decoration: const InputDecoration(
                hintText: 'https://yourbrand.com',
                prefixIcon: Icon(Icons.link_rounded, color: AppColors.textTertiary),
              ),
            ),

            const SizedBox(height: 20),

            // Industry
            Text('INDUSTRY / SECTOR', style: AppTextStyles.labelCaption),
            const SizedBox(height: 8),
            TextField(
              controller: _industryController,
              style: AppTextStyles.bodyBold,
              decoration: const InputDecoration(hintText: 'e.g. B2B SaaS, HealthTech, Clean Energy'),
            ),

            const SizedBox(height: 20),

            // Voice Presets
            Text('QUICK FOUNDER PERSONA PRESETS', style: AppTextStyles.labelCaption),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPresetChip(
                    label: '⚡ Silicon Valley Founder',
                    tone: 'Authoritative, vision-led, data-backed, high conviction, zero fluff',
                    pillars: 'Market Deconstructions, Product Velocity, Scaling Lessons',
                    banned: 'cheap, game-changer, synergy, revolutionary',
                  ),
                  const SizedBox(width: 8),
                  _buildPresetChip(
                    label: '🛠 Tech Architect',
                    tone: 'Analytical, engineering-first, systems architecture rigor, trade-off analysis',
                    pillars: 'Architecture Breakdowns, Latency & Scale, Code Patterns',
                    banned: 'magic, easy, turnkey, foolproof',
                  ),
                  const SizedBox(width: 8),
                  _buildPresetChip(
                    label: '👑 Luxury Editorial',
                    tone: 'Bespoke, refined, minimal, evocative, quiet luxury, understated confidence',
                    pillars: 'Craftsmanship, Design Philosophy, Material Excellence',
                    banned: 'bargain, discount, buy now, promo',
                  ),
                  const SizedBox(width: 8),
                  _buildPresetChip(
                    label: '📈 Growth & CRO Lead',
                    tone: 'High-hook, direct, tactical, frameworks, conversion-driven, checklist format',
                    pillars: 'A/B Test Teardowns, Growth Experiments, Funnel Analytics',
                    banned: 'hope, maybe, eventually',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tone of voice
            Text('BRAND TONE & VOICE SPECTRUM', style: AppTextStyles.labelCaption),
            const SizedBox(height: 8),
            TextField(
              controller: _toneController,
              style: AppTextStyles.bodyBold,
              decoration: const InputDecoration(hintText: 'e.g. Authoritative, direct, data-backed, zero fluff'),
            ),

            const SizedBox(height: 20),

            // Target Audience
            Text('TARGET AUDIENCE / ICP', style: AppTextStyles.labelCaption),
            const SizedBox(height: 8),
            TextField(
              controller: _audienceController,
              maxLines: 2,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. CTOs, VP of Engineering, Series A Founders'),
            ),

            const SizedBox(height: 20),

            // Content Pillars
            Text('CONTENT PILLARS (COMMA SEPARATED)', style: AppTextStyles.labelCaption),
            const SizedBox(height: 8),
            TextField(
              controller: _pillarsController,
              style: AppTextStyles.bodyBold,
              decoration: const InputDecoration(hintText: 'e.g. Tech Deconstructions, Cost Tips, Culture'),
            ),

            const SizedBox(height: 20),

            // Banned Words
            Text('BANNED WORDS / CLICHÉS (COMMA SEPARATED)', style: AppTextStyles.labelCaption),
            const SizedBox(height: 8),
            TextField(
              controller: _bannedWordsController,
              style: AppTextStyles.bodyBold,
              decoration: const InputDecoration(hintText: 'e.g. cheap, game-changer, revolutionary'),
            ),

            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              child: GlowingButton(
                text: 'Save & Ingest Brand Brain',
                isLoading: provider.isLoading,
                onPressed: _handleSave,
                icon: Icons.check_circle_rounded,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required String tone,
    required String pillars,
    required String banned,
  }) {
    return ActionChip(
      label: Text(label, style: AppTextStyles.badgeText.copyWith(color: AppColors.iceSilver)),
      backgroundColor: AppColors.surfaceAubergine,
      side: const BorderSide(color: AppColors.borderAubergine),
      onPressed: () {
        setState(() {
          _toneController.text = tone;
          _pillarsController.text = pillars;
          _bannedWordsController.text = banned;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Applied "$label" persona settings!'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.deepAubergine,
          ),
        );
      },
    );
  }
}

extension ListFilterExtension<T> on Iterable<T> {
  Iterable<T> filter(bool Function(T element) test) => where(test);
}
