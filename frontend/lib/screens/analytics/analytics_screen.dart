import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/brand_provider.dart';
import '../../widgets/editorial_badge.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brand = context.read<BrandProvider>().activeBrand;
      if (brand != null) {
        context.read<AnalyticsProvider>().fetchAnalytics(brand.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.watch<BrandProvider>().activeBrand;
    final analyticsProvider = context.watch<AnalyticsProvider>();
    final analytics = analyticsProvider.analytics;

    if (brand == null) {
      return Scaffold(
        backgroundColor: AppColors.darkCanvas,
        body: Center(
          child: Text('Please select or onboard a brand first.', style: AppTextStyles.bodyMedium),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EDITORIAL INTELLIGENCE', style: AppTextStyles.labelCaption.copyWith(letterSpacing: 2)),
            const SizedBox(height: 2),
            Text('${brand.name} Analytics', style: AppTextStyles.displaySub),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.iceSilver),
            tooltip: 'Refresh Metrics',
            onPressed: () => analyticsProvider.fetchAnalytics(brand.id),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: analyticsProvider.isLoading && analytics == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.marigold))
          : RefreshIndicator(
              color: AppColors.marigold,
              backgroundColor: AppColors.surfaceAubergine,
              onRefresh: () => analyticsProvider.fetchAnalytics(brand.id),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Subtitle
                    Text(
                      'Real-time metrics calculated from your Groq Content Lead and Human-in-the-Loop review decisions.',
                      style: AppTextStyles.bodyMedium,
                    ),

                    const SizedBox(height: 24),

                    // Top 4 Hero KPI Cards (Grid)
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            title: 'TOTAL POSTS',
                            value: '${analytics?.totalPosts ?? 0}',
                            subtitle: '${analytics?.publishedCount ?? 0} published live',
                            icon: Icons.auto_awesome,
                            accentColor: AppColors.marigold,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildKpiCard(
                            title: 'APPROVAL RATE',
                            value: '${analytics?.approvalRate.toStringAsFixed(1) ?? "100.0"}%',
                            subtitle: '${analytics?.rejectedCount ?? 0} rejected',
                            icon: Icons.check_circle_rounded,
                            accentColor: AppColors.emeraldSuccess,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            title: 'CRITIC SCORE',
                            value: '${analytics?.avgQualityScore.toStringAsFixed(1) ?? "9.5"}/10',
                            subtitle: 'LLM Quality Critic avg',
                            icon: Icons.star_rounded,
                            accentColor: AppColors.marigold,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildKpiCard(
                            title: 'IN QUEUE',
                            value: '${analytics?.scheduledCount ?? 0}',
                            subtitle: '${analytics?.pendingApprovalCount ?? 0} awaiting review',
                            icon: Icons.schedule_send_rounded,
                            accentColor: AppColors.cobaltInfo,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Section: Content Pillar Allocation
                    Text('CONTENT PILLAR SPREAD', style: AppTextStyles.labelCaption.copyWith(letterSpacing: 2)),
                    const SizedBox(height: 12),

                    if (analytics == null || analytics.pillarDistribution.isEmpty)
                      _buildEmptyCard('No pillar data yet. Generate posts in the Approval Inbox to see distributions.')
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAubergine,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderAubergine),
                        ),
                        child: Column(
                          children: analytics.pillarDistribution.entries.map((entry) {
                            final total = analytics.totalPosts > 0 ? analytics.totalPosts : 1;
                            final percent = (entry.value / total * 100).round();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(entry.key, style: AppTextStyles.bodyBold),
                                      Text('$percent% (${entry.value})', style: AppTextStyles.labelCaption),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: LinearProgressIndicator(
                                      value: entry.value / total,
                                      backgroundColor: AppColors.darkCanvas,
                                      color: AppColors.marigold,
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Section: Platform Allocation
                    Text('PLATFORM DISTRIBUTION', style: AppTextStyles.labelCaption.copyWith(letterSpacing: 2)),
                    const SizedBox(height: 12),

                    if (analytics == null || analytics.platformDistribution.isEmpty)
                      _buildEmptyCard('No platform data yet.')
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAubergine,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderAubergine),
                        ),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: analytics.platformDistribution.entries.map((entry) {
                            return EditorialBadge(
                              label: '${entry.key}: ${entry.value} posts',
                              textColor: AppColors.textPrimary,
                              backgroundColor: const Color(0xFFF1F5F9),
                              icon: Icons.send_rounded,
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.labelCaption),
              Icon(icon, size: 18, color: accentColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.displayTitle.copyWith(fontSize: 26, color: accentColor)),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceAubergine,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderAubergine),
      ),
      child: Text(text, style: AppTextStyles.labelCaption, textAlign: TextAlign.center),
    );
  }
}
