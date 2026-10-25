import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/post_model.dart';

class SocialPostPreviewModal extends StatefulWidget {
  final PostModel post;
  final String brandName;

  const SocialPostPreviewModal({
    super.key,
    required this.post,
    required this.brandName,
  });

  static void show(BuildContext context, PostModel post, String brandName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SocialPostPreviewModal(post: post, brandName: brandName),
    );
  }

  @override
  State<SocialPostPreviewModal> createState() => _SocialPostPreviewModalState();
}

class _SocialPostPreviewModalState extends State<SocialPostPreviewModal> {
  late String _currentPlatform;

  @override
  void initState() {
    super.initState();
    _currentPlatform = widget.post.platform.toUpperCase();
    if (_currentPlatform != 'LINKEDIN' && _currentPlatform != 'TWITTER') {
      _currentPlatform = 'LINKEDIN';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.surfaceAubergine,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderAubergine,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Modal Header & Platform Switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LIVE FEED MOCKUP PREVIEW', style: AppTextStyles.labelCaption),
                    const SizedBox(height: 2),
                    Text('How it appears to your ICP', style: AppTextStyles.displaySub),
                  ],
                ),
                Row(
                  children: [
                    ChoiceChip(
                      label: Text('LinkedIn', style: AppTextStyles.badgeText.copyWith(color: _currentPlatform == 'LINKEDIN' ? AppColors.textOnMarigold : AppColors.textPrimary)),
                      selected: _currentPlatform == 'LINKEDIN',
                      selectedColor: AppColors.marigold,
                      backgroundColor: AppColors.darkCanvas,
                      side: const BorderSide(color: AppColors.borderAubergine),
                      onSelected: (_) => setState(() => _currentPlatform = 'LINKEDIN'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('Twitter / X', style: AppTextStyles.badgeText.copyWith(color: _currentPlatform == 'TWITTER' ? AppColors.textOnMarigold : AppColors.textPrimary)),
                      selected: _currentPlatform == 'TWITTER',
                      selectedColor: AppColors.marigold,
                      backgroundColor: AppColors.darkCanvas,
                      side: const BorderSide(color: AppColors.borderAubergine),
                      onSelected: (_) => setState(() => _currentPlatform = 'TWITTER'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.borderAubergine, height: 1),

          // Feed Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: _currentPlatform == 'LINKEDIN'
                  ? _buildLinkedInMockup()
                  : _buildTwitterMockup(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedInMockup() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderAubergine),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.marigold,
                  child: Text(
                    widget.brandName.isNotEmpty ? widget.brandName[0].toUpperCase() : 'B',
                    style: AppTextStyles.displaySub.copyWith(color: AppColors.textOnMarigold, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(widget.brandName, style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary, fontSize: 15)),
                          const SizedBox(width: 6),
                          Text('• 1st', style: AppTextStyles.labelCaption.copyWith(color: AppColors.textTertiary)),
                        ],
                      ),
                      Text('Autonomous Content Lead & AI Director', style: AppTextStyles.labelCaption.copyWith(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text('2h • ', style: AppTextStyles.labelCaption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
                          const Icon(Icons.public, color: AppColors.textTertiary, size: 12),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz, color: AppColors.textTertiary),
              ],
            ),
          ),

          // Post Text Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SelectableText(
              widget.post.content,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.45, fontSize: 14),
            ),
          ),

          // Hashtags
          if (widget.post.hashtags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
              child: Text(
                widget.post.hashtags.join(' '),
                style: AppTextStyles.bodyBold.copyWith(color: const Color(0xFF0A66C2), fontSize: 13),
              ),
            ),

          const SizedBox(height: 12),

          // Creative Image
          if (widget.post.mediaUrls.isNotEmpty)
            CachedNetworkImage(
              imageUrl: widget.post.mediaUrls.first,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 260,
                color: const Color(0xFFF1F5F9),
                child: const Center(child: CircularProgressIndicator(color: AppColors.marigold)),
              ),
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),

          // Social Stats Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.thumb_up_alt_rounded, size: 14, color: Color(0xFF0A66C2)),
                    const SizedBox(width: 4),
                    const Icon(Icons.favorite_rounded, size: 14, color: Color(0xFFDF704D)),
                    const SizedBox(width: 6),
                    Text('142', style: AppTextStyles.labelCaption.copyWith(color: AppColors.textTertiary, fontSize: 12)),
                  ],
                ),
                Text('28 comments • 14 reposts', style: AppTextStyles.labelCaption.copyWith(color: AppColors.textTertiary, fontSize: 12)),
              ],
            ),
          ),

          const Divider(color: AppColors.borderAubergine, height: 1),

          // Interaction Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLinkedInAction(Icons.thumb_up_alt_outlined, 'Like'),
                _buildLinkedInAction(Icons.chat_bubble_outline_rounded, 'Comment'),
                _buildLinkedInAction(Icons.repeat_rounded, 'Repost'),
                _buildLinkedInAction(Icons.send_rounded, 'Send'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedInAction(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.bodyBold.copyWith(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTwitterMockup() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderAubergine),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.marigold,
                child: Text(
                  widget.brandName.isNotEmpty ? widget.brandName[0].toUpperCase() : 'B',
                  style: AppTextStyles.displaySub.copyWith(color: AppColors.textOnMarigold, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Text(widget.brandName, style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary, fontSize: 15)),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Color(0xFF1D9BF0), size: 16),
                    const SizedBox(width: 6),
                    Text('@${widget.brandName.replaceAll(' ', '').toLowerCase()} · 2h', style: AppTextStyles.labelCaption.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: AppColors.textTertiary),
            ],
          ),

          const SizedBox(height: 12),

          // Tweet Body
          SelectableText(
            widget.post.content,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.4, fontSize: 15),
          ),

          if (widget.post.hashtags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.post.hashtags.join(' '),
                style: AppTextStyles.bodyBold.copyWith(color: const Color(0xFF1D9BF0), fontSize: 14),
              ),
            ),

          const SizedBox(height: 14),

          // Creative Image
          if (widget.post.mediaUrls.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: widget.post.mediaUrls.first,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 240,
                  color: const Color(0xFFF1F5F9),
                  child: const Center(child: CircularProgressIndicator(color: AppColors.marigold)),
                ),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

          const SizedBox(height: 16),

          // Twitter Interaction Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTwitterAction(Icons.chat_bubble_outline_rounded, '18'),
              _buildTwitterAction(Icons.repeat_rounded, '34'),
              _buildTwitterAction(Icons.favorite_border_rounded, '289'),
              _buildTwitterAction(Icons.bookmark_border_rounded, '61'),
              _buildTwitterAction(Icons.share_outlined, ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTwitterAction(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        if (count.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(count, style: AppTextStyles.labelCaption.copyWith(color: AppColors.textTertiary, fontSize: 12)),
        ],
      ],
    );
  }
}
