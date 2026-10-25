import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/brand_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/editorial_badge.dart';
import '../../widgets/flux_image_card.dart';
import '../../models/post_model.dart';

class PostApprovalInboxScreen extends StatefulWidget {
  const PostApprovalInboxScreen({super.key});

  @override
  State<PostApprovalInboxScreen> createState() => _PostApprovalInboxScreenState();
}

class _PostApprovalInboxScreenState extends State<PostApprovalInboxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brand = context.read<BrandProvider>().activeBrand;
      if (brand != null) {
        context.read<PostProvider>().fetchPosts(brand.id, status: 'PENDING_APPROVAL');
      }
    });
  }

  void _showGenerateModal(BuildContext context, String brandId) {
    String selectedPlatform = 'LINKEDIN';
    final topicController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceAubergine,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI CONTENT LEAD DISPATCH', style: AppTextStyles.labelCaption),
                  const SizedBox(height: 6),
                  Text('Generate Strategic Post', style: AppTextStyles.displaySub),
                  const SizedBox(height: 18),

                  // Platform Chips
                  Row(
                    children: [
                      ChoiceChip(
                        label: Text('LINKEDIN',
                            style: AppTextStyles.badgeText.copyWith(
                                color: selectedPlatform == 'LINKEDIN' ? AppColors.textOnMarigold : AppColors.iceSilver)),
                        selected: selectedPlatform == 'LINKEDIN',
                        selectedColor: AppColors.marigold,
                        backgroundColor: AppColors.deepAubergine,
                        onSelected: (_) => setModalState(() => selectedPlatform = 'LINKEDIN'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('INSTAGRAM',
                            style: AppTextStyles.badgeText.copyWith(
                                color: selectedPlatform == 'INSTAGRAM' ? AppColors.textOnMarigold : AppColors.iceSilver)),
                        selected: selectedPlatform == 'INSTAGRAM',
                        selectedColor: AppColors.marigold,
                        backgroundColor: AppColors.deepAubergine,
                        onSelected: (_) => setModalState(() => selectedPlatform = 'INSTAGRAM'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('TWITTER',
                            style: AppTextStyles.badgeText.copyWith(
                                color: selectedPlatform == 'TWITTER' ? AppColors.textOnMarigold : AppColors.iceSilver)),
                        selected: selectedPlatform == 'TWITTER',
                        selectedColor: AppColors.marigold,
                        backgroundColor: AppColors.deepAubergine,
                        onSelected: (_) => setModalState(() => selectedPlatform = 'TWITTER'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text('TOPIC / ANGLE (OPTIONAL)', style: AppTextStyles.labelCaption),
                  const SizedBox(height: 6),
                  TextField(
                    controller: topicController,
                    style: AppTextStyles.bodyBold,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Why lines of code is a dead metric, or leave blank for pillars',
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: GlowingButton(
                      text: 'Generate Post & Flux Visual',
                      onPressed: () async {
                        final topic = topicController.text.trim();
                        Navigator.of(ctx).pop();
                        final postProvider = context.read<PostProvider>();
                        final success = await postProvider.generatePosts(
                          brandId: brandId,
                          platform: selectedPlatform,
                          topic: topic.isNotEmpty ? topic : null,
                          count: 1,
                        );

                        if (!context.mounted) return;
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Strategic post & Flux creative generated in PENDING_APPROVAL!'),
                              backgroundColor: AppColors.emeraldSuccess,
                            ),
                          );
                        }
                      },
                      icon: Icons.auto_awesome,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRewriteDialog(BuildContext context, PostModel post) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceAubergine,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderAubergine),
          ),
          title: Text('Request AI Rewrite', style: AppTextStyles.displaySub),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell the AI Content Lead how to improve this post (e.g. "make the hook more aggressive", "shorten it").',
                style: AppTextStyles.labelCaption,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: feedbackController,
                maxLines: 3,
                style: AppTextStyles.bodyBold,
                decoration: const InputDecoration(hintText: 'Enter your revision notes...'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: AppTextStyles.bodyBold.copyWith(color: AppColors.textTertiary)),
            ),
            GlowingButton(
              text: 'Rewrite with AI',
              onPressed: () async {
                final feedback = feedbackController.text.trim();
                if (feedback.isEmpty) return;

                Navigator.of(ctx).pop();
                final success = await context.read<PostProvider>().requestChanges(post.id, feedback);

                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AI refined the post based on your feedback!'),
                      backgroundColor: AppColors.emeraldSuccess,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.watch<BrandProvider>().activeBrand;
    final postProvider = context.watch<PostProvider>();

    if (brand == null) {
      return Center(child: Text('Select or create a brand first', style: AppTextStyles.bodyBold));
    }

    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.marigold,
        foregroundColor: AppColors.textOnMarigold,
        elevation: 6,
        icon: const Icon(Icons.auto_awesome),
        label: Text('Generate Post', style: AppTextStyles.buttonPrimary),
        onPressed: () => _showGenerateModal(context, brand.id),
      ),
      body: RefreshIndicator(
        color: AppColors.marigold,
        backgroundColor: AppColors.surfaceAubergine,
        onRefresh: () => postProvider.fetchPosts(brand.id, status: postProvider.currentFilter),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('HUMAN-IN-THE-LOOP COMMAND CENTER', style: AppTextStyles.labelCaption),
              const SizedBox(height: 4),
              Text('Approval Inbox.', style: AppTextStyles.displayTitle),

              const SizedBox(height: 18),

              // Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('WAITING REVIEW', 'PENDING_APPROVAL', postProvider, brand.id),
                    const SizedBox(width: 8),
                    _buildFilterChip('APPROVED QUEUE', 'APPROVED', postProvider, brand.id),
                    const SizedBox(width: 8),
                    _buildFilterChip('PUBLISHED', 'PUBLISHED', postProvider, brand.id),
                    const SizedBox(width: 8),
                    _buildFilterChip('ALL POSTS', 'ALL', postProvider, brand.id),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (postProvider.isGenerating) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAubergine,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.marigold.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const CircularProgressIndicator(color: AppColors.marigold, strokeWidth: 2.5),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Synthesizing Strategy & Rendering Flux Visual...', style: AppTextStyles.headlineSans),
                            const SizedBox(height: 2),
                            Text('Writing platform-native copy + 1024x1024 creative', style: AppTextStyles.labelCaption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().shimmer(duration: 1500.ms),
                const SizedBox(height: 20),
              ],

              if (postProvider.isLoading && postProvider.posts.isEmpty) ...[
                const SizedBox(height: 80),
                const Center(child: CircularProgressIndicator(color: AppColors.marigold)),
              ] else if (postProvider.posts.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAubergine,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderAubergine),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.mark_email_read_outlined, color: AppColors.textTertiary, size: 44),
                      const SizedBox(height: 14),
                      Text('Inbox is Clear', style: AppTextStyles.bodyBold),
                      const SizedBox(height: 6),
                      Text(
                        'No posts in this category. Click "Generate Post" below to have your AI Content Lead create a strategic post.',
                        style: AppTextStyles.labelCaption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: postProvider.posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 22),
                  itemBuilder: (context, index) {
                    final post = postProvider.posts[index];
                    return _buildPostCard(context, post, brand.id);
                  },
                ),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String statusKey, PostProvider provider, String brandId) {
    final isSelected = provider.currentFilter == statusKey;
    return ChoiceChip(
      label: Text(label, style: AppTextStyles.badgeText.copyWith(color: isSelected ? AppColors.textOnMarigold : AppColors.iceSilver)),
      selected: isSelected,
      selectedColor: AppColors.marigold,
      backgroundColor: AppColors.surfaceAubergine,
      onSelected: (_) => provider.setFilter(statusKey, brandId),
    );
  }

  Widget _buildPostCard(BuildContext context, PostModel post, String brandId) {
    final isPending = post.status == 'PENDING_APPROVAL';
    final isApproved = post.status == 'APPROVED';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAubergine,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isPending ? AppColors.borderHighlight : AppColors.borderAubergine,
          width: isPending ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with badges
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 18, top: 18),
            child: Row(
              children: [
                EditorialBadge.status(post.status),
                const SizedBox(width: 8),
                EditorialBadge(
                  label: post.platform,
                  backgroundColor: AppColors.deepAubergine,
                  textColor: AppColors.iceSilver,
                ),
                const Spacer(),
                if (post.qualityScore != null)
                  EditorialBadge.qualityScore(post.qualityScore!),
              ],
            ),
          ),

          // Strategy Tags
          if (post.pillar != null || post.funnelStage != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                children: [
                  if (post.funnelStage != null) ...[
                    EditorialBadge.funnel(post.funnelStage!),
                    const SizedBox(width: 6),
                  ],
                  if (post.pillar != null)
                    Expanded(
                      child: Text(
                        'Pillar: ${post.pillar!}',
                        style: AppTextStyles.labelCaption.copyWith(color: AppColors.iceSilver),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],

          const Divider(color: AppColors.borderAubergine, height: 1),

          // Post Body Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: SelectableText(
              post.content,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.6),
            ),
          ),

          // Hashtags
          if (post.hashtags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 18, bottom: 14),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: post.hashtags
                    .map((tag) => Text(tag, style: AppTextStyles.badgeText.copyWith(color: AppColors.marigold)))
                    .toList(),
              ),
            ),

          // Flux Image Creative
          if (post.mediaUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: FluxImageCard(
                imageUrl: post.mediaUrls.first,
                prompt: post.suggestedMediaPrompt,
              ),
            ),

          // Critic Note
          if (post.criticNotes != null) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.darkCanvas,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderAubergine),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.rate_review_outlined, color: AppColors.marigold, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI Critic: ${post.criticNotes!}',
                      style: AppTextStyles.labelCaption.copyWith(color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Divider(color: AppColors.borderAubergine, height: 1),

          // Action Buttons Bar
          Padding(
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                if (isPending) ...[
                  // Reject Button
                  TextButton.icon(
                    onPressed: () => context.read<PostProvider>().rejectPost(post.id),
                    icon: const Icon(Icons.cancel_outlined, color: AppColors.crimsonReject, size: 16),
                    label: Text('Reject', style: AppTextStyles.bodyBold.copyWith(color: AppColors.crimsonReject, fontSize: 13)),
                  ),
                  // Rewrite Button
                  TextButton.icon(
                    onPressed: () => _showRewriteDialog(context, post),
                    icon: const Icon(Icons.edit_note_rounded, color: AppColors.iceSilver, size: 18),
                    label: Text('AI Rewrite', style: AppTextStyles.bodyBold.copyWith(color: AppColors.iceSilver, fontSize: 13)),
                  ),
                  // Approve & Schedule
                  GlowingButton(
                    text: 'Approve',
                    onPressed: () => context.read<PostProvider>().approvePost(post.id),
                    icon: Icons.check_rounded,
                  ),
                ],
                if (isApproved) ...[
                  // Publish Now
                  GlowingButton(
                    text: 'Publish Live Now',
                    onPressed: () => context.read<PostProvider>().publishNow(post.id),
                    icon: Icons.rocket_launch_rounded,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
