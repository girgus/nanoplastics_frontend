import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/category_detail_data.dart';
import '../web_theme.dart';

class CategoryDetailView extends StatefulWidget {
  final CategoryDetailData data;
  final AppLocalizations l10n;
  final Future<void> Function(String url) onOpenInNewTab;
  final VoidCallback onPostIdea;
  final VoidCallback onGoToSources;
  final ValueChanged<String> onSparkIdea;

  const CategoryDetailView({
    super.key,
    required this.data,
    required this.l10n,
    required this.onOpenInNewTab,
    required this.onPostIdea,
    required this.onGoToSources,
    required this.onSparkIdea,
  });

  @override
  State<CategoryDetailView> createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends State<CategoryDetailView> {
  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return CustomScrollView(
      slivers: [
        // ── Hero ──────────────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
          sliver: SliverToBoxAdapter(
            child: _HeroSection(data: data),
          ),
        ),

        // ── Latest Discoveries carousel ────────────────────────────────────
        if (data.allEvidenceStudies.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            sliver: SliverToBoxAdapter(
              child: _DiscoveriesCarousel(
                studies: data.allEvidenceStudies,
                themeColor: data.themeColor,
                onOpenInNewTab: widget.onOpenInNewTab,
              ),
            ),
          ),

        const SliverPadding(padding: EdgeInsets.only(top: 14)),

        // ── Evidence by topic ─────────────────────────────────────────────
        if (data.evidenceSections.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            sliver: SliverToBoxAdapter(
              child: _EvidenceSections(
                key: ValueKey(data.categoryKey),
                sections: data.evidenceSections,
                themeColor: data.themeColor,
                onOpenInNewTab: widget.onOpenInNewTab,
                onSparkIdea: widget.onSparkIdea,
              ),
            ),
          ),

        const SliverPadding(padding: EdgeInsets.only(top: 14)),

        // ── Join the effort CTA ───────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
          sliver: SliverToBoxAdapter(
            child: _CollaborateCTA(
              onPostIdea: widget.onPostIdea,
              onGoToSources: widget.onGoToSources,
              onSparkIdea: widget.onSparkIdea,
              studyCount: data.evidenceStudyCount,
            ),
          ),
        ),

        const SliverSafeArea(
          sliver: SliverToBoxAdapter(child: SizedBox(height: 32)),
        ),
      ],
    );
  }
}

// ── Hero Section ──────────────────────────────────────────────────────────────
// Large icon + title + subtitle + study count and year range pills.
class _HeroSection extends StatelessWidget {
  final CategoryDetailData data;
  const _HeroSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final studies = data.allEvidenceStudies;
    String yearLabel = '';
    if (studies.isNotEmpty) {
      final years = studies.map((s) => s.year).where((y) => y > 0).toList();
      if (years.isNotEmpty) {
        final minYear = years.reduce(min);
        final maxYear = years.reduce(max);
        yearLabel = minYear == maxYear ? '$maxYear' : '$minYear–$maxYear';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            data.themeColor.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
        border: Border.all(color: data.themeColor.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(WebTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: data.themeColor.withValues(alpha: 0.14),
                  border: Border.all(
                      color: data.themeColor.withValues(alpha: 0.28)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.themeColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        color: WebTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.subtitle,
                      style: const TextStyle(
                        color: WebTheme.textSecondary,
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MetaPill(label: '${data.evidenceStudyCount} studies'),
              if (yearLabel.isNotEmpty) _MetaPill(label: yearLabel),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Discoveries Carousel ──────────────────────────────────────────────────────
// Horizontal scrollable row showing the 5 most recent research papers.
class _DiscoveriesCarousel extends StatelessWidget {
  final List<EvidenceStudy> studies;
  final Color themeColor;
  final Future<void> Function(String url) onOpenInNewTab;

  const _DiscoveriesCarousel({
    required this.studies,
    required this.themeColor,
    required this.onOpenInNewTab,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = studies.where((s) => s.year > 0).toList()
      ..sort((a, b) => b.year.compareTo(a.year));
    final visible = sorted.take(5).toList();

    return _SectionBlock(
      title: 'LATEST DISCOVERIES',
      count: 0,
      showCount: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: visible
                  .map((s) => _StudyCard(
                        study: s,
                        themeColor: themeColor,
                        onTap: () => onOpenInNewTab(s.url),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Study Card (used in carousel) ─────────────────────────────────────────────
class _StudyCard extends StatefulWidget {
  final EvidenceStudy study;
  final Color themeColor;
  final VoidCallback onTap;

  const _StudyCard({
    required this.study,
    required this.themeColor,
    required this.onTap,
  });

  @override
  State<_StudyCard> createState() => _StudyCardState();
}

class _StudyCardState extends State<_StudyCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(WebTheme.itemRadius),
          child: AnimatedContainer(
            duration: WebTheme.fast,
            width: 220,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _hovered
                  ? WebTheme.surfacePanel
                  : WebTheme.bg.withValues(alpha: 0.6),
              border: Border.all(
                color: _hovered
                    ? widget.themeColor.withValues(alpha: 0.35)
                    : WebTheme.borderSubtle,
              ),
              borderRadius: BorderRadius.circular(WebTheme.itemRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _YearBadge(
                        year: widget.study.year, color: widget.themeColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.study.studyType ?? 'Study',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: WebTheme.textMuted,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const Icon(Icons.open_in_new,
                        size: 12, color: WebTheme.textMuted),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.study.journal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: WebTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.study.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: WebTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Year Badge ────────────────────────────────────────────────────────────────
class _YearBadge extends StatelessWidget {
  final int year;
  final Color color;
  const _YearBadge({required this.year, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        year.toString(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Evidence Sections ─────────────────────────────────────────────────────────
// Groups studies by topic (EvidenceSection), each collapsible.
class _EvidenceSections extends StatelessWidget {
  final List<EvidenceSection> sections;
  final Color themeColor;
  final Future<void> Function(String url) onOpenInNewTab;
  final ValueChanged<String> onSparkIdea;

  const _EvidenceSections({
    super.key,
    required this.sections,
    required this.themeColor,
    required this.onOpenInNewTab,
    required this.onSparkIdea,
  });

  @override
  Widget build(BuildContext context) {
    final totalStudies =
        sections.fold(0, (sum, s) => sum + s.studies.length);

    return _SectionBlock(
      title: 'EVIDENCE BY TOPIC',
      count: totalStudies,
      children: sections
          .map((s) => _EvidenceSectionBlock(
                section: s,
                themeColor: themeColor,
                onOpenInNewTab: onOpenInNewTab,
                onSparkIdea: onSparkIdea,
              ))
          .toList(),
    );
  }
}

// ── Evidence Section Block ────────────────────────────────────────────────────
// One collapsible topic block inside the evidence panel.
class _EvidenceSectionBlock extends StatefulWidget {
  final EvidenceSection section;
  final Color themeColor;
  final Future<void> Function(String url) onOpenInNewTab;
  final ValueChanged<String> onSparkIdea;

  const _EvidenceSectionBlock({
    required this.section,
    required this.themeColor,
    required this.onOpenInNewTab,
    required this.onSparkIdea,
  });

  @override
  State<_EvidenceSectionBlock> createState() => _EvidenceSectionBlockState();
}

class _EvidenceSectionBlockState extends State<_EvidenceSectionBlock> {
  bool _expanded = false;
  bool _showAll = false;
  static const _previewCount = 3;

  @override
  Widget build(BuildContext context) {
    final studies = widget.section.studies;
    final visible =
        _showAll ? studies : studies.take(_previewCount).toList();
    final hasMore = studies.length > _previewCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Collapsible header
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedContainer(
            duration: WebTheme.fast,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color:
                  _expanded ? WebTheme.surfacePanel : Colors.transparent,
              border: const Border(
                  top: BorderSide(color: WebTheme.borderSubtle)),
            ),
            child: Row(
              children: [
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: widget.themeColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.section.title,
                    style: const TextStyle(
                      color: WebTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${studies.length}',
                  style: const TextStyle(
                    color: WebTheme.textMuted,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),

        // Description (when expanded)
        if (_expanded && widget.section.description != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(38, 4, 14, 4),
            child: Text(
              widget.section.description!,
              style: const TextStyle(
                color: WebTheme.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),

        // Study rows (when expanded)
        if (_expanded) ...[
          ...visible.asMap().entries.map(
                (e) => _FindingRow(
                  number: (e.key + 1).toString().padLeft(2, '0'),
                  text: e.value.title,
                  tag: e.value.studyType ?? 'Study',
                  color: widget.themeColor,
                  onSpark: () => widget.onSparkIdea(e.value.title),
                  onOpenSource: e.value.url.isNotEmpty
                      ? () => widget.onOpenInNewTab(e.value.url)
                      : null,
                ),
              ),
          if (hasMore)
            _ShowMoreRow(
              expanded: _showAll,
              remaining: studies.length - _previewCount,
              onToggle: () => setState(() => _showAll = !_showAll),
            ),
        ],
      ],
    );
  }
}

// ── Collaborate CTA ───────────────────────────────────────────────────────────
// "JOIN THE EFFORT" — 3 action cards encouraging user contribution.
class _CollaborateCTA extends StatelessWidget {
  final VoidCallback onPostIdea;
  final VoidCallback onGoToSources;
  final ValueChanged<String> onSparkIdea;
  final int studyCount;

  const _CollaborateCTA({
    required this.onPostIdea,
    required this.onGoToSources,
    required this.onSparkIdea,
    required this.studyCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Text(
            'JOIN THE EFFORT',
            style: TextStyle(
              color: WebTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.08,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: Text(
            'Each contribution strengthens the community and evolves the knowledge graph.',
            style: TextStyle(
              color: WebTheme.textSecondary,
              fontSize: 12.5,
              height: 1.55,
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _CTACard(
              icon: Icons.lightbulb_outline,
              color: const Color(0xFF3B82F6),
              title: 'Post an Idea',
              description:
                  'Contribute a solution or hypothesis. Your idea becomes part of the category knowledge graph.',
              onTap: onPostIdea,
            ),
            _CTACard(
              icon: Icons.menu_book_outlined,
              color: WebTheme.accent,
              title: 'View All Sources',
              description:
                  '$studyCount peer-reviewed papers. Filter by topic, year, or journal.',
              onTap: onGoToSources,
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── CTA Card ──────────────────────────────────────────────────────────────────
class _CTACard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _CTACard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<_CTACard> createState() => _CTACardState();
}

class _CTACardState extends State<_CTACard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(WebTheme.cardRadius),
        child: AnimatedContainer(
          duration: WebTheme.fast,
          width: 180,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withValues(alpha: 0.10)
                : WebTheme.surfaceHover,
            border: Border.all(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.40)
                  : WebTheme.borderSubtle,
            ),
            borderRadius: BorderRadius.circular(WebTheme.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, size: 18, color: widget.color),
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: const TextStyle(
                  color: WebTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.description,
                style: const TextStyle(
                  color: WebTheme.textSecondary,
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section Block ─────────────────────────────────────────────────────────────
// Reusable container with a header row and bordered body.
class _SectionBlock extends StatelessWidget {
  final String title;
  final int count;
  final List<Widget> children;
  final bool showCount;

  const _SectionBlock({
    required this.title,
    required this.count,
    required this.children,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WebTheme.surfaceHover,
        border: Border.all(color: WebTheme.borderSubtle),
        borderRadius: BorderRadius.circular(WebTheme.itemRadius),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: WebTheme.borderSubtle)),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: WebTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.08,
                  ),
                ),
                const Spacer(),
                if (showCount)
                  Text(
                    '$count',
                    style: const TextStyle(
                      color: WebTheme.textMuted,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

// ── Finding Row ───────────────────────────────────────────────────────────────
// Single study row with hover state, spark button, and optional source link.
class _FindingRow extends StatefulWidget {
  final String number;
  final String text;
  final String tag;
  final Color color;
  final VoidCallback onSpark;
  final VoidCallback? onOpenSource;

  const _FindingRow({
    required this.number,
    required this.text,
    required this.tag,
    required this.color,
    required this.onSpark,
    this.onOpenSource,
  });

  @override
  State<_FindingRow> createState() => _FindingRowState();
}

class _FindingRowState extends State<_FindingRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      widget.text,
      style: TextStyle(
        color: widget.onOpenSource != null
            ? WebTheme.accent
            : WebTheme.textPrimary,
        fontSize: 13,
        height: 1.45,
        decoration: widget.onOpenSource != null
            ? TextDecoration.underline
            : null,
        decorationColor: WebTheme.accent.withValues(alpha: 0.4),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: WebTheme.fast,
        decoration: BoxDecoration(
          color: _hovered ? WebTheme.surfacePanel : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: Color(0x0DFFFFFF)),
          ),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              child: Text(
                widget.number,
                style: const TextStyle(
                  color: WebTheme.textMuted,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: widget.onOpenSource != null
                  ? InkWell(
                      onTap: widget.onOpenSource,
                      child: titleWidget,
                    )
                  : titleWidget,
            ),
            const SizedBox(width: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                widget.tag,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 10,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _hovered ? 1.0 : 0.0,
              duration: WebTheme.fast,
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Tooltip(
                  message: 'Spark idea from this finding',
                  child: InkWell(
                    onTap: widget.onSpark,
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text('💡', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Show More / Collapse Row ──────────────────────────────────────────────────
class _ShowMoreRow extends StatelessWidget {
  final bool expanded;
  final int remaining;
  final VoidCallback onToggle;

  const _ShowMoreRow({
    required this.expanded,
    required this.remaining,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              size: 15,
              color: WebTheme.accent,
            ),
            const SizedBox(width: 6),
            Text(
              expanded ? 'Show less' : 'Show $remaining more',
              style: const TextStyle(
                color: WebTheme.accent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Meta Pill ─────────────────────────────────────────────────────────────────
class _MetaPill extends StatelessWidget {
  final String label;
  const _MetaPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: WebTheme.surfaceHover,
        border: Border.all(color: WebTheme.borderSubtle),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: WebTheme.textMuted,
          fontSize: 11,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
