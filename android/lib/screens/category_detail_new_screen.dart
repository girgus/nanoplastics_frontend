import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import '../config/app_colors.dart';
import '../widgets/nanosolve_logo.dart';
import '../widgets/brainstorm_box.dart';
import '../models/category_detail_data.dart';
import '../l10n/app_localizations.dart';
import 'pdf_viewer_screen.dart';
import '../services/logger_service.dart';

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
  late AnimationController _animationController;
  bool _isSourcesExpanded = false;
  CustomTabsSession? _customTabsSession;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Warmup Custom Tabs for faster loading
    _warmupCustomTabs();

    // Log category view
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

  Future<void> _warmupCustomTabs() async {
    try {
      _customTabsSession = await warmupCustomTabs();
    } catch (e) {
      debugPrint('Failed to warmup custom tabs: $e');
    }
  }

  Future<void> _preFetchUrls() async {
    if (_customTabsSession == null ||
        widget.categoryData.sourceLinks == null ||
        widget.categoryData.sourceLinks!.isEmpty) {
      return;
    }

    try {
      // Pre-fetch the first few URLs that are most likely to be opened
      final urlsToPrefetch = widget.categoryData.sourceLinks!
          .take(3)
          .map((link) => Uri.parse(link.url))
          .toList();

      for (final url in urlsToPrefetch) {
        await mayLaunchUrl(
          url,
          customTabsSession: _customTabsSession,
        );
      }
    } catch (e) {
      debugPrint('Failed to pre-fetch URLs: $e');
    }
  }

  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    // CustomTabsSession doesn't need explicit cleanup, just release reference
    _customTabsSession = null;
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
              const Color(0xFF080A10),
              const Color(0xFF0A0A14),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildHeroIcon(),
              Expanded(
                child: _buildScrollableContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                tooltip: l10n.categoryDetailBack,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.categoryDetailBackToOverview,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const NanosolveLogo(height: 60),
          const SizedBox(height: 15),
          Text(
            widget.categoryData.title.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIcon() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
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
              size: 60,
              color: widget.categoryData.themeColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildInfoPanel(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F141E).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(25),
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
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.categoryData.subtitle.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: widget.categoryData.themeColor,
              letterSpacing: 0.5,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 20),
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
          ...widget.categoryData.entries.map((entry) => _buildEntry(entry)),
          if (widget.categoryData.sourceLinks != null &&
              widget.categoryData.sourceLinks!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildDivider(),
            const SizedBox(height: 20),
            _buildSourcesSection(),
          ],
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),
          BrainstormBox(
            title: AppLocalizations.of(context)!.categoryDetailBrainstormTitle,
            username:
                AppLocalizations.of(context)!.categoryDetailBrainstormUser,
            placeholder: AppLocalizations.of(context)!
                .categoryDetailBrainstormPlaceholder,
            onSubmit: (text) {
              // Handle brainstorm submission
              LoggerService().logIdeaSubmission(
                category: widget.categoryData.title,
                title: text,
                contentLength: text.length,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSourcesSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isSourcesExpanded = !_isSourcesExpanded;
            });
            // Pre-fetch URLs when sources are expanded
            if (_isSourcesExpanded) {
              _preFetchUrls();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141928).withValues(alpha: 0.85),
              border: Border.all(
                color: AppColors.pastelAqua.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.pastelAqua.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.menu_book_outlined,
                    size: 24,
                    color: AppColors.pastelAqua,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.categoryDetailSourcesTitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.categoryData.sourceLinks!.length} ${l10n.categoryDetailSourcesCount}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isSourcesExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.pastelAqua,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (_isSourcesExpanded) ...[
          const SizedBox(height: 12),
          ...widget.categoryData.sourceLinks!.asMap().entries.map((entry) {
            return _buildSourceLinkCard(
              number: entry.key + 1,
              sourceLink: entry.value,
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSourceLinkCard({
    required int number,
    required SourceLink sourceLink,
  }) {
    return GestureDetector(
      onTap: () => _handleSourceLink(sourceLink),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF141928).withValues(alpha: 0.85),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sourceLink.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    sourceLink.source,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.pastelLavender,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '#$number',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Icon(
                  Icons.open_in_new,
                  size: 18,
                  color: AppColors.pastelAqua.withValues(alpha: 0.8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSourceLink(SourceLink sourceLink) async {
    // Check if this is a PDF asset link
    if (sourceLink.pdfAssetPath != null) {
      _launchPdfAsset(sourceLink);
    } else {
      // Otherwise launch as web URL
      _launchUrl(sourceLink.url);
    }
  }

  void _launchPdfAsset(SourceLink sourceLink) {
    debugPrint('📄 [PDF] Opening PDF asset: ${sourceLink.pdfAssetPath}');
    final startPage = sourceLink.pdfStartPage ?? 1;
    final endPage = sourceLink.pdfEndPage ?? 999;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(
          title: sourceLink.title,
          startPage: startPage,
          endPage: endPage,
          description: sourceLink.source,
          pdfAssetPath: sourceLink.pdfAssetPath!,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    debugPrint('🔗 [CustomTabs] Launching URL: $url');
    try {
      final uri = Uri.parse(url);
      debugPrint('🔗 [CustomTabs] Parsed URI: $uri');
      debugPrint('🔗 [CustomTabs] Using Firefox with Custom Tabs');

      // Add referrer to make the request look more legitimate
      final urlWithReferrer =
          '$url${url.contains('?') ? '&' : '?'}utm_source=nanoplastics_app';

      await launchUrl(
        Uri.parse(urlWithReferrer),
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: const Color(0xFF0F141E),
          ),
          shareState: CustomTabsShareState.on,
          urlBarHidingEnabled: false,
          showTitle: true,
          // Explicitly use Firefox to avoid detection
          browser: const CustomTabsBrowserConfiguration(
            fallbackCustomTabs: [
              'org.mozilla.firefox',
              'org.mozilla.firefox_beta',
              'com.microsoft.emmx',
            ],
          ),
        ),
        safariVCOptions: const SafariViewControllerOptions(
          preferredBarTintColor: Color(0xFF0F141E),
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: true,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
      debugPrint('🔗 [CustomTabs] URL launched successfully in Firefox');
    } catch (e) {
      debugPrint('❌ [CustomTabs] Error launching $url: $e');
    }
  }

  Widget _buildEntry(DetailEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              // Navigate to PDF viewer if PDF page info is available
              if (entry.pdfStartPage != null && entry.pdfEndPage != null) {
                LoggerService().logUserAction(
                  'pdf_entry_clicked',
                  params: {
                    'category': widget.categoryData.title,
                    'entry': entry.highlight,
                    'startPage': entry.pdfStartPage,
                    'endPage': entry.pdfEndPage,
                  },
                );

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PDFViewerScreen(
                      title: entry.highlight,
                      startPage: entry.pdfStartPage!,
                      endPage: entry.pdfEndPage!,
                      description:
                          entry.pdfCategory ?? widget.categoryData.title,
                    ),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.categoryData.themeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: widget.categoryData.themeColor.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.highlight.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: widget.categoryData.themeColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (entry.pdfStartPage != null &&
                      entry.pdfEndPage != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.picture_as_pdf,
                      size: 14,
                      color:
                          widget.categoryData.themeColor.withValues(alpha: 0.7),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entry.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFE0E0E0),
              height: 1.6,
            ),
          ),
          if (entry.bulletPoints != null && entry.bulletPoints!.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...entry.bulletPoints!.map((point) => Padding(
                  padding: const EdgeInsets.only(left: 15, bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8, right: 10),
                        width: 6,
                        height: 6,
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
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFB0B0B0),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
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
