import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../mixins/language_selection_mixin.dart';
import '../models/category_detail_data.dart';
import '../services/service_locator.dart';
import '../utils/platform_adaptive.dart';
import 'sections/explore_section.dart';
import 'sections/ideas_section.dart';
import 'sections/leaderboard_section.dart';
import 'sections/settings_section.dart';
import 'sections/sources_section.dart';
import 'web_state.dart';
import 'web_theme.dart';
import 'widgets/web_background.dart';
import 'widgets/web_sidebar.dart';
import 'widgets/web_topbar.dart';

class NanoSolveWebApp extends StatefulWidget {
  final String? initialCategoryKey;

  const NanoSolveWebApp({super.key, this.initialCategoryKey});

  @override
  State<NanoSolveWebApp> createState() => _NanoSolveWebAppState();
}

class _NanoSolveWebAppState extends State<NanoSolveWebApp>
    with LanguageSelectionMixin<NanoSolveWebApp> {
  WebSection _section = WebSection.explore;
  String _sourcesQuery = '';
  CategoryDetailData? _selectedCategory;
  String? _ideaPrefill;

  bool _sidebarExpanded = true;

  @override
  void initState() {
    super.initState();
    initLanguageSelection();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = CategoryDetailDataFactory.all(l10n);
    final localeLanguage =
        Localizations.localeOf(context).languageCode.toLowerCase();
    final resolvedLanguage =
        settingsManager.storedUserLanguage?.toLowerCase() ?? localeLanguage;

    if (selectedLanguage != resolvedLanguage) {
      selectedLanguage = resolvedLanguage;
    }

    // Select initial category once (prefer initialCategoryKey, else first)
    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = widget.initialCategoryKey != null
          ? categories.firstWhere(
              (c) => c.categoryKey == widget.initialCategoryKey,
              orElse: () => categories.first,
            )
          : categories.first;
    }

    final width = MediaQuery.sizeOf(context).width;
    final compactSidebar = width < 900;
    // Sidebar expand/collapse is always user-controlled via the hamburger button.
    final expandedSidebar = _sidebarExpanded;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          setState(() {
            if (_selectedCategory != null && _section == WebSection.explore) {
              _selectedCategory =
                  categories.isNotEmpty ? categories.first : null;
            }
          });
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: WebTheme.bg,
        body: Column(
          children: [
            // ── Sticky Top Bar ──────────────────────────────────────────
            WebTopBar(
              l10n: l10n,
              section: _section,
              sidebarExpanded: expandedSidebar,
              selectedCategoryTitle: _selectedCategory?.title,
              onToggleSidebar: () =>
                  setState(() => _sidebarExpanded = !_sidebarExpanded),
              onSectionChanged: (s) => setState(() => _section = s),
              onGoHome: () => setState(() {
                _section = WebSection.explore;
                _selectedCategory =
                    categories.isNotEmpty ? categories.first : null;
              }),
              onGoToLanding: () => Navigator.of(context).maybePop(),
            ),
            // ── Main layout: Sidebar + Content ──────────────────────────
            Expanded(
              child: Stack(
                children: [
                  // Subtle background animation
                  const Positioned.fill(
                    child: WebBackground(domain: WebDomain.human),
                  ),
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.neonCyan.withValues(alpha: 0.04),
                            Colors.transparent,
                            AppColors.pastelAqua.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: PlatformAdaptive.contentMaxWidth(
                            context,
                            mobile: 900,
                            tablet: 1280,
                            desktop: 1700,
                          ),
                        ),
                        child: Row(
                          children: [
                            // ── Sidebar ──────────────────────────
                            AnimatedContainer(
                              width: expandedSidebar
                                  ? WebTheme.sidebarExpanded
                                  : WebTheme.sidebarCollapsed,
                              duration: WebTheme.slow,
                              curve: WebTheme.sidebarCurve,
                              child: WebSidebar(
                                l10n: l10n,
                                expanded: expandedSidebar,
                                compactMode: compactSidebar,
                                selectedLanguage: selectedLanguage,
                                categories: categories,
                                selectedCategory: _selectedCategory,
                                onSelectLanguage: selectLanguage,
                                onSelectCategory: (cat) => setState(() {
                                  _selectedCategory = cat;
                                  _section = WebSection.explore;
                                }),
                              ),
                            ),
                            // ── Main Content ────────────────────
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 14, 20, 20),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: DecoratedBox(
                                    decoration: const BoxDecoration(
                                      color: WebTheme.surfacePanel,
                                      border: Border.fromBorderSide(
                                        BorderSide(
                                            color: WebTheme.borderSubtle),
                                      ),
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: WebTheme.normal,
                                      switchInCurve: WebTheme.switchCurve,
                                      switchOutCurve: WebTheme.switchCurve,
                                      child: _buildSection(
                                        l10n: l10n,
                                        categories: categories,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required AppLocalizations l10n,
    required List<CategoryDetailData> categories,
  }) {
    return switch (_section) {
      WebSection.explore => ExploreSection(
          key: const ValueKey('explore-section'),
          l10n: l10n,
          categories: categories,
          selectedCategory: _selectedCategory,
          activeLanguageCode: _activeLanguageCode(),
          onSelectCategory: (category) =>
              setState(() => _selectedCategory = category),
          onClearSelection: () => setState(() {
            _selectedCategory = categories.isNotEmpty ? categories.first : null;
          }),
          onOpenSources: (category) => setState(() {
            _selectedCategory = category;
            _section = WebSection.sources;
          }),
          onPostIdea: (category) => setState(() {
            _selectedCategory = category;
            _section = WebSection.ideas;
          }),
          onSparkIdea: (text) {
            setState(() => _ideaPrefill = text);
            _showSnack(l10n.webWorkspaceFindingAdded);
          },
          onOpenInNewTab: _openSourceInNewPanel,
        ),
      WebSection.sources => SourcesSection(
          key: const ValueKey('sources-section'),
          l10n: l10n,
          categories: categories,
          query: _sourcesQuery,
          onQueryChanged: (value) => setState(() => _sourcesQuery = value),
          activeLanguageCode: _activeLanguageCode(),
          onOpenInNewTab: _openSourceInNewPanel,
        ),
      WebSection.ideas => IdeasSection(
          key: const ValueKey('ideas-section'),
          l10n: l10n,
          categories: categories,
          initialCategory: _selectedCategory,
          initialContext: _ideaPrefill,
        ),
      WebSection.leaderboard => LeaderboardSection(
          key: const ValueKey('leaderboard-section'),
          l10n: l10n,
          onPostIdea: () => setState(() => _section = WebSection.ideas),
        ),
      WebSection.settings => SettingsSection(
          key: const ValueKey('settings-section'),
          l10n: l10n,
          selectedLanguage: selectedLanguage,
          onSelectLanguage: selectLanguage,
        ),
    };
  }

  Future<void> _openSourceInNewPanel(String rawUrl) async {
    final l10n = AppLocalizations.of(context)!;
    final normalized = rawUrl.trim();
    if (normalized.isEmpty) {
      _showSnack(l10n.webWorkspaceInvalidSourceLink);
      return;
    }

    Uri? uri = Uri.tryParse(normalized);
    uri ??= Uri.tryParse(Uri.encodeFull(normalized));
    if (uri == null || !(uri.hasScheme && uri.host.isNotEmpty)) {
      _showSnack(l10n.webWorkspaceInvalidSourceLink);
      return;
    }

    final opened = await PlatformAdaptive.launchExternalUri(uri);
    if (!opened && mounted) {
      _showSnack(l10n.webWorkspaceOpenSourceFailed);
    }
  }

  String _activeLanguageCode() {
    final settingsLang =
        ServiceLocator().settingsManager.userLanguage.toLowerCase();
    const supported = {'en', 'cs', 'es', 'fr', 'ru'};
    if (supported.contains(settingsLang)) {
      return settingsLang;
    }

    final localeLang =
        Localizations.localeOf(context).languageCode.toLowerCase();
    return supported.contains(localeLang) ? localeLang : 'en';
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
