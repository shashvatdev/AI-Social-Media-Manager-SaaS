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
          backgroundColor: Color(0xFFECFDF5),
          textColor: Color(0xFF059669),
          icon: Icons.check_circle_rounded,
        );
      case 'SCHEDULED':
        return const EditorialBadge(
          label: 'SCHEDULED QUEUE',
          backgroundColor: Color(0xFFFFFBEB),
          textColor: Color(0xFFD97706),
          icon: Icons.schedule_rounded,
        );
      case 'PUBLISHED':
        return const EditorialBadge(
          label: 'LIVE ON SOCIAL',
          backgroundColor: Color(0xFFEFF6FF),
          textColor: Color(0xFF2563EB),
          icon: Icons.rocket_launch_rounded,
        );
      case 'REJECTED':
        return const EditorialBadge(
          label: 'REJECTED',
          backgroundColor: Color(0xFFFEF2F2),
          textColor: Color(0xFFDC2626),
          icon: Icons.cancel_rounded,
        );
      case 'PENDING_APPROVAL':
      default:
        return const EditorialBadge(
          label: 'WAITING YOUR APPROVAL',
          backgroundColor: Color(0xFFF1F5F9),
          textColor: AppColors.deepAubergine,
          icon: Icons.hourglass_top_rounded,
        );
    }
  }

  factory EditorialBadge.qualityScore(String score) {
    return EditorialBadge(
      label: 'CRITIC $score',
      backgroundColor: const Color(0xFFFFFBEB),
      textColor: const Color(0xFFD97706),
      icon: Icons.star_rounded,
    );
  }

  factory EditorialBadge.funnel(String stage) {
    return EditorialBadge(
      label: stage.toUpperCase(),
      backgroundColor: const Color(0xFFF8FAFC),
      textColor: AppColors.textSecondary,
      icon: Icons.filter_alt_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: textColor.withValues(alpha: 0.25), width: 1),
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
