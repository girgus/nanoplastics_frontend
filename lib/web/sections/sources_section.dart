import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/category_detail_data.dart';
import '../../models/pdf_source.dart';
import '../web_state.dart';
import '../web_theme.dart';

class SourcesSection extends StatefulWidget {
  final AppLocalizations l10n;
  final WebDomain domain;
  final List<CategoryDetailData> categories;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final String activeLanguageCode;
  final Future<void> Function(String url) onOpenInNewTab;

  const SourcesSection({
    super.key,
    required this.l10n,
    required this.domain,
    required this.categories,
    required this.query,
    required this.onQueryChanged,
    required this.activeLanguageCode,
    required this.onOpenInNewTab,
  });

  @override
  State<SourcesSection> createState() => _SourcesSectionState();
}

class _SourcesSectionState extends State<SourcesSection> {
  final Set<String> _collapsedCategoryKeys = <String>{};
  final TextEditingController _searchController = TextEditingController();

  @override
  void didUpdateWidget(covariant SourcesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_searchController.text != widget.query) {
      _searchController.text = widget.query;
      _searchController.selection = TextSelection.collapsed(
        offset: _searchController.text.length,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.query.trim().toLowerCase();
    final categoryBlocks = widget.categories.map((category) {
      final allatraSources = _allatraSourcesForCategory(category);
      return (category: category, allatraSources: allatraSources);
    }).where((block) {
      if (query.isEmpty) return true;

      final category = block.category;
      if (category.title.toLowerCase().contains(query) ||
          category.subtitle.toLowerCase().contains(query)) {
        return true;
      }

      for (final section in category.evidenceSections) {
        if (section.title.toLowerCase().contains(query)) {
          return true;
        }
        for (final study in section.studies) {
          if (study.title.toLowerCase().contains(query) ||
              study.journal.toLowerCase().contains(query) ||
              study.year.toString().contains(query) ||
              study.authorsShort.toLowerCase().contains(query)) {
            return true;
          }
        }
      }

      for (final source in block.allatraSources) {
        if (source.title.toLowerCase().contains(query) ||
            source.description.toLowerCase().contains(query) ||
            source.getPageRangeDisplay().toLowerCase().contains(query)) {
          return true;
        }
      }

      return false;
    }).toList(growable: false);

    int totalResults = 0;
    for (final block in categoryBlocks) {
      totalResults +=
          block.category.evidenceStudyCount + block.allatraSources.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 6),
          child: Text(
            widget.l10n.sourcesLibraryTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
          child: Text(
            widget.l10n.sourcesLibrarySubtitle(
              widget.domain.isHuman
                  ? widget.l10n.tabHuman
                  : widget.l10n.tabPlanet,
            ),
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.74), fontSize: 12),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
          child: Text(
            widget.l10n.sourcesDescription(totalResults),
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.60), fontSize: 12),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
          child: TextField(
            controller: _searchController,
            onChanged: widget.onQueryChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: widget.l10n.sourcesSearchPlaceholder,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: widget.query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        widget.onQueryChanged('');
                      },
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
          child: Text(
            widget.l10n.sourcesCountBadge(totalResults),
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55), fontSize: 11),
          ),
        ),
        Expanded(
          child: categoryBlocks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.l10n.sourcesNoResults(widget.query),
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72)),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          widget.onQueryChanged('');
                        },
                        child: Text(widget.l10n.sourcesClearSearch),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: categoryBlocks.length,
                  itemBuilder: (_, i) {
                    final category = categoryBlocks[i].category;
                    final allatraSources = categoryBlocks[i].allatraSources;
                    final collapsed =
                        _collapsedCategoryKeys.contains(category.categoryKey);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: WebTheme.surfaceCard(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (collapsed) {
                                  _collapsedCategoryKeys
                                      .remove(category.categoryKey);
                                } else {
                                  _collapsedCategoryKeys
                                      .add(category.categoryKey);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  AnimatedRotation(
                                    duration: WebTheme.normal,
                                    turns: collapsed ? 0.0 : 0.5,
                                    child: Icon(
                                      Icons.expand_more,
                                      color: category.themeColor,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(category.icon,
                                      color: category.themeColor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      category.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    widget.l10n.sourcesCountBadge(
                                      category.evidenceStudyCount +
                                          allatraSources.length,
                                    ),
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.65),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!collapsed)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...category.evidenceSections.map((section) {
                                    final headlineUrl =
                                        _headlinePdfUrlForSection(
                                      category: category,
                                      section: section,
                                      allatraSources: allatraSources,
                                    );

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: headlineUrl == null
                                                ? null
                                                : () => widget.onOpenInNewTab(
                                                    headlineUrl),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: category.themeColor
                                                    .withValues(alpha: 0.08),
                                                border: Border(
                                                  left: BorderSide(
                                                      color:
                                                          category.themeColor,
                                                      width: 3),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${widget.l10n.sourcesHeadlineLabel}: ${section.title}',
                                                      style: TextStyle(
                                                        color:
                                                            category.themeColor,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                  if (headlineUrl != null)
                                                    Icon(
                                                      Icons
                                                          .picture_as_pdf_outlined,
                                                      size: 15,
                                                      color: category.themeColor
                                                          .withValues(
                                                              alpha: 0.9),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            widget.l10n.sourcesStudiesLabel,
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.65),
                                              fontSize: 11,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          ...section.studies.map((study) =>
                                              InkWell(
                                                onTap: () => widget
                                                    .onOpenInNewTab(study.url),
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 6),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 9),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.08)),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '${study.authorsShort} (${study.year}) — ${study.journal}',
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: Colors.white
                                                                .withValues(
                                                                    alpha:
                                                                        0.84),
                                                            fontFamily:
                                                                'monospace',
                                                            fontSize: 12.5,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Tooltip(
                                                        message: widget.l10n
                                                            .sourcesOpenInNewTab,
                                                        child: IconButton(
                                                          onPressed: () => widget
                                                              .onOpenInNewTab(
                                                                  study.url),
                                                          icon: const Icon(
                                                              Icons.open_in_new,
                                                              size: 16),
                                                          color: AppColors
                                                              .pastelAqua,
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )),
                                        ],
                                      ),
                                    );
                                  }),
                                  if (allatraSources.isNotEmpty) ...[
                                    Text(
                                      widget.l10n.sourcesAllatraLabel,
                                      style: TextStyle(
                                        color: category.themeColor,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...allatraSources.map((source) => InkWell(
                                          onTap: () => widget
                                              .onOpenInNewTab(source.url!),
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 6),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 9),
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.08)),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${source.title} — ${source.getPageRangeDisplay()}',
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Tooltip(
                                                  message: widget
                                                      .l10n.sourcesOpenInNewTab,
                                                  child: IconButton(
                                                    onPressed: () =>
                                                        widget.onOpenInNewTab(
                                                            source.url!),
                                                    icon: const Icon(
                                                        Icons.open_in_new,
                                                        size: 16),
                                                    color: AppColors.pastelMint,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<PDFSource> _allatraSourcesForCategory(CategoryDetailData category) {
    final categoryPool = [
      if (widget.domain.isHuman) ...humanHealthSources,
      if (!widget.domain.isHuman) ...earthPollutionSources,
      if (!widget.domain.isHuman) ...waterAbilitiesSources,
    ]
        .where((s) =>
            s.language == widget.activeLanguageCode &&
            s.url != null &&
            s.url!.isNotEmpty)
        .toList();

    final globalReports = earthPollutionSources
        .where((s) =>
            s.language == widget.activeLanguageCode &&
            s.url != null &&
            s.url!.isNotEmpty)
        .where(_isFullAllatraReport)
        .toList(growable: false);

    final keywords = _categoryKeywords(category.categoryKey);
    final matched = categoryPool.where((source) {
      final haystack = '${source.title} ${source.description}'.toLowerCase();
      return keywords.any(haystack.contains);
    }).toList(growable: false);

    final unique = <String>{};
    final ordered = <PDFSource>[];
    for (final source in [...globalReports, ...matched]) {
      final id = '${source.title}|${source.url}';
      if (unique.add(id)) ordered.add(source);
    }
    return ordered;
  }

  bool _isFullAllatraReport(PDFSource source) {
    final text = '${source.title} ${source.description}'.toLowerCase();
    return source.endPage == PDFSource.endPageSentinel ||
        text.contains('report') ||
        text.contains('zpráva') ||
        text.contains('raport') ||
        text.contains('отч') ||
        text.contains('informe');
  }

  List<String> _categoryKeywords(String categoryKey) {
    switch (categoryKey) {
      case 'human_central':
        return ['central', 'centrální', 'centrales', 'централь', 'cerveau'];
      case 'human_detox':
        return ['filtration', 'detox', 'filtrace', 'détox', 'детокс'];
      case 'human_vitality':
        return ['vitality', 'tissues', 'vitalita', 'vitalité', 'tkan'];
      case 'human_reproduction':
        return ['reproduction', 'vývoj', 'fertility', 'fœtus', 'развит'];
      case 'human_entry':
        return ['entry gates', 'vstupní brány', 'portes d\'entrée', 'вход'];
      case 'human_ways_of_destruction':
        return [
          'physical attack',
          'fyzický útok',
          'attaque physique',
          'физичес'
        ];
      case 'planet_ocean':
        return ['world ocean', 'océan mondial', 'oceán', 'мировой океан'];
      case 'planet_atmosphere':
        return ['atmosphere', 'atmosféra', 'atmosphère', 'атмосфера'];
      case 'planet_bio':
        return ['flora', 'fauna', 'biota', 'flore', 'флора'];
      case 'planet_magnetic':
        return [
          'magnetic field',
          'magnetické pole',
          'champ magnétique',
          'магнит'
        ];
      case 'planet_entry':
        return ['entry', 'source', 'zdroj', 'porte', 'источ'];
      case 'planet_physical':
        return [
          'physical properties',
          'fyzické',
          'propriétés physiques',
          'физические'
        ];
      default:
        return const [];
    }
  }

  String? _headlinePdfUrlForSection({
    required CategoryDetailData category,
    required EvidenceSection section,
    required List<PDFSource> allatraSources,
  }) {
    final pageFromEntry = _pageForSectionHeadline(category, section.title);
    final exactPageUrl = _buildAllatraPageUrl(pageFromEntry);
    if (exactPageUrl != null) return exactPageUrl;

    final sectionTokens = _normalizeHeadline(section.title)
        .split(' ')
        .where((w) => w.length > 3)
        .toSet();

    final ranked = allatraSources
        .where((s) => !_isFullAllatraReport(s))
        .map((s) {
          final haystack = _normalizeHeadline('${s.title} ${s.description}');
          final score = sectionTokens.where(haystack.contains).length;
          return (source: s, score: score);
        })
        .where((it) => it.score > 0)
        .toList(growable: false)
      ..sort((a, b) => b.score.compareTo(a.score));

    if (ranked.isNotEmpty) {
      final directUrl = ranked.first.source.url;
      if (directUrl != null && directUrl.isNotEmpty) return directUrl;
    }

    return null;
  }

  int? _pageForSectionHeadline(
      CategoryDetailData category, String sectionTitle) {
    final normalizedSection = _normalizeHeadline(sectionTitle);
    if (normalizedSection.isEmpty) return null;

    final exact = category.entries.where((e) {
      final h = _normalizeHeadline(e.highlight);
      return h == normalizedSection;
    });
    for (final entry in exact) {
      if (entry.pdfStartPage != null && entry.pdfStartPage! > 0) {
        return entry.pdfStartPage;
      }
    }

    final partial = category.entries.where((e) {
      final h = _normalizeHeadline(e.highlight);
      return h.contains(normalizedSection) || normalizedSection.contains(h);
    });
    for (final entry in partial) {
      if (entry.pdfStartPage != null && entry.pdfStartPage! > 0) {
        return entry.pdfStartPage;
      }
    }

    return null;
  }

  String _normalizeHeadline(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? _buildAllatraPageUrl(int? page) {
    if (page == null || page <= 0) return null;

    const baseUrls = <String, String>{
      'en':
          'https://allatra.org/storage/app/media/reports/en/Nanoplastics_in_the_Biosphere_Report.pdf',
      'cs':
          'https://allatra.org/storage/app/media/reports/cs/Nanoplastics_in_the_Biosphere_Report_CS.pdf',
      'es':
          'https://allatra.org/storage/app/media/reports/es/Nanoplasticos_en_la_Biosfera_Informe_ES.pdf',
      'fr':
          'https://allatra.org/storage/app/media/reports/fr/Nanoplastics_in_the_Biosphere_Report_FR.pdf',
      'ru':
          'https://allatra.org/storage/app/media/reports/ru/Nanoplastics_in_the_Biosphere_Report_RU.pdf',
    };

    final base =
        baseUrls[widget.activeLanguageCode.toLowerCase()] ?? baseUrls['en']!;
    return '$base#page=$page';
  }
}
