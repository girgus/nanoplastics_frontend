import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/category_detail_data.dart';
import '../web_theme.dart';
import '../widgets/category_showcase_card.dart';

class ExploreSection extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isHumanDomain;
  final List<CategoryDetailData> categories;
  final CategoryDetailData? selectedCategory;
  final String activeLanguageCode;
  final ValueChanged<CategoryDetailData> onSelectCategory;
  final VoidCallback onClearSelection;
  final ValueChanged<CategoryDetailData> onOpenSources;
  final ValueChanged<CategoryDetailData> onPostIdea;
  final Future<void> Function(String url) onOpenInNewTab;

  const ExploreSection({
    super.key,
    required this.l10n,
    required this.isHumanDomain,
    required this.categories,
    required this.selectedCategory,
    required this.activeLanguageCode,
    required this.onSelectCategory,
    required this.onClearSelection,
    required this.onOpenSources,
    required this.onPostIdea,
    required this.onOpenInNewTab,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCategory == null) {
      return _buildShowcase(context);
    }

    return Row(
      children: [
        SizedBox(
          width: 220,
          child: _CategoryList(
            categories: categories,
            selectedCategory: selectedCategory!,
            onSelectCategory: onSelectCategory,
            onClearSelection: onClearSelection,
            allDomainsLabel: l10n.exploreAllDomains,
          ),
        ),
        Expanded(
          child: _CategoryPanel(
            data: selectedCategory!,
            activeLanguageCode: activeLanguageCode,
            onGoToSources: () => onOpenSources(selectedCategory!),
            onPostIdea: () => onPostIdea(selectedCategory!),
            onOpenInNewTab: onOpenInNewTab,
            sourcesLabel: l10n.navSources,
            ideasLabel: l10n.ideasTitle,
          ),
        ),
      ],
    );
  }

  Widget _buildShowcase(BuildContext context) {
    final subtitle =
        isHumanDomain ? l10n.exploreHumanTitle : l10n.explorePlanetTitle;
    final description =
        isHumanDomain ? l10n.exploreHumanDesc : l10n.explorePlanetDesc;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(32, 36, 32, 28),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.exploreResearchDomains,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 310,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.42,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                return CategoryShowcaseCard(
                  category: category,
                  index: index,
                  ctaLabel: l10n.exploreCardCta,
                  onTap: () => onSelectCategory(category),
                );
              },
              childCount: categories.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<CategoryDetailData> categories;
  final CategoryDetailData selectedCategory;
  final ValueChanged<CategoryDetailData> onSelectCategory;
  final VoidCallback onClearSelection;
  final String allDomainsLabel;

  const _CategoryList({
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.onClearSelection,
    required this.allDomainsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onClearSelection,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.arrow_back,
                      size: 13, color: Colors.white.withValues(alpha: 0.7)),
                  const SizedBox(width: 8),
                  Text(
                    allDomainsLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final cat = categories[i];
                final active = cat.categoryKey == selectedCategory.categoryKey;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: InkWell(
                    onTap: () => onSelectCategory(cat),
                    borderRadius: BorderRadius.circular(WebTheme.itemRadius),
                    child: AnimatedContainer(
                      duration: WebTheme.fast,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 9),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(WebTheme.itemRadius),
                        color: active
                            ? cat.themeColor.withValues(alpha: 0.14)
                            : Colors.transparent,
                        border: Border.all(
                          color: active
                              ? cat.themeColor.withValues(alpha: 0.45)
                              : Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(cat.icon, color: cat.themeColor, size: 17),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              cat.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: active
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.65),
                                fontWeight:
                                    active ? FontWeight.w700 : FontWeight.w400,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPanel extends StatelessWidget {
  final CategoryDetailData data;
  final String activeLanguageCode;
  final VoidCallback onGoToSources;
  final VoidCallback onPostIdea;
  final Future<void> Function(String url) onOpenInNewTab;
  final String sourcesLabel;
  final String ideasLabel;

  const _CategoryPanel({
    required this.data,
    required this.activeLanguageCode,
    required this.onGoToSources,
    required this.onPostIdea,
    required this.onOpenInNewTab,
    required this.sourcesLabel,
    required this.ideasLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: data.themeColor.withValues(alpha: 0.18),
                    border: Border.all(
                        color: data.themeColor.withValues(alpha: 0.5)),
                  ),
                  child: Icon(data.icon, color: data.themeColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.subtitle,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: onPostIdea,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: Text(ideasLabel),
                ),
                OutlinedButton.icon(
                  onPressed: onGoToSources,
                  icon: const Icon(Icons.menu_book_outlined),
                  label: Text('$sourcesLabel (${data.evidenceStudyCount})'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...data.entries.take(8).map(
                  (e) => _EvidenceEntry(
                    entry: e,
                    color: data.themeColor,
                    onOpenPdf: () async {
                      final url = _buildAllatraPageUrl(
                        languageCode: activeLanguageCode,
                        page: e.pdfStartPage,
                      );
                      if (url != null) {
                        await onOpenInNewTab(url);
                      }
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  String? _buildAllatraPageUrl({
    required String languageCode,
    required int? page,
  }) {
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

    final base = baseUrls[languageCode.toLowerCase()] ?? baseUrls['en']!;
    return '$base#page=$page';
  }
}

class _EvidenceEntry extends StatefulWidget {
  final DetailEntry entry;
  final Color color;
  final Future<void> Function()? onOpenPdf;

  const _EvidenceEntry({
    required this.entry,
    required this.color,
    this.onOpenPdf,
  });

  @override
  State<_EvidenceEntry> createState() => _EvidenceEntryState();
}

class _EvidenceEntryState extends State<_EvidenceEntry> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final canOpen =
        widget.entry.pdfStartPage != null && widget.entry.pdfStartPage! > 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: canOpen ? widget.onOpenPdf : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: canOpen
                  ? widget.color.withValues(alpha: _hovered ? 0.32 : 0.22)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.entry.highlight,
                      style: TextStyle(
                          color: widget.color, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (canOpen)
                    Tooltip(
                      message: 'Open on page ${widget.entry.pdfStartPage}',
                      child: IconButton(
                        onPressed: widget.onOpenPdf,
                        icon: Icon(Icons.picture_as_pdf_outlined,
                            size: 14,
                            color: widget.color.withValues(alpha: 0.7)),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.entry.description,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
