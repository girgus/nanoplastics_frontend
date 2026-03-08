import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/category_detail_data.dart';
import '../services/logger_service.dart';
import '../services/service_locator.dart';
import '../utils/app_sizing.dart';
import '../utils/app_spacing.dart';
import '../utils/app_theme_colors.dart';
import '../utils/app_typography.dart';
import '../widgets/brainstorm_box.dart';
import '../widgets/nanosolve_logo.dart';
import 'category_evidence_screen.dart';
import 'pdf_viewer_screen.dart';

class CategoryDetailNewScreen extends StatefulWidget {
  final CategoryDetailData categoryData;

  const CategoryDetailNewScreen({
    super.key,
    required this.categoryData,
  });

  @override
  State<CategoryDetailNewScreen> createState() =>
      _CategoryDetailNewScreenState();
}

class _CategoryDetailNewScreenState extends State<CategoryDetailNewScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    LoggerService().logScreenNavigation(
      'CategoryDetailScreen',
      params: {
        'category': widget.categoryData.title,
        'subtitle': widget.categoryData.subtitle,
      },
    );
    LoggerService().logFeatureUsage('category_detail_opened', metadata: {
      'category': widget.categoryData.title,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              widget.categoryData.themeColor.withValues(alpha: 0.08),
              AppThemeColors.of(context).gradientEnd,
              AppThemeColors.of(context).gradientEnd,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Stack(
                  children: [
                    _buildScrollableContent(),
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

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.contentPaddingH,
        vertical: spacing.contentPaddingV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: spacing.headerSpacing),
          NanosolveLogo(height: sizing.logoHeightLg),
        ],
      ),
    );
  }

  Widget _buildHeroIcon() {
    final sizing = AppSizing.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: sizing.heroPadding),
          child: Container(
            width: sizing.heroIconSize,
            height: sizing.heroIconSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.categoryData.themeColor.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: widget.categoryData.glowColor,
                  blurRadius: 30 + (_animationController.value * 20),
                  spreadRadius: 5 + (_animationController.value * 5),
                ),
              ],
            ),
            child: Icon(
              widget.categoryData.icon,
              size: sizing.heroIconInnerSize,
              color: widget.categoryData.themeColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollableContent() {
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.space20),
      child: Column(
        children: [
          SizedBox(height: spacing.headerSpacing),
          Text(
            widget.categoryData.title.toUpperCase(),
            style: typography.headline.copyWith(
              color: AppThemeColors.of(context).textMain,
            ),
            textAlign: TextAlign.center,
          ),
          _buildHeroIcon(),
          _buildInfoPanel(),
          const SizedBox(height: AppConstants.space30),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    final subtitleStyle = Theme.of(context).textTheme.headlineSmall;

    return Container(
      decoration: BoxDecoration(
        color: AppThemeColors.of(context).surfaceMid.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
        border: Border.all(
          color: widget.categoryData.themeColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.categoryData.subtitle.toUpperCase(),
            style: subtitleStyle?.copyWith(
              color: widget.categoryData.themeColor,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: AppConstants.space8,
              bottom: AppConstants.space20,
            ),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.categoryData.themeColor.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          ...widget.categoryData.entries.map(_buildEntry),
          if (widget.categoryData.evidenceSections.isNotEmpty) ...[
            const SizedBox(height: AppConstants.space20),
            _buildDivider(),
            const SizedBox(height: AppConstants.space20),
            _buildEvidencePreview(),
          ],
          const SizedBox(height: AppConstants.space20),
          _buildDivider(),
          const SizedBox(height: AppConstants.space20),
          BrainstormBox(
            title: AppLocalizations.of(context)!.categoryDetailBrainstormTitle,
            username:
                AppLocalizations.of(context)!.categoryDetailBrainstormUser,
            placeholder: AppLocalizations.of(context)!
                .categoryDetailBrainstormPlaceholder,
            category: widget.categoryData.categoryKey,
            onSubmit: (text, attachments) async {
              LoggerService().logIdeaSubmission(
                category: widget.categoryData.categoryKey,
                title: text,
                contentLength: text.length,
              );

              final result = await ServiceLocator().apiService.submitIdea(
                    description: text,
                    category: widget.categoryData.categoryKey,
                    attachments: attachments,
                  );

              if (!result['success']) {
                LoggerService().logError(
                  'idea_submission_failed_in_ui',
                  result['message'],
                );
                throw Exception(result['message']);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEvidencePreview() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    final themeColor = widget.categoryData.themeColor;

    return Semantics(
      button: true,
      label: l10n.categoryDetailSourcesTitle,
      child: InkWell(
        key: const ValueKey('evidence-preview-open'),
        onTap: _openEvidenceLibrary,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.md,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                themeColor.withValues(alpha: 0.13),
                themeColor.withValues(alpha: 0.05),
                AppThemeColors.of(context)
                    .cardBackground
                    .withValues(alpha: 0.5),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: themeColor.withValues(alpha: 0.32),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.categoryData.glowColor.withValues(alpha: 0.14),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.space10),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(
                    color: themeColor.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(
                  Icons.biotech_outlined,
                  size: sizing.iconSm,
                  color: themeColor,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.categoryDetailSourcesTitle.toUpperCase(),
                      style: typography.label.copyWith(
                        color: themeColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.categoryData.evidenceStudyCount} ${l10n.categoryDetailSourcesCount}',
                      style: typography.bodySm.copyWith(
                        color: AppThemeColors.of(context).textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              Icon(
                Icons.arrow_forward_ios,
                size: sizing.iconXs,
                color: themeColor.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEvidenceLibrary() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CategoryEvidenceScreen(categoryData: widget.categoryData),
      ),
    );
  }

  Widget _buildEntry(DetailEntry entry) {
    const bulletSize = 6.0;
    final highlightStyle = Theme.of(context).textTheme.titleSmall;
    final descStyle = Theme.of(context).textTheme.headlineMedium;
    const pdfIconSize = AppConstants.iconSmall;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              if (entry.pdfStartPage == null || entry.pdfEndPage == null) {
                return;
              }

              LoggerService().logUserAction(
                'pdf_entry_clicked',
                params: {
                  'category': widget.categoryData.title,
                  'entry': entry.highlight,
                  'startPage': entry.pdfStartPage,
                  'endPage': entry.pdfEndPage,
                },
              );

              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final pdf = await ServiceLocator().pdfService.resolvePdf(
                    language: ServiceLocator().settingsManager.userLanguage,
                  );
              if (!context.mounted) return;

              if (pdf != null) {
                navigator.push(
                  MaterialPageRoute(
                    builder: (_) => PDFViewerScreen(
                      title: entry.highlight,
                      pdfPath: pdf.path,
                      startPage: entry.pdfStartPage!,
                      endPage: entry.pdfEndPage!,
                      description:
                          entry.pdfCategory ?? widget.categoryData.title,
                    ),
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Failed to load PDF')),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.space8,
                vertical: AppConstants.space4,
              ),
              decoration: BoxDecoration(
                color: widget.categoryData.themeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                border: Border.all(
                  color: widget.categoryData.themeColor.withValues(alpha: 0.4),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        entry.highlight.toUpperCase(),
                        style: highlightStyle?.copyWith(
                          color: widget.categoryData.themeColor,
                        ),
                      ),
                    ),
                    if (entry.pdfStartPage != null &&
                        entry.pdfEndPage != null) ...[
                      const SizedBox(width: AppConstants.space4),
                      Icon(
                        Icons.picture_as_pdf,
                        size: pdfIconSize,
                        color: widget.categoryData.themeColor
                            .withValues(alpha: 0.7),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.space8),
          Text(
            entry.description,
            style: descStyle?.copyWith(
              color: AppThemeColors.of(context).textMain,
              fontWeight: FontWeight.normal,
            ),
          ),
          if (entry.bulletPoints != null && entry.bulletPoints!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.space8),
            ...entry.bulletPoints!.map(
              (point) => Padding(
                padding: const EdgeInsets.only(
                  left: AppConstants.space16,
                  bottom: AppConstants.space4,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        top: AppConstants.space8,
                        right: AppConstants.space8,
                      ),
                      width: bulletSize,
                      height: bulletSize,
                      decoration: BoxDecoration(
                        color: widget.categoryData.themeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.categoryData.glowColor,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppThemeColors.of(context).textMuted,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.pastelAqua.withValues(alpha: 0.5),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
