import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/category_detail_data.dart';
import '../services/logger_service.dart';
import '../utils/app_sizing.dart';
import '../utils/app_spacing.dart';
import '../utils/app_theme_colors.dart';
import '../utils/app_typography.dart';
import '../utils/platform_adaptive.dart';
import '../utils/responsive_config.dart';
import '../widgets/nanosolve_logo.dart';

class CategoryEvidenceScreen extends StatefulWidget {
  final CategoryDetailData categoryData;

  const CategoryEvidenceScreen({
    super.key,
    required this.categoryData,
  });

  @override
  State<CategoryEvidenceScreen> createState() => _CategoryEvidenceScreenState();
}

class _CategoryEvidenceScreenState extends State<CategoryEvidenceScreen> {
  @override
  void initState() {
    super.initState();
    LoggerService().logScreenNavigation(
      'CategoryEvidenceScreen',
      params: {'category': widget.categoryData.title},
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.categoryData.evidenceSections;
    final spacing = AppSpacing.of(context);

    return Scaffold(
      body: Container(
        key: const ValueKey('category-evidence-screen'),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.6,
            colors: [
              widget.categoryData.themeColor.withValues(alpha: 0.12),
              AppThemeColors.of(context).gradientEnd,
              const Color(0xFF090C16),
            ],
            stops: const [0.0, 0.35, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Stack(
                  children: [
                    Builder(builder: (context) {
                      final allStudies = sections
                          .expand((s) => s.studies)
                          .toList(growable: false);
                      if (allStudies.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.contentPaddingH,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .categoryDetailSourcesTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppThemeColors.of(context).textMuted,
                                  ),
                            ),
                          ),
                        );
                      }
                      final typography = AppTypography.of(context);
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.contentPaddingH,
                          vertical: spacing.contentPaddingV,
                        ),
                        itemCount: allStudies.length + 1,
                        itemBuilder: (ctx, i) {
                          if (i == 0) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: spacing.md),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .categoryDetailSourcesTitle,
                                style: typography.headline.copyWith(
                                  color: AppThemeColors.of(context).textMain,
                                ),
                              ),
                            );
                          }
                          return _buildStudyCard(
                            index: i,
                            study: allStudies[i - 1],
                          );
                        },
                      );
                    }),
                    // Glow separator at top (below logo)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              widget.categoryData.themeColor
                                  .withValues(alpha: 0.12),
                              widget.categoryData.themeColor
                                  .withValues(alpha: 0.03),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: AppConstants.space40,
                      right: AppConstants.space40,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              widget.categoryData.themeColor
                                  .withValues(alpha: 0.75),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.categoryData.themeColor
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    final responsive = ResponsiveConfig.fromContext(context);
    final isXLargePortrait = responsive.isPortrait && responsive.isXLargePhone;
    final backFontSize =
        (typography.back.fontSize ?? 12) * (isXLargePortrait ? 0.88 : 1.0);
    final logoHeight = sizing.logoHeightLg * (isXLargePortrait ? 0.82 : 1.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.contentPaddingH,
        vertical: spacing.contentPaddingV * (isXLargePortrait ? 0.5 : 0.65),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      color: AppThemeColors.of(context).textMain,
                      size: sizing.backIcon,
                    ),
                    const SizedBox(width: AppConstants.space4),
                    Flexible(
                      child: Text(
                        l10n.categoryDetailBackToOverview,
                        style: typography.back.copyWith(
                          color: AppThemeColors.of(context).textMain,
                          fontSize: backFontSize,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: spacing.sm * (isXLargePortrait ? 0.7 : 1.0)),
          NanosolveLogo(height: logoHeight),
        ],
      ),
    );
  }

  Widget _buildStudyCard({
    required int index,
    required EvidenceStudy study,
  }) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    return Semantics(
      button: true,
      label: study.title,
      child: InkWell(
        key: ValueKey('evidence-study-card-$index'),
        onTap: () => _openStudy(study),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: spacing.sm),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppThemeColors.of(context)
                .cardBackground
                .withValues(alpha: 0.85),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number
              SizedBox(
                width: 24,
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: typography.labelXs.copyWith(
                    color: AppThemeColors.of(context)
                        .textMuted
                        .withValues(alpha: 0.5),
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      study.title,
                      style: typography.title.copyWith(
                        color: AppThemeColors.of(context).textMain,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing.xs / 2),
                    _buildMetaChip(
                      '${study.journal} · ${study.year}',
                      AppColors.pastelLavender,
                    ),
                    SizedBox(height: spacing.xs / 2),
                    // Authors
                    Text(
                      study.authorsShort,
                      style: typography.labelXs.copyWith(
                        color: AppThemeColors.of(context).textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (study.summary != null && study.summary!.isNotEmpty) ...[
                      SizedBox(height: spacing.xs / 2),
                      Text(
                        study.summary!,
                        style: typography.labelSm.copyWith(
                          color: AppThemeColors.of(context).textMuted,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              // Open icon
              Icon(
                Icons.open_in_new,
                size: sizing.iconSm,
                color: AppColors.pastelAqua.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space8,
        vertical: AppConstants.space4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }

  Future<void> _openStudy(EvidenceStudy study) async {
    LoggerService().logUserAction('category_evidence_study_opened', params: {
      'category': widget.categoryData.categoryKey,
      'title': study.title,
      'journal': study.journal,
      'year': study.year,
    });

    try {
      final url =
          '${study.url}${study.url.contains('?') ? '&' : '?'}utm_source=nanoplastics_app';

      if (PlatformAdaptive.isWeb) {
        await PlatformAdaptive.launchExternalUrl(url);
        return;
      }

      await launchUrl(
        Uri.parse(url),
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: const Color(0xFF141928),
          ),
          shareState: CustomTabsShareState.on,
          urlBarHidingEnabled: true,
          showTitle: true,
          browser: const CustomTabsBrowserConfiguration(
            fallbackCustomTabs: [
              'org.mozilla.firefox',
              'org.mozilla.firefox_beta',
              'com.microsoft.emmx',
            ],
          ),
        ),
        safariVCOptions: const SafariViewControllerOptions(
          preferredBarTintColor: Color(0xFF141928),
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: true,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (e, stackTrace) {
      LoggerService().logError(
          'Evidence study open failed', '${study.url}: $e', stackTrace);
    }
  }
}
