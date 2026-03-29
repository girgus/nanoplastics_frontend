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
import 'sections/sources_section.dart';
import 'web_state.dart';
import 'web_theme.dart';
import 'widgets/ai_chat_panel.dart';
import 'widgets/web_background.dart';
import 'widgets/web_sidebar.dart';
import 'widgets/web_topbar.dart';

class NanoSolveWebApp extends StatefulWidget {
  const NanoSolveWebApp({super.key});

  @override
  State<NanoSolveWebApp> createState() => _NanoSolveWebAppState();
}

class _NanoSolveWebAppState extends State<NanoSolveWebApp>
    with LanguageSelectionMixin<NanoSolveWebApp> {
  WebSection _section = WebSection.explore;
  WebDomain _domain = WebDomain.human;
  String _sourcesQuery = '';
  CategoryDetailData? _selectedCategory;

  bool _isChatOpen = false;
  double _chatPanelHeight = WebTheme.chatPanelHeightDefault;
  bool _isSidebarHovered = false;

  @override
  void initState() {
    super.initState();
    initLanguageSelection();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = CategoryDetailDataFactory.all(l10n);
    final domainCategories = categories
        .where((c) => _domain == WebDomain.human
            ? c.categoryKey.startsWith('human_')
            : c.categoryKey.startsWith('planet_'))
        .toList(growable: false);

    if (_selectedCategory != null &&
        !domainCategories
            .any((c) => c.categoryKey == _selectedCategory!.categoryKey)) {
      _selectedCategory = null;
    }

    final width = MediaQuery.sizeOf(context).width;
    final compactSidebar = width < 1200;
    final expandedSidebar = compactSidebar ? false : _isSidebarHovered;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        if (event.logicalKey == LogicalKeyboardKey.escape) {
          setState(() {
            if (_isChatOpen) {
              _isChatOpen = false;
            } else if (_selectedCategory != null &&
                _section == WebSection.explore) {
              _selectedCategory = null;
            }
          });
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: WebBackground(domain: _domain)),
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _domainAccent.withValues(alpha: 0.07),
                      Colors.transparent,
                      _domainAccentSoft.withValues(alpha: 0.04),
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
                      MouseRegion(
                        onEnter: (_) =>
                            setState(() => _isSidebarHovered = true),
                        onExit: (_) =>
                            setState(() => _isSidebarHovered = false),
                        child: AnimatedContainer(
                          width: expandedSidebar
                              ? WebTheme.sidebarExpanded
                              : WebTheme.sidebarCollapsed,
                          duration: WebTheme.slow,
                          curve: WebTheme.sidebarCurve,
                          child: WebSidebar(
                            l10n: l10n,
                            expanded: expandedSidebar,
                            compactMode: compactSidebar,
                            domain: _domain,
                            section: _section,
                            isChatOpen: _isChatOpen,
                            selectedLanguage: selectedLanguage,
                            onDomainChanged: _setDomain,
                            onSectionChanged: (section) =>
                                setState(() => _section = section),
                            onGoHome: () => setState(() {
                              _section = WebSection.explore;
                              _selectedCategory = null;
                            }),
                            onToggleChat: () =>
                                setState(() => _isChatOpen = !_isChatOpen),
                            onSelectLanguage: selectLanguage,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 14, 20, 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: WebTheme.surfacePanel(context),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Column(
                                children: [
                                  WebTopBar(
                                    l10n: l10n,
                                    section: _section,
                                    domain: _domain,
                                    selectedCategoryTitle:
                                        _selectedCategory?.title,
                                    onDomainChanged: _setDomain,
                                  ),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        AnimatedSwitcher(
                                          duration: WebTheme.normal,
                                          switchInCurve: WebTheme.switchCurve,
                                          switchOutCurve: WebTheme.switchCurve,
                                          child: _buildSection(
                                            l10n: l10n,
                                            domainCategories: domainCategories,
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: _ChatResizableContainer(
                                            isOpen: _isChatOpen,
                                            height: _chatPanelHeight,
                                            onResize: (delta) {
                                              final viewportH =
                                                  MediaQuery.sizeOf(context)
                                                      .height;
                                              final maxHeight = viewportH * 0.8;
                                              setState(() {
                                                _chatPanelHeight =
                                                    (_chatPanelHeight + delta)
                                                        .clamp(
                                                  WebTheme.chatPanelHeightMin,
                                                  maxHeight,
                                                );
                                              });
                                            },
                                            child: AiChatPanel(
                                              l10n: l10n,
                                              onClose: () => setState(
                                                  () => _isChatOpen = false),
                                              onMinimize: () => setState(
                                                  () => _isChatOpen = false),
                                              onOpenLibrary: () {
                                                setState(() {
                                                  _section = WebSection.sources;
                                                  _isChatOpen = false;
                                                });
                                              },
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
    );
  }

  Widget _buildSection({
    required AppLocalizations l10n,
    required List<CategoryDetailData> domainCategories,
  }) {
    return switch (_section) {
      WebSection.explore => ExploreSection(
          key: const ValueKey('explore-section'),
          l10n: l10n,
          isHumanDomain: _domain == WebDomain.human,
          categories: domainCategories,
          selectedCategory: _selectedCategory,
          activeLanguageCode: _activeLanguageCode(),
          onSelectCategory: (category) =>
              setState(() => _selectedCategory = category),
          onClearSelection: () => setState(() => _selectedCategory = null),
          onOpenSources: (category) => setState(() {
            _selectedCategory = category;
            _section = WebSection.sources;
          }),
          onPostIdea: (category) => setState(() {
            _selectedCategory = category;
            _section = WebSection.ideas;
          }),
          onOpenInNewTab: _openSourceInNewPanel,
        ),
      WebSection.sources => SourcesSection(
          key: const ValueKey('sources-section'),
          l10n: l10n,
          domain: _domain,
          categories: domainCategories,
          query: _sourcesQuery,
          onQueryChanged: (value) => setState(() => _sourcesQuery = value),
          activeLanguageCode: _activeLanguageCode(),
          onOpenInNewTab: _openSourceInNewPanel,
        ),
      WebSection.ideas => IdeasSection(
          key: const ValueKey('ideas-section'),
          l10n: l10n,
          categories: domainCategories,
          initialCategory: _selectedCategory,
        ),
      WebSection.leaderboard => LeaderboardSection(
          key: const ValueKey('leaderboard-section'),
          l10n: l10n,
          onPostIdea: () => setState(() => _section = WebSection.ideas),
        ),
    };
  }

  Future<void> _openSourceInNewPanel(String rawUrl) async {
    final normalized = rawUrl.trim();
    if (normalized.isEmpty) {
      _showSnack('Invalid source link.');
      return;
    }

    Uri? uri = Uri.tryParse(normalized);
    uri ??= Uri.tryParse(Uri.encodeFull(normalized));
    if (uri == null || !(uri.hasScheme && uri.host.isNotEmpty)) {
      _showSnack('Invalid source link.');
      return;
    }

    final opened = await PlatformAdaptive.launchExternalUri(uri);
    if (!opened && mounted) {
      _showSnack('Could not open source link in a new tab.');
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

  void _setDomain(WebDomain domain) {
    setState(() {
      _domain = domain;
      _selectedCategory = null;
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Color get _domainAccent =>
      _domain == WebDomain.human ? AppColors.neonCyan : AppColors.neonOcean;

  Color get _domainAccentSoft =>
      _domain == WebDomain.human ? AppColors.pastelAqua : AppColors.pastelMint;
}

class _ChatResizableContainer extends StatelessWidget {
  final bool isOpen;
  final double height;
  final Widget child;
  final ValueChanged<double> onResize;

  const _ChatResizableContainer({
    required this.isOpen,
    required this.height,
    required this.child,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: isOpen ? height : 0,
      duration: WebTheme.slow,
      curve: WebTheme.chatCurve,
      child: isOpen
          ? Column(
              children: [
                GestureDetector(
                  onVerticalDragUpdate: (d) => onResize(-d.delta.dy),
                  child: Container(
                    height: 6,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                Expanded(child: child),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
