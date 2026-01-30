import 'package:flutter/material.dart';
import 'dart:ui';
import '../config/app_colors.dart';
import '../widgets/nanosolve_logo.dart';
import '../l10n/app_localizations.dart';
import '../models/pdf_source.dart';
import 'pdf_viewer_screen.dart';
import '../services/logger_service.dart';

enum SourceType { webLinks, videoLinks }

class SourcesScreen extends StatefulWidget {
  const SourcesScreen({super.key});

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen> {
  SourceType _selectedTab = SourceType.webLinks;
  bool _isHumanHealthExpanded = false;
  bool _isEarthPollutionExpanded = false;
  bool _isWaterAbilitiesExpanded = false;

  @override
  void initState() {
    super.initState();
    LoggerService().logScreenNavigation('SourcesScreen');
    LoggerService().logFeatureUsage('sources_screen_opened', metadata: {
      'timestamp': DateTime.now().toIso8601String(),
    });
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
              AppColors.pastelAqua.withValues(alpha: 0.05),
              AppColors.pastelLavender.withValues(alpha: 0.05),
              const Color(0xFF0A0A12),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildMainReportCard(),
              _buildTabsNavigation(),
              Expanded(
                child: _selectedTab == SourceType.webLinks
                    ? _buildWebLinksTab()
                    : _buildVideoLinksTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context)!.sourcesBack,
                    style: TextStyle(
                      color: AppColors.pastelAqua,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Icon(
                  Icons.menu_book_outlined,
                  size: 24,
                  color: AppColors.pastelAqua,
                ),
              ],
            ),
            const SizedBox(height: 15),
            const NanosolveLogo(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildMainReportCard() {
    return Container(
      margin: const EdgeInsets.all(25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.pastelAqua.withValues(alpha: 0.1),
            AppColors.pastelMint.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(color: AppColors.pastelAqua),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.pastelAqua.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.sourcesMainReportLabel,
            style: TextStyle(
              color: AppColors.pastelAqua,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.sourcesMainReportTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsNavigation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: AppLocalizations.of(context)!.sourcesTabWeb,
              isActive: _selectedTab == SourceType.webLinks,
              onTap: () {
                setState(() => _selectedTab = SourceType.webLinks);
                LoggerService().logUserAction('sources_tab_switched',
                    params: {'tab': 'web'});
              },
            ),
          ),
          Expanded(
            child: _buildTabButton(
              label: AppLocalizations.of(context)!.sourcesTabVideo,
              isActive: _selectedTab == SourceType.videoLinks,
              onTap: () {
                setState(() => _selectedTab = SourceType.videoLinks);
                LoggerService().logUserAction('sources_tab_switched',
                    params: {'tab': 'video'});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.pastelAqua.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
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
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.pastelAqua : AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildWebLinksTab() {
    final l10n = AppLocalizations.of(context)!;

    // Filter water sources based on current language
    final currentLocale = Localizations.localeOf(context);
    final isCzech = currentLocale.languageCode == 'cs';
    final filteredWaterSources = waterAbilitiesSources.where((source) {
      if (isCzech) {
        return source.title.contains('Czech');
      } else {
        return source.title.contains('English');
      }
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          _buildExpandableSection(
            title: l10n.sourcesSectionHumanHealth,
            icon: Icons.favorite_outline,
            sources: humanHealthSources,
            isExpanded: _isHumanHealthExpanded,
            onTap: () => setState(
                () => _isHumanHealthExpanded = !_isHumanHealthExpanded),
          ),
          const SizedBox(height: 12),
          _buildExpandableSection(
            title: l10n.sourcesSectionEarthPollution,
            icon: Icons.public,
            sources: earthPollutionSources,
            isExpanded: _isEarthPollutionExpanded,
            onTap: () => setState(
                () => _isEarthPollutionExpanded = !_isEarthPollutionExpanded),
          ),
          const SizedBox(height: 12),
          _buildExpandableSection(
            title: l10n.sourcesSectionWaterAbilities,
            icon: Icons.water_drop_outlined,
            sources: filteredWaterSources,
            isExpanded: _isWaterAbilitiesExpanded,
            onTap: () => setState(
                () => _isWaterAbilitiesExpanded = !_isWaterAbilitiesExpanded),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildVideoLinksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF141928).withValues(alpha: 0.85),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 48,
                  color: AppColors.pastelMint.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.sourcesSectionVideoContent,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required List<PDFSource> sources,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.85),
        border: Border.all(
          color: isExpanded
              ? AppColors.pastelAqua.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header (always visible)
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.pastelMint.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: AppColors.pastelMint,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${sources.length} resources',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.pastelAqua,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: sources.asMap().entries.map((entry) {
                  return _buildPDFLinkCard(
                    number: entry.key + 1,
                    source: entry.value,
                  );
                }).toList(),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildPDFLinkCard({
    required int number,
    required PDFSource source,
  }) {
    return GestureDetector(
      onTap: () {
        LoggerService().logUserAction('pdf_source_clicked', params: {
          'source': source.title,
          'startPage': source.startPage,
          'endPage': source.endPage,
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PDFViewerScreen(
              title: source.title,
              startPage: source.startPage,
              endPage: source.endPage,
              description: source.description,
              pdfAssetPath: source.pdfAssetPath,
            ),
          ),
        );
      },
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
                    source.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    source.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.pastelLavender,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pastelAqua.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.pastelAqua.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Pages ${source.startPage}-${source.endPage}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.pastelAqua,
                        fontWeight: FontWeight.w700,
                      ),
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
                  Icons.picture_as_pdf,
                  size: 20,
                  color: AppColors.pastelAqua.withValues(alpha: 0.8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
