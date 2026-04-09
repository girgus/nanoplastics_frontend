import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _findingsPreviewCount = 5;
  static const _sourcesPreviewCount = 3;
  bool _showAllFindings = false;
  bool _showAllSources = false;

  final TextEditingController _notesController = TextEditingController();
  Timer? _saveDebounce;

  String get _notesKey => 'research_notes_${widget.data.categoryKey}';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void didUpdateWidget(covariant CategoryDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.categoryKey != widget.data.categoryKey) {
      _showAllFindings = false;
      _showAllSources = false;
      _loadNotes();
    }
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_notesKey) ?? '';
    if (mounted) {
      _notesController.text = saved;
    }
  }

  void _onNotesChanged(String value) {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 600), () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notesKey, value);
    });
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studies = widget.data.allEvidenceStudies;
    final visibleFindings = _showAllFindings
        ? studies
        : studies.take(_findingsPreviewCount).toList();
    final visibleSources =
        _showAllSources ? studies : studies.take(_sourcesPreviewCount).toList();
    final hasMoreFindings = studies.length > _findingsPreviewCount;
    final hasMoreSources = studies.length > _sourcesPreviewCount;

    return CustomScrollView(
      slivers: [
        // Header
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
          sliver: SliverToBoxAdapter(
            child: _Header(data: widget.data),
          ),
        ),

        // Key Findings
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          sliver: SliverToBoxAdapter(
            child: _SectionBlock(
              title: 'KEY FINDINGS',
              count: studies.length,
              children: [
                ...visibleFindings.asMap().entries.map((e) => _FindingRow(
                      number: (e.key + 1).toString().padLeft(2, '0'),
                      text: e.value.title,
                      tag: e.value.studyType ?? 'Study',
                      color: widget.data.themeColor,
                      onSpark: () => widget.onSparkIdea(e.value.title),
                    )),
                if (hasMoreFindings)
                  _ShowMoreRow(
                    expanded: _showAllFindings,
                    remaining: studies.length - _findingsPreviewCount,
                    onToggle: () =>
                        setState(() => _showAllFindings = !_showAllFindings),
                  ),
              ],
            ),
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(top: 14)),

        // Sources preview
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          sliver: SliverToBoxAdapter(
            child: _SectionBlock(
              title: 'SCIENTIFIC SOURCES',
              count: studies.length,
              trailingAction: TextButton(
                onPressed: widget.onGoToSources,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: WebTheme.accent,
                ),
                child: const Text('View all', style: TextStyle(fontSize: 12)),
              ),
              children: [
                ...visibleSources.map((s) => _SourceRow(study: s)),
                if (hasMoreSources)
                  _ShowMoreRow(
                    expanded: _showAllSources,
                    remaining: studies.length - _sourcesPreviewCount,
                    onToggle: () =>
                        setState(() => _showAllSources = !_showAllSources),
                  ),
              ],
            ),
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(top: 14)),

        // Research notes
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          sliver: SliverToBoxAdapter(
            child: _ResearchNotesBlock(
              controller: _notesController,
              onChanged: _onNotesChanged,
              onPostIdea: widget.onPostIdea,
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

// ── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final CategoryDetailData data;
  const _Header({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: data.themeColor.withValues(alpha: 0.12),
                border:
                    Border.all(color: data.themeColor.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(data.icon, color: data.themeColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: WebTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.02,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.subtitle,
                    style: const TextStyle(
                      color: WebTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          children: [
            _MetaPill(label: '${data.evidenceStudyCount} studies'),
          ],
        ),
      ],
    );
  }
}

// ── Section block ─────────────────────────────────────────────────────────────
class _SectionBlock extends StatelessWidget {
  final String title;
  final int count;
  final List<Widget> children;
  final Widget? trailingAction;

  const _SectionBlock({
    required this.title,
    required this.count,
    required this.children,
    this.trailingAction,
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: WebTheme.borderSubtle)),
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
                if (trailingAction != null)
                  trailingAction!
                else
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

// ── Finding row ───────────────────────────────────────────────────────────────
class _FindingRow extends StatefulWidget {
  final String number;
  final String text;
  final String tag;
  final Color color;
  final VoidCallback onSpark;

  const _FindingRow({
    required this.number,
    required this.text,
    required this.tag,
    required this.color,
    required this.onSpark,
  });

  @override
  State<_FindingRow> createState() => _FindingRowState();
}

class _FindingRowState extends State<_FindingRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              child: Text(
                widget.text,
                style: const TextStyle(
                  color: WebTheme.textPrimary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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

// ── Source row ────────────────────────────────────────────────────────────────
class _SourceRow extends StatelessWidget {
  final EvidenceStudy study;
  const _SourceRow({required this.study});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  study.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: WebTheme.accent,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                if (study.doiOrPubMed != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    study.doiOrPubMed!,
                    style: const TextStyle(
                      color: WebTheme.textMuted,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                study.journal,
                style: const TextStyle(
                  color: WebTheme.textSecondary,
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                study.year.toString(),
                style: const TextStyle(
                  color: WebTheme.textMuted,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Show more / collapse row ──────────────────────────────────────────────────
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

// ── Research notes block ──────────────────────────────────────────────────────
class _ResearchNotesBlock extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onPostIdea;

  const _ResearchNotesBlock({
    required this.controller,
    required this.onChanged,
    required this.onPostIdea,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: WebTheme.borderSubtle)),
            ),
            child: const Row(
              children: [
                Text(
                  'RESEARCH NOTES',
                  style: TextStyle(
                    color: WebTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.08,
                  ),
                ),
                Spacer(),
                Icon(Icons.save_outlined, size: 13, color: WebTheme.textMuted),
                SizedBox(width: 4),
                Text(
                  'auto-saved',
                  style: TextStyle(
                    color: WebTheme.textMuted,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          // Textarea
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              maxLines: 6,
              minLines: 4,
              style: const TextStyle(
                color: WebTheme.textPrimary,
                fontSize: 13,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                hintText: 'Your notes on this category...',
                hintStyle: TextStyle(
                  color: WebTheme.textMuted,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // CTA row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: WebTheme.borderSubtle)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    size: 13, color: WebTheme.textMuted),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Spark an idea from a finding above, or write your own',
                    style: TextStyle(
                      color: WebTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: onPostIdea,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Post Idea'),
                  style: FilledButton.styleFrom(
                    backgroundColor: WebTheme.accent,
                    foregroundColor: const Color(0xFF003228),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge widgets ─────────────────────────────────────────────────────────────
class _RiskBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _RiskBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.06,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

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
