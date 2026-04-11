import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../models/category_detail_data.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_theme_colors.dart';
import '../../utils/app_typography.dart';

class EvidenceStudyCard extends StatelessWidget {
  final EvidenceStudy study;
  final int number;
  final VoidCallback onTap;

  const EvidenceStudyCard({
    super.key,
    required this.study,
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    final themeColors = AppThemeColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: spacing.sm),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        decoration: BoxDecoration(
          color: themeColors.cardBackground.withValues(alpha: 0.85),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              child: Text(
                number.toString().padLeft(2, '0'),
                style: typography.labelXs.copyWith(
                  color: themeColors.textMuted.withValues(alpha: 0.5),
                ),
              ),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    study.title,
                    style: typography.title.copyWith(
                      color: themeColors.textMain,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.xs / 2),
                  Text(
                    '${study.journal} · ${study.year} · ${study.authorsShort}',
                    style: typography.labelSm.copyWith(
                      color: themeColors.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            Icon(
              Icons.open_in_new,
              size: sizing.iconSm,
              color: AppColors.pastelAqua.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
