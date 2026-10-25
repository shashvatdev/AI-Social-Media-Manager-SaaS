import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/brand_provider.dart';
import '../../providers/strategy_provider.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/editorial_badge.dart';

class StrategyBlueprintScreen extends StatefulWidget {
  const StrategyBlueprintScreen({super.key});

  @override
  State<StrategyBlueprintScreen> createState() => _StrategyBlueprintScreenState();
}

class _StrategyBlueprintScreenState extends State<StrategyBlueprintScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brand = context.read<BrandProvider>().activeBrand;
      if (brand != null) {
        context.read<StrategyProvider>().fetchStrategy(brand.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.watch<BrandProvider>().activeBrand;
    final strategyProvider = context.watch<StrategyProvider>();
    final strategy = strategyProvider.strategy;

    if (brand == null) {
      return Center(
        child: Text('Please select or create an active brand.', style: AppTextStyles.bodyBold),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      body: RefreshIndicator(
        color: AppColors.marigold,
        backgroundColor: AppColors.surfaceAubergine,
        onRefresh: () => strategyProvider.fetchStrategy(brand.id),
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
                      Text('AI CONTENT LEAD ENGINE', style: AppTextStyles.labelCaption),
                      const SizedBox(height: 4),
                      Text('Strategy Blueprint.', style: AppTextStyles.displayTitle),
                    ],
                  ),
                  if (strategy != null)
                    EditorialBadge(
                      label: strategy.isApproved ? 'APPROVED STRATEGY' : 'PENDING REVIEW',
                      backgroundColor: strategy.isApproved ? const Color(0x2200E599) : AppColors.marigoldGlow,
                      textColor: strategy.isApproved ? AppColors.emeraldSuccess : AppColors.marigold,
                      icon: strategy.isApproved ? Icons.verified_rounded : Icons.pending_actions_rounded,
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Empty State or Blueprint Content
              if (strategyProvider.isLoading && strategy == null) ...[
                const SizedBox(height: 100),
                const Center(child: CircularProgressIndicator(color: AppColors.marigold)),
              ] else if (strategy == null) ...[
                // Unformulated Blueprint Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAubergine,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderAubergine),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.deepAubergine,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderAubergine),
                        ),
                        child: const Icon(Icons.psychology_alt_rounded, color: AppColors.marigold, size: 38),
                      ),
                      const SizedBox(height: 20),
                      Text('No Active Strategy Blueprint', style: AppTextStyles.displaySub),
                      const SizedBox(height: 10),
                      Text(
                        'Your AI Content Lead will analyze your scraped website & ingested docs to formulate a high-converting 30-day strategy.',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 26),
                      GlowingButton(
                        text: 'Formulate 30-Day Strategy Blueprint',
                        isLoading: strategyProvider.isLoading,
                        onPressed: () => strategyProvider.generateStrategy(brand.id),
                        icon: Icons.auto_awesome,
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1),
              ] else ...[
                // Formulated Blueprint Cards

                // 1. Positioning Statement Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
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
                          const Icon(Icons.gps_fixed_rounded, color: AppColors.marigold, size: 18),
                          const SizedBox(width: 8),
                          Text('MARKET POSITIONING & UNFAIR ADVANTAGE', style: AppTextStyles.labelCaption),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '"${strategy.positioningStatement}"',
                        style: AppTextStyles.displaySub.copyWith(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          height: 1.45,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1),

                const SizedBox(height: 20),

                // 2. Content Pillars Breakdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAubergine,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderAubergine),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('STRATEGIC CONTENT PILLARS (DISTRIBUTION %)', style: AppTextStyles.labelCaption),
                      const SizedBox(height: 16),
                      ...strategy.contentPillars.map((pillar) {
                        final name = pillar['name'] ?? 'Pillar';
                        final pct = (pillar['target_percentage'] ?? 25).toDouble();
                        final theme = pillar['focus_theme'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(name, style: AppTextStyles.bodyBold),
                                  Text('${pct.toInt()}%',
                                      style: AppTextStyles.bodyBold.copyWith(color: AppColors.marigold)),
                                ],
                              ),
                              if (theme.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(theme, style: AppTextStyles.labelCaption),
                              ],
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: pct / 100.0,
                                  backgroundColor: AppColors.darkCanvas,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.marigold),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 20),

                // 3. Target Personas
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAubergine,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderAubergine),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TARGET AUDIENCE ICP PERSONAS', style: AppTextStyles.labelCaption),
                      const SizedBox(height: 16),
                      ...strategy.targetPersonas.map((persona) {
                        final name = persona['name'] ?? 'Ideal Customer';
                        final title = persona['job_title'] ?? '';
                        final painPoints = (persona['pain_points'] as List<dynamic>?) ?? [];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.darkCanvas,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderAubergine),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person_pin_rounded, color: AppColors.marigold, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(name, style: AppTextStyles.headlineSans),
                                  ),
                                ],
                              ),
                              if (title.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('Job Titles: $title',
                                    style: AppTextStyles.labelCaption.copyWith(color: AppColors.iceSilver)),
                              ],
                              if (painPoints.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text('Top Pain Points:', style: AppTextStyles.labelCaption),
                                const SizedBox(height: 4),
                                ...painPoints.map((p) => Text('• $p',
                                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, height: 1.4))),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 28),

                // Approve Strategy Button if not approved
                if (!strategy.isApproved)
                  SizedBox(
                    width: double.infinity,
                    child: GlowingButton(
                      text: 'Approve Strategy Blueprint',
                      onPressed: () => strategyProvider.approveStrategy(brand.id),
                      icon: Icons.check_circle_rounded,
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
