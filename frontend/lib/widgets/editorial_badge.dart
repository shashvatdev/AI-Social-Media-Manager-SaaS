import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class EditorialBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const EditorialBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory EditorialBadge.status(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return const EditorialBadge(
          label: 'APPROVED',
          backgroundColor: Color(0x2200E599),
          textColor: AppColors.emeraldSuccess,
          icon: Icons.check_circle_rounded,
        );
      case 'PUBLISHED':
        return const EditorialBadge(
          label: 'LIVE ON SOCIAL',
          backgroundColor: Color(0x33EAAA00),
          textColor: AppColors.marigold,
          icon: Icons.rocket_launch_rounded,
        );
      case 'REJECTED':
        return const EditorialBadge(
          label: 'REJECTED',
          backgroundColor: Color(0x22FF3366),
          textColor: AppColors.crimsonReject,
          icon: Icons.cancel_rounded,
        );
      case 'PENDING_APPROVAL':
      default:
        return const EditorialBadge(
          label: 'WAITING YOUR APPROVAL',
          backgroundColor: Color(0x333A0F34),
          textColor: AppColors.iceSilver,
          icon: Icons.hourglass_top_rounded,
        );
    }
  }

  factory EditorialBadge.qualityScore(String score) {
    return EditorialBadge(
      label: 'QUALITY SCORE: $score',
      backgroundColor: const Color(0x22EAAA00),
      textColor: AppColors.marigold,
      icon: Icons.stars_rounded,
    );
  }

  factory EditorialBadge.funnel(String stage) {
    return EditorialBadge(
      label: stage.toUpperCase(),
      backgroundColor: const Color(0x224C1844),
      textColor: AppColors.iceSilver,
      icon: Icons.filter_alt_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTextStyles.badgeText.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
