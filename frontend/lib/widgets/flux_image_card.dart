import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class FluxImageCard extends StatelessWidget {
  final String imageUrl;
  final String? prompt;

  const FluxImageCard({
    super.key,
    required this.imageUrl,
    this.prompt,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceAubergine,
          border: Border.all(color: AppColors.borderAubergine, width: 1),
        ),
        child: AspectRatio(
          aspectRatio: 1.0, // 1024x1024 square social format
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surfaceAubergine,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.marigold,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surfaceAubergine,
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.image_outlined, color: AppColors.textTertiary, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          'Creative Visual Processing',
                          style: AppTextStyles.labelCaption,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Subtle gradient overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.75),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.marigold, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'AI FLUX CREATIVE (1024x1024)',
                        style: AppTextStyles.badgeText.copyWith(color: AppColors.iceSilver),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
