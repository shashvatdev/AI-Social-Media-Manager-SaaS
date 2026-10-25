import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/brand_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/editorial_badge.dart';
import '../../widgets/flux_image_card.dart';
import '../../widgets/social_post_preview_modal.dart';
import '../../models/post_model.dart';

class PostApprovalInboxScreen extends StatefulWidget {
  const PostApprovalInboxScreen({super.key});

  @override
  State<PostApprovalInboxScreen> createState() => _PostApprovalInboxScreenState();
}

class _PostApprovalInboxScreenState extends State<PostApprovalInboxScreen> {
  bool _isCalendarView = false;
  DateTime _selectedCalendarDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

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
    int selectedCount = 1;
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
                                color: selectedPlatform == 'LINKEDIN' ? AppColors.textOnMarigold : AppColors.textPrimary)),
                        selected: selectedPlatform == 'LINKEDIN',
                        selectedColor: AppColors.marigold,
                        backgroundColor: AppColors.darkCanvas,
                        side: const BorderSide(color: AppColors.borderAubergine),
                        onSelected: (_) => setModalState(() => selectedPlatform = 'LINKEDIN'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('INSTAGRAM',
                            style: AppTextStyles.badgeText.copyWith(
                                color: selectedPlatform == 'INSTAGRAM' ? AppColors.textOnMarigold : AppColors.textPrimary)),
                        selected: selectedPlatform == 'INSTAGRAM',
                        selectedColor: AppColors.marigold,
                        backgroundColor: AppColors.darkCanvas,
                        side: const BorderSide(color: AppColors.borderAubergine),
                        onSelected: (_) => setModalState(() => selectedPlatform = 'INSTAGRAM'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('TWITTER',
                            style: AppTextStyles.badgeText.copyWith(
                                color: selectedPlatform == 'TWITTER' ? AppColors.textOnMarigold : AppColors.textPrimary)),
                        selected: selectedPlatform == 'TWITTER',
                        selectedColor: AppColors.marigold,
                        backgroundColor: AppColors.darkCanvas,
                        side: const BorderSide(color: AppColors.borderAubergine),
                        onSelected: (_) => setModalState(() => selectedPlatform = 'TWITTER'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Batch Volume Selector
                  Text('BATCH VOLUME', style: AppTextStyles.labelCaption),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: Text('1 Post', style: AppTextStyles.badgeText.copyWith(color: selectedCount == 1 ? AppColors.textOnMarigold : AppColors.textPrimary)),
                          selected: selectedCount == 1,
                          selectedColor: AppColors.marigold,
                          backgroundColor: AppColors.darkCanvas,
                          side: const BorderSide(color: AppColors.borderAubergine),
                          onSelected: (_) => setModalState(() => selectedCount = 1),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('3-Post Sprint', style: AppTextStyles.badgeText.copyWith(color: selectedCount == 3 ? AppColors.textOnMarigold : AppColors.textPrimary)),
                          selected: selectedCount == 3,
                          selectedColor: AppColors.marigold,
                          backgroundColor: AppColors.darkCanvas,
                          side: const BorderSide(color: AppColors.borderAubergine),
                          onSelected: (_) => setModalState(() => selectedCount = 3),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('5-Post Week Cadence', style: AppTextStyles.badgeText.copyWith(color: selectedCount == 5 ? AppColors.textOnMarigold : AppColors.textPrimary)),
                          selected: selectedCount == 5,
                          selectedColor: AppColors.marigold,
                          backgroundColor: AppColors.darkCanvas,
                          side: const BorderSide(color: AppColors.borderAubergine),
                          onSelected: (_) => setModalState(() => selectedCount = 5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

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
                      text: selectedCount == 1 ? 'Generate Post & Flux Visual' : 'Synthesize Batch ($selectedCount Posts)',
                      onPressed: () async {
                        final topic = topicController.text.trim();
                        Navigator.of(ctx).pop();
                        final postProvider = context.read<PostProvider>();
                        final success = await postProvider.generatePosts(
                          brandId: brandId,
                          platform: selectedPlatform,
                          topic: topic.isNotEmpty ? topic : null,
                          count: selectedCount,
                        );

                        if (!context.mounted) return;
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$selectedCount strategic post(s) & Flux creative(s) generated in PENDING_APPROVAL!'),
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

  void _showCriticTeardownModal(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceAubergine,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('AI QUALITY CRITIC TEARDOWN', style: AppTextStyles.labelCaption),
                  if (post.qualityScore != null)
                    EditorialBadge.qualityScore(post.qualityScore!),
                ],
              ),
              const SizedBox(height: 6),
              Text('Executive Evaluation', style: AppTextStyles.displaySub),
              const SizedBox(height: 18),

              // Breakdown rows
              _buildCriticScoreRow('Hook Scroll-Stopping Power', '9.8 / 10', AppColors.marigold),
              const SizedBox(height: 8),
              _buildCriticScoreRow('ICP Audience Resonance', '9.6 / 10', AppColors.emeraldSuccess),
              const SizedBox(height: 8),
              _buildCriticScoreRow('Brand Tone & No-Fluff Compliance', '9.9 / 10', AppColors.iceSilver),

              const SizedBox(height: 18),

              // Critic observations
              if (post.criticNotes != null) ...[
                Text('CRITIQUE OBSERVATIONS', style: AppTextStyles.labelCaption),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkCanvas,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderAubergine),
                  ),
                  child: Text(
                    post.criticNotes!,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.45),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Strategic Angle
              if (post.hookAngle != null) ...[
                Text('PSYCHOLOGICAL HOOK ANGLE', style: AppTextStyles.labelCaption),
                const SizedBox(height: 6),
                Text(post.hookAngle!, style: AppTextStyles.bodyBold.copyWith(color: AppColors.marigold)),
                const SizedBox(height: 20),
              ],

              SizedBox(
                width: double.infinity,
                child: GlowingButton(
                  text: 'Close Teardown',
                  isSecondary: true,
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCriticScoreRow(String label, String score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkCanvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderAubergine),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(fontSize: 13)),
          Text(score, style: AppTextStyles.bodyBold.copyWith(color: color, fontSize: 13)),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, PostModel post) {
    final contentController = TextEditingController(text: post.content);
    final hashtagsController = TextEditingController(text: post.hashtags.join(', '));

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceAubergine,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderAubergine),
          ),
          title: Text('Edit Post Content', style: AppTextStyles.displaySub),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('POST COPY', style: AppTextStyles.labelCaption),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  style: AppTextStyles.bodyBold,
                  decoration: const InputDecoration(hintText: 'Enter updated post copy...'),
                ),
                const SizedBox(height: 16),
                Text('HASHTAGS (COMMA SEPARATED)', style: AppTextStyles.labelCaption),
                const SizedBox(height: 8),
                TextField(
                  controller: hashtagsController,
                  style: AppTextStyles.bodyBold,
                  decoration: const InputDecoration(hintText: '#AI, #SaaS, #Tech'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: AppTextStyles.bodyMedium),
            ),
            GlowingButton(
              text: 'Save Changes',
              onPressed: () async {
                final updatedContent = contentController.text.trim();
                final rawTags = hashtagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
                Navigator.of(ctx).pop();

                final success = await context.read<PostProvider>().editPost(
                  post.id,
                  content: updatedContent,
                  hashtags: rawTags,
                );

                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post copy updated successfully!'),
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

  void _showScheduleDialog(BuildContext context, PostModel post) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 2)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.marigold,
              onPrimary: AppColors.textOnMarigold,
              surface: AppColors.surfaceAubergine,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 2))),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.marigold,
              onPrimary: AppColors.textOnMarigold,
              surface: AppColors.surfaceAubergine,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null || !context.mounted) return;

    final scheduleDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final success = await context.read<PostProvider>().approvePost(post.id, scheduledFor: scheduleDateTime);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post queued for autonomous publishing at ${DateFormat('MMM d, h:mm a').format(scheduleDateTime)}!'),
          backgroundColor: AppColors.emeraldSuccess,
        ),
      );
    }
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
              // Header Row with View Switcher
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HUMAN-IN-THE-LOOP COMMAND CENTER', style: AppTextStyles.labelCaption),
                      const SizedBox(height: 4),
                      Text(
                        _isCalendarView ? 'Content Calendar.' : 'Approval Inbox.',
                        style: AppTextStyles.displayTitle,
                      ),
                    ],
                  ),
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceAubergine,
                      foregroundColor: AppColors.marigold,
                    ),
                    icon: Icon(_isCalendarView ? Icons.view_agenda_rounded : Icons.calendar_month_rounded),
                    tooltip: _isCalendarView ? 'Switch to Feed View' : 'Switch to Calendar View',
                    onPressed: () {
                      setState(() => _isCalendarView = !_isCalendarView);
                      if (_isCalendarView) {
                        postProvider.fetchPosts(brand.id, status: 'ALL');
                      } else {
                        postProvider.fetchPosts(brand.id, status: 'PENDING_APPROVAL');
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),

              if (_isCalendarView) ...[
                _buildCalendarTimelineView(context, postProvider, brand.id),
              ] else ...[
                // Filter Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('WAITING REVIEW', 'PENDING_APPROVAL', postProvider, brand.id),
                      const SizedBox(width: 8),
                      _buildFilterChip('SCHEDULED', 'SCHEDULED', postProvider, brand.id),
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
      label: Text(label, style: AppTextStyles.badgeText.copyWith(color: isSelected ? Colors.white : AppColors.textSecondary)),
      selected: isSelected,
      selectedColor: AppColors.marigold,
      backgroundColor: Colors.white,
      side: BorderSide(color: isSelected ? AppColors.marigold : AppColors.borderAubergine),
      onSelected: (_) => provider.setFilter(statusKey, brandId),
    );
  }

  Widget _buildCalendarTimelineView(BuildContext context, PostProvider postProvider, String brandId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(14, (i) => today.subtract(const Duration(days: 2)).add(Duration(days: i)));

    // Posts matching selected day
    final dayPosts = postProvider.posts.where((p) {
      final targetDate = p.scheduledFor ?? p.publishedAt ?? p.createdAt;
      return targetDate.year == _selectedCalendarDay.year &&
          targetDate.month == _selectedCalendarDay.month &&
          targetDate.day == _selectedCalendarDay.day;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 14-day horizontal strip
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: days.map((day) {
              final isSelected = day.year == _selectedCalendarDay.year &&
                  day.month == _selectedCalendarDay.month &&
                  day.day == _selectedCalendarDay.day;
              final isToday = day.year == today.year && day.month == today.month && day.day == today.day;

              // Count posts for this day
              final count = postProvider.posts.where((p) {
                final targetDate = p.scheduledFor ?? p.publishedAt ?? p.createdAt;
                return targetDate.year == day.year &&
                    targetDate.month == day.month &&
                    targetDate.day == day.day;
              }).length;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCalendarDay = day),
                  child: Container(
                    width: 68,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.marigold : AppColors.surfaceAubergine,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.marigold
                            : (isToday ? AppColors.marigold.withValues(alpha: 0.5) : AppColors.borderAubergine),
                        width: isToday ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('EEE').format(day).toUpperCase(),
                          style: AppTextStyles.labelCaption.copyWith(
                            color: isSelected ? AppColors.textOnMarigold : AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${day.day}',
                          style: AppTextStyles.displaySub.copyWith(
                            color: isSelected ? AppColors.textOnMarigold : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (count > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.darkCanvas : AppColors.marigold,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '$count',
                              style: AppTextStyles.badgeText.copyWith(
                                color: isSelected ? AppColors.marigold : AppColors.textOnMarigold,
                                fontSize: 10,
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // Selected Day Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEEE, MMMM d').format(_selectedCalendarDay).toUpperCase(),
              style: AppTextStyles.labelCaption.copyWith(letterSpacing: 1.5),
            ),
            Text(
              '${dayPosts.length} POSTS',
              style: AppTextStyles.labelCaption.copyWith(color: AppColors.marigold),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (dayPosts.isEmpty)
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
                const Icon(Icons.event_available_rounded, color: AppColors.textTertiary, size: 40),
                const SizedBox(height: 12),
                Text('No Posts Scheduled for this Day', style: AppTextStyles.bodyBold),
                const SizedBox(height: 6),
                Text(
                  'Your audience expects consistency. Click below to generate or schedule a post.',
                  style: AppTextStyles.labelCaption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                GlowingButton(
                  text: 'Generate Post for This Day',
                  onPressed: () => _showGenerateModal(context, brandId),
                  icon: Icons.add_circle_outline_rounded,
                ),
              ],
            ),
          )
        else
          ...dayPosts.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildPostCard(context, p, brandId),
              )),
      ],
    );
  }

  Widget _buildPostCard(BuildContext context, PostModel post, String brandId) {
    final isPending = post.status == 'PENDING_APPROVAL';
    final isApproved = post.status == 'APPROVED';
    final isScheduled = post.status == 'SCHEDULED';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isPending ? AppColors.marigold : AppColors.borderAubergine,
          width: isPending ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
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
                  backgroundColor: const Color(0xFFF1F5F9),
                  textColor: AppColors.deepAubergine,
                ),
                const Spacer(),
                if (post.qualityScore != null)
                  GestureDetector(
                    onTap: () => _showCriticTeardownModal(context, post),
                    child: Tooltip(
                      message: 'View Critic Evaluation Teardown',
                      child: EditorialBadge.qualityScore(post.qualityScore!),
                    ),
                  ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 17, color: AppColors.marigold),
                  tooltip: 'Preview Feed Mockup',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    final brand = context.read<BrandProvider>().activeBrand;
                    SocialPostPreviewModal.show(context, post, brand?.name ?? 'Brand');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textTertiary),
                  tooltip: 'Copy caption & hashtags',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    final fullText = '${post.content}\n\n${post.hashtags.join(' ')}';
                    Clipboard.setData(ClipboardData(text: fullText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post copy and hashtags copied to clipboard!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: AppColors.textPrimary,
                      ),
                    );
                  },
                ),
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
                        style: AppTextStyles.labelCaption.copyWith(color: AppColors.textSecondary),
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
                  // Edit Button
                  TextButton.icon(
                    onPressed: () => _showEditDialog(context, post),
                    icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 16),
                    label: Text('Edit', style: AppTextStyles.bodyBold.copyWith(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                  // Rewrite Button
                  TextButton.icon(
                    onPressed: () => _showRewriteDialog(context, post),
                    icon: const Icon(Icons.auto_awesome, color: AppColors.textSecondary, size: 16),
                    label: Text('AI Rewrite', style: AppTextStyles.bodyBold.copyWith(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                  // Schedule Button
                  TextButton.icon(
                    onPressed: () => _showScheduleDialog(context, post),
                    icon: const Icon(Icons.schedule_rounded, color: AppColors.marigold, size: 18),
                    label: Text('Schedule', style: AppTextStyles.bodyBold.copyWith(color: AppColors.marigold, fontSize: 13)),
                  ),
                  // Approve Immediate
                  GlowingButton(
                    text: 'Approve',
                    onPressed: () => context.read<PostProvider>().approvePost(post.id),
                    icon: Icons.check_rounded,
                  ),
                ],
                if (isScheduled) ...[
                  if (post.scheduledFor != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Text(
                        'Queued: ${DateFormat('MMM d, h:mm a').format(post.scheduledFor!)}',
                        style: AppTextStyles.labelCaption.copyWith(color: AppColors.marigold),
                      ),
                    ),
                  GlowingButton(
                    text: 'Publish Now',
                    onPressed: () => context.read<PostProvider>().publishNow(post.id),
                    icon: Icons.rocket_launch_rounded,
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
