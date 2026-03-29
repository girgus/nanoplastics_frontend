import 'dart:io';

import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/app_spacing.dart';
import '../utils/app_sizing.dart';
import '../utils/app_typography.dart';
import '../widgets/nanosolve_logo.dart';
import '../widgets/glowing_header_separator.dart';
import '../l10n/app_localizations.dart';
import '../models/category_detail_data.dart';
import '../models/pdf_source.dart';
import '../models/sources.dart';
import '../services/logger_service.dart';
import '../services/settings_manager.dart';
import '../services/service_locator.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import '../services/web_link_cache_service.dart';
import '../utils/app_theme_colors.dart';
import '../utils/platform_adaptive.dart';
import 'pdf_viewer_screen.dart';
import 'web_view_screen.dart';

enum SourceType { webLinks, videoLinks }

class SourcesScreen extends StatefulWidget {
  const SourcesScreen({super.key});

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

enum WebLinkSection { humanHealth, earthPollution, waterAbilities }

enum VideoSection { videos, reports }

class _SourcesScreenState extends State<SourcesScreen> {
  SourceType _selectedTab = SourceType.webLinks;
  WebLinkSection _selectedSection = WebLinkSection.humanHealth;
  VideoSection _selectedVideoSection = VideoSection.videos;
  String _webLinksSearchQuery = '';
  final TextEditingController _webLinksSearchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    LoggerService().logScreenNavigation('SourcesScreen');
    LoggerService().logFeatureUsage('sources_screen_opened', metadata: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  void dispose() {
    _webLinksSearchController.dispose();
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
              AppColors.pastelAqua
                  .withValues(alpha: AppThemeColors.of(context).pastelAlpha),
              AppColors.pastelLavender
                  .withValues(alpha: AppThemeColors.of(context).pastelAlpha),
              AppThemeColors.of(context).gradientEnd,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: PlatformAdaptive.contentMaxWidth(context),
              ),
              child: Column(
                children: [
                  _SourcesScreenHeader(this),
                  _SourcesScreenTabs(
                    selectedTab: _selectedTab,
                    onTabChanged: (tab) => setState(() => _selectedTab = tab),
                  ),
                  Expanded(
                    child: _selectedTab == SourceType.webLinks
                        ? _buildWebLinksTab()
                        : _buildVideoLinksTab(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebLinksTab() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    final isMobilePlatform =
        !PlatformAdaptive.isWeb && (Platform.isAndroid || Platform.isIOS);
    if (isMobilePlatform) {
      return _buildMobileEvidenceWebLinksTab(
        l10n: l10n,
        spacing: spacing,
        sizing: sizing,
        typography: typography,
      );
    }

    final userLang = SettingsManager().userLanguage;

    final sections = [
      (
        section: WebLinkSection.humanHealth,
        title: l10n.sourcesSectionHumanHealth,
        icon: Icons.favorite_outline,
        sources:
            humanHealthSources.where((s) => s.language == userLang).toList(),
      ),
      (
        section: WebLinkSection.earthPollution,
        title: l10n.sourcesSectionEarthPollution,
        icon: Icons.public,
        sources:
            earthPollutionSources.where((s) => s.language == userLang).toList(),
      ),
      (
        section: WebLinkSection.waterAbilities,
        title: l10n.sourcesSectionWaterAbilities,
        icon: Icons.water_drop_outlined,
        sources:
            waterAbilitiesSources.where((s) => s.language == userLang).toList(),
      ),
    ];

    final selectedData =
        sections.firstWhere((s) => s.section == _selectedSection);

    return Column(
      children: [
        // ── Navigation: all 3 slim section headers ──
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.contentPaddingH),
          child: Column(
            children: [
              for (final s in sections) ...[
                _buildSectionHeader(
                  title: s.title,
                  icon: s.icon,
                  sourceCount: s.sources.length,
                  isSelected: s.section == _selectedSection,
                  spacing: spacing,
                  sizing: sizing,
                  typography: typography,
                  onTap: () => setState(() => _selectedSection = s.section),
                ),
                SizedBox(height: spacing.xs),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing.sm),
        // ── Content: selected section's items ──
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
                horizontal: spacing.contentPaddingH,
                vertical: spacing.contentPaddingV),
            itemCount: selectedData.sources.length,
            itemBuilder: (ctx, i) => _buildCompactSourceCard(
              number: i + 1,
              source: selectedData.sources[i],
              spacing: spacing,
              sizing: sizing,
              typography: typography,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileEvidenceWebLinksTab({
    required AppLocalizations l10n,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
  }) {
    final groups = _buildGroupedEvidenceLinks(l10n, _webLinksSearchQuery);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.contentPaddingH,
            spacing.xs,
            spacing.contentPaddingH,
            spacing.sm,
          ),
          child: TextField(
            controller: _webLinksSearchController,
            onChanged: (value) => setState(() => _webLinksSearchQuery = value),
            style: typography.body,
            decoration: InputDecoration(
              hintText: 'Search links by title, author, journal…',
              hintStyle: typography.bodySm.copyWith(
                color: AppThemeColors.of(context).textMuted,
              ),
              prefixIcon: Icon(
                Icons.search,
                size: sizing.iconSm,
                color: AppThemeColors.of(context).textMuted,
              ),
              suffixIcon: _webLinksSearchQuery.trim().isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.close,
                        size: sizing.iconSm,
                        color: AppThemeColors.of(context).textMuted,
                      ),
                      onPressed: () {
                        _webLinksSearchController.clear();
                        setState(() => _webLinksSearchQuery = '');
                      },
                    ),
              filled: true,
              fillColor: AppThemeColors.of(context)
                  .cardBackground
                  .withValues(alpha: 0.85),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                borderSide:
                    BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                borderSide:
                    BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                borderSide: BorderSide(
                  color: AppColors.pastelAqua.withValues(alpha: 0.55),
                ),
              ),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: groups.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: spacing.contentPaddingH),
                    child: Text(
                      'No links found.',
                      textAlign: TextAlign.center,
                      style: typography.bodySm.copyWith(
                        color: AppThemeColors.of(context).textMuted,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.contentPaddingH,
                    vertical: spacing.contentPaddingV,
                  ),
                  itemCount: groups.length,
                  itemBuilder: (ctx, groupIndex) {
                    final group = groups[groupIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.categoryTitle.toUpperCase(),
                          style: typography.title.copyWith(
                            color: group.categoryColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: spacing.sm),
                        ...group.studies.asMap().entries.map((entry) {
                          return _buildMobileEvidenceStudyCard(
                            category: group,
                            study: entry.value,
                            number: entry.key + 1,
                            spacing: spacing,
                            sizing: sizing,
                            typography: typography,
                          );
                        }),
                        SizedBox(height: spacing.lg),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<MobileEvidenceGroup> _buildGroupedEvidenceLinks(
    AppLocalizations l10n,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    final categories = CategoryDetailDataFactory.all(l10n);

    final groups = categories
        .map((category) {
          final seen = <String>{};
          final studies = category.evidenceSections
              .expand((section) => section.studies)
              .where((study) {
            if (normalizedQuery.isEmpty) return true;
            final haystack = [
              category.title,
              study.title,
              study.authorsShort,
              study.journal,
              study.url,
            ].join(' ').toLowerCase();
            return haystack.contains(normalizedQuery);
          }).where((study) {
            final key = '${study.title}|${study.url}';
            return seen.add(key);
          }).toList();

          studies.sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

          return MobileEvidenceGroup(
            categoryKey: category.categoryKey,
            categoryTitle: category.title,
            categoryColor: category.themeColor,
            studies: studies,
          );
        })
        .where((group) => group.studies.isNotEmpty)
        .toList();

    groups.sort((a, b) =>
        a.categoryTitle.toLowerCase().compareTo(b.categoryTitle.toLowerCase()));
    return groups;
  }

  Widget _buildMobileEvidenceStudyCard({
    required MobileEvidenceGroup category,
    required EvidenceStudy study,
    required int number,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
  }) {
    return InkWell(
      onTap: () => _openEvidenceStudyFromSources(category.categoryKey, study),
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: spacing.sm),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        decoration: BoxDecoration(
          color:
              AppThemeColors.of(context).cardBackground.withValues(alpha: 0.85),
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
                  color: AppThemeColors.of(context)
                      .textMuted
                      .withValues(alpha: 0.5),
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
                      color: AppThemeColors.of(context).textMain,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.xs / 2),
                  Text(
                    '${study.journal} · ${study.year} · ${study.authorsShort}',
                    style: typography.labelSm.copyWith(
                      color: AppThemeColors.of(context).textMuted,
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

  Future<void> _openEvidenceStudyFromSources(
    String categoryKey,
    EvidenceStudy study,
  ) async {
    LoggerService().logUserAction('sources_evidence_study_opened', params: {
      'category': categoryKey,
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
    } catch (e, st) {
      LoggerService().logError(
        'SourcesEvidenceStudyOpenFailed',
        '${study.url}: $e',
        st,
      );
    }
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required int sourceCount,
    required bool isSelected,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
    required VoidCallback onTap,
    Color? accentColorOverride,
  }) {
    final accentColor = isSelected
        ? (accentColorOverride ?? AppColors.pastelAqua)
        : AppColors.textMuted;
    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (accentColorOverride ?? AppColors.pastelAqua)
                    .withValues(alpha: 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: isSelected
                  ? (accentColorOverride ?? AppColors.pastelAqua)
                      .withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: sizing.iconXss, color: accentColor),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: typography.label.copyWith(
                    color: isSelected
                        ? AppThemeColors.of(context).textMain
                        : AppThemeColors.of(context).textMuted,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$sourceCount',
                  style: typography.labelXs.copyWith(color: accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoLinksTab() {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    final userLanguage = SettingsManager().userLanguage;

    // Get videos for user's language, fallback to English if not available
    final allVideos = allVideoSources[userLanguage] ?? videoSourcesEn;

    final sections = [
      (
        section: VideoSection.videos,
        title: l10n.sourcesVideoSectionDocumentaries,
        icon: Icons.play_circle_outline,
        sources: allVideos.where((v) => !v.isReport).toList(),
      ),
      // Not needed for now.
      // (
      //   section: VideoSection.reports,
      //   title: l10n.sourcesVideoSectionReports,
      //   icon: Icons.picture_as_pdf_outlined,
      //   sources: allVideos.where((v) => v.isReport).toList(),
      // ),
    ];

    final selectedData =
        sections.firstWhere((s) => s.section == _selectedVideoSection);

    return Column(
      children: [
        // ── Navigation: 2 slim section headers ──
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.contentPaddingH),
          child: Column(
            children: [
              for (final s in sections) ...[
                _buildSectionHeader(
                  title: s.title,
                  icon: s.icon,
                  sourceCount: s.sources.length,
                  isSelected: s.section == _selectedVideoSection,
                  accentColorOverride: AppColors.pastelMint,
                  spacing: spacing,
                  sizing: sizing,
                  typography: typography,
                  onTap: () =>
                      setState(() => _selectedVideoSection = s.section),
                ),
                SizedBox(height: spacing.xs),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing.sm),
        // ── Content: selected section's items ──
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
                horizontal: spacing.contentPaddingH,
                vertical: spacing.contentPaddingV),
            itemCount: selectedData.sources.length,
            itemBuilder: (ctx, i) => _buildCompactVideoCard(
              number: i + 1,
              video: selectedData.sources[i],
              spacing: spacing,
              sizing: sizing,
              typography: typography,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactVideoCard({
    required int number,
    required VideoSource video,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
  }) {
    final chipColor =
        video.isReport ? AppColors.pastelAqua : AppColors.pastelMint;
    final chipLabel = video.isReport ? 'PDF Report' : 'Documentary';

    return InkWell(
      onTap: () async {
        LoggerService().logUserAction('video_source_clicked', params: {
          'title': video.title,
          'url': video.url,
          'language': video.language,
          'isReport': video.isReport,
        });

        // Videos open in Chrome Custom Tab — stays in-app, supports full
        // YouTube playback without WebView limitations
        try {
          await launchUrl(
            Uri.parse(video.url),
            customTabsOptions: CustomTabsOptions(
              colorSchemes: CustomTabsColorSchemes.defaults(
                toolbarColor: AppThemeColors.of(context).cardBackground,
              ),
              shareState: CustomTabsShareState.off,
              urlBarHidingEnabled: true,
              showTitle: true,
            ),
            safariVCOptions: const SafariViewControllerOptions(
              preferredBarTintColor: Color(0xFF0A0A12),
              preferredControlTintColor: Color(0xFF7FFFD4),
              barCollapsingEnabled: true,
            ),
          );
        } catch (e) {
          LoggerService().logError('VideoLinkOpen', e.toString());
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: spacing.sm),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        decoration: BoxDecoration(
          color:
              AppThemeColors.of(context).cardBackground.withValues(alpha: 0.85),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Number
            SizedBox(
              width: 24,
              child: Text(
                number.toString().padLeft(2, '0'),
                style: typography.labelXs.copyWith(
                  color: AppThemeColors.of(context)
                      .textMuted
                      .withValues(alpha: 0.5),
                ),
              ),
            ),
            SizedBox(width: spacing.sm),
            // Title + chip
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    video.title,
                    style: typography.title.copyWith(
                      color: AppThemeColors.of(context).textMain,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.xs / 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: chipColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border:
                          Border.all(color: chipColor.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      chipLabel,
                      style: typography.labelXs.copyWith(color: chipColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            // Icon
            Icon(
              video.isReport ? Icons.picture_as_pdf : Icons.play_circle_filled,
              size: sizing.iconSm,
              color: chipColor.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Color _descriptionColor(String description) {
    if (description.contains('Brain') ||
        description.contains('Central') ||
        description.contains('мозг') ||
        description.contains('mozek') ||
        description.contains('Centraux') ||
        description.contains('Centrales')) {
      return AppColors.neonCyan;
    }
    if (description.contains('Heart') ||
        description.contains('Vital') ||
        description.contains('srdce') ||
        description.contains('Vitalit')) {
      return AppColors.neonCrimson;
    }
    if (description.contains('Reproduc') ||
        description.contains('Fertil') ||
        description.contains('placenta') ||
        description.contains('Репродук')) {
      return AppColors.neonViolet;
    }
    if (description.contains('Entry') ||
        description.contains('Inhal') ||
        description.contains('vstupní') ||
        description.contains('Entrées') ||
        description.contains('Vías') ||
        description.contains('Пути')) {
      return AppColors.neonOrange;
    }
    if (description.contains('Filtrat') ||
        description.contains('Detox') ||
        description.contains('Filtrace') ||
        description.contains('Filtr') ||
        description.contains('Фильтр')) {
      return AppColors.neonLime;
    }
    if (description.contains('Ocean') ||
        description.contains('Marine') ||
        description.contains('oceán') ||
        description.contains('Océan') ||
        description.contains('océano') ||
        description.contains('мор')) {
      return AppColors.neonOcean;
    }
    if (description.contains('Atmos') ||
        description.contains('atmos') ||
        description.contains('Atmosphère') ||
        description.contains('Атмос')) {
      return AppColors.neonAtmos;
    }
    if (description.contains('Flora') ||
        description.contains('Fauna') ||
        description.contains('Biosphere') ||
        description.contains('Biosphère')) {
      return AppColors.neonBio;
    }
    if (description.contains('Magnetic') ||
        description.contains('Core') ||
        description.contains('Magnét') ||
        description.contains('ядро') ||
        description.contains('Магнит')) {
      return AppColors.neonMagma;
    }
    return AppColors.pastelAqua;
  }

  Widget _buildCompactSourceCard({
    required int number,
    required PDFSource source,
    required AppSpacing spacing,
    required AppSizing sizing,
    required AppTypography typography,
  }) {
    final chipColor = _descriptionColor(source.description);
    return InkWell(
      onTap: () async {
        LoggerService().logUserAction('pdf_source_clicked', params: {
          'source': source.title,
          'startPage': source.startPage,
          'endPage': source.endPage,
        });

        // Non-PDF web links → in-app WebView (caches for offline use)
        if (source.isWebLink && !source.url!.contains('.pdf')) {
          final navigator = Navigator.of(context);
          await WebLinkCacheService().markVisited(source.url!);
          navigator.push(
            MaterialPageRoute(
              builder: (_) => WebViewScreen(
                url: source.url!,
                title: source.title,
              ),
            ),
          );
          return;
        }

        final navigator = Navigator.of(context);
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final themeColors = AppThemeColors.of(context);
        final dialogBg = themeColors.dialogBackground;
        final toolbarColor = themeColors.cardBackground;

        if (source.pdfAssetPath != null && source.pdfAssetPath!.isNotEmpty) {
          // Navigate immediately — PDFViewerScreen opens asset directly via
          // PdfDocument.openAsset(), no extraction step needed.
          navigator.push(
            MaterialPageRoute(
              builder: (_) => PDFViewerScreen(
                title: source.title,
                pdfAssetPath: source.pdfAssetPath,
                startPage: source.startPage,
                endPage: source.endPage,
                description: source.description,
              ),
            ),
          );
        } else {
          final lang = ServiceLocator().settingsManager.userLanguage;

          final cached =
              await ServiceLocator().settingsManager.getPdfForLanguage(lang);
          final needsDownload = cached == null || !await cached.exists();

          if (needsDownload && context.mounted) {
            showDialog(
              context: context, // ignore: use_build_context_synchronously
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                backgroundColor: dialogBg,
                title: const Text(
                  'Downloading PDF…',
                  style: TextStyle(color: AppColors.pastelAqua),
                ),
                content: const LinearProgressIndicator(
                  backgroundColor: Colors.white12,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.pastelAqua),
                ),
              ),
            );
          }

          File? pdf;
          try {
            pdf = await ServiceLocator().pdfService.resolvePdf(language: lang);
          } catch (e, st) {
            LoggerService().logError('ResolvePdfFailed', e.toString(), st);
          }

          if (needsDownload && context.mounted) await navigator.maybePop();
          if (!context.mounted) return;

          if (pdf != null) {
            final pdfPath = pdf.path;
            navigator.push(
              MaterialPageRoute(
                builder: (_) => PDFViewerScreen(
                  title: source.title,
                  pdfPath: pdfPath,
                  startPage: source.startPage,
                  endPage: source.endPage,
                  description: source.description,
                ),
              ),
            );
          } else if (source.isWebLink) {
            // PDF unavailable — open URL as fallback via Custom Tabs.
            // WebView can't render PDFs; Custom Tabs hands off to the
            // system PDF viewer / browser while keeping the user in-app.
            await WebLinkCacheService().markVisited(source.url!);
            try {
              await launchUrl(
                Uri.parse(source.url!),
                customTabsOptions: CustomTabsOptions(
                  colorSchemes: CustomTabsColorSchemes.defaults(
                    toolbarColor: toolbarColor,
                  ),
                  shareState: CustomTabsShareState.on,
                  urlBarHidingEnabled: true,
                  showTitle: true,
                ),
                safariVCOptions: const SafariViewControllerOptions(
                  preferredBarTintColor: AppColors.pastelLavender,
                  preferredControlTintColor: Colors.white,
                  barCollapsingEnabled: true,
                  dismissButtonStyle:
                      SafariViewControllerDismissButtonStyle.close,
                ),
              );
            } catch (e) {
              LoggerService().logError('PdfFallbackLaunchFailed', e.toString());
            }
          } else {
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Failed to load PDF')),
            );
          }
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: spacing.sm),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        decoration: BoxDecoration(
          color:
              AppThemeColors.of(context).cardBackground.withValues(alpha: 0.85),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Number
            SizedBox(
              width: 24,
              child: Text(
                number.toString().padLeft(2, '0'),
                style: typography.labelXs.copyWith(
                  color: AppThemeColors.of(context)
                      .textMuted
                      .withValues(alpha: 0.5),
                ),
              ),
            ),
            SizedBox(width: spacing.sm),
            // Title + subcategory chip
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    source.title,
                    style: typography.title.copyWith(
                      color: AppThemeColors.of(context).textMain,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.xs / 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: chipColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border:
                          Border.all(color: chipColor.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      source.description,
                      style: typography.labelXs.copyWith(color: chipColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            // Page range + icon + offline badge
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  source.getPageRangeDisplay(),
                  style: typography.labelSm.copyWith(
                    color: AppThemeColors.of(context).textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (source.isWebLink && !source.url!.contains('.pdf'))
                      FutureBuilder<bool>(
                        future: WebLinkCacheService().hasVisited(source.url!),
                        builder: (ctx, snap) {
                          if (snap.data == true) {
                            return Semantics(
                              label: 'Available offline',
                              child: Tooltip(
                                message: 'Available offline',
                                child: Icon(
                                  Icons.cloud_done,
                                  size: sizing.iconXs,
                                  color: AppColors.pastelMint
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    if (source.isWebLink && !source.url!.contains('.pdf'))
                      SizedBox(width: spacing.xs / 2),
                    Icon(
                      source.isWebLink && !source.url!.contains('.pdf')
                          ? Icons.open_in_browser
                          : Icons.picture_as_pdf,
                      size: sizing.iconSm,
                      color: AppColors.pastelAqua.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header Widget - extracted to prevent rebuild on tab change
// ─────────────────────────────────────────────────────────────────────────────
class _SourcesScreenHeader extends StatelessWidget {
  final _SourcesScreenState state;

  const _SourcesScreenHeader(this.state);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: spacing.contentPaddingH,
          vertical: spacing.contentPaddingV),
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
                  Icon(Icons.arrow_back_ios,
                      color: AppThemeColors.of(context).textMain,
                      size: sizing.backIcon),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Tabs Navigation Widget - extracted to reduce main rebuild impact
// ─────────────────────────────────────────────────────────────────────────────
class _SourcesScreenTabs extends StatelessWidget {
  final SourceType selectedTab;
  final Function(SourceType) onTabChanged;

  const _SourcesScreenTabs({
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: spacing.tabMarginH, vertical: sizing.tabMarginV),
          padding: EdgeInsets.all(spacing.tabInnerPadding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  label: AppLocalizations.of(context)!.sourcesTabWeb,
                  isActive: selectedTab == SourceType.webLinks,
                  textStyle: typography.tab,
                  padding: spacing.tabButtonPadding,
                  onTap: () {
                    onTabChanged(SourceType.webLinks);
                    LoggerService().logUserAction('sources_tab_switched',
                        params: {'tab': 'web'});
                  },
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  label: AppLocalizations.of(context)!.sourcesTabVideo,
                  isActive: selectedTab == SourceType.videoLinks,
                  textStyle: typography.tab,
                  padding: spacing.tabButtonPadding,
                  onTap: () {
                    onTabChanged(SourceType.videoLinks);
                    LoggerService().logUserAction('sources_tab_switched',
                        params: {'tab': 'video'});
                  },
                ),
              ),
            ],
          ),
        ),
        ...GlowingHeaderSeparator.build(
          glowColor: AppColors.energy,
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required TextStyle textStyle,
    required double padding,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: padding, horizontal: padding),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.pastelAqua.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: isActive
              ? Border.all(color: AppColors.pastelAqua.withValues(alpha: 0.3))
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.pastelAqua.withValues(alpha: 0.1),
                    blurRadius: 15,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: textStyle.copyWith(
            color: isActive ? AppColors.pastelAqua : AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
