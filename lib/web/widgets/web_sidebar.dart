import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../mixins/language_selection_mixin.dart';
import '../../models/category_detail_data.dart';
import '../../widgets/nanosolve_logo.dart';
import '../web_theme.dart';

// ── Left Panel Sidebar ────────────────────────────────────────────────────────
// Displays the navigation sidebar with logo, category list, and language selector.
// Toggles between expanded (showing labels) and collapsed (icons only) states.

class WebSidebar extends StatelessWidget {
  final AppLocalizations l10n;
  final bool expanded;
  final bool compactMode;
  final String selectedLanguage;
  final List<CategoryDetailData> categories;
  final CategoryDetailData? selectedCategory;
  final ValueChanged<String> onSelectLanguage;
  final ValueChanged<CategoryDetailData> onSelectCategory;

  const WebSidebar({
    super.key,
    required this.l10n,
    required this.expanded,
    required this.compactMode,
    required this.selectedLanguage,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectLanguage,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final showLabels = expanded && !compactMode;

    final languagePicker = PopupMenuButton<String>(
      tooltip: l10n.sidebarLang,
      onSelected: onSelectLanguage,
      itemBuilder: (context) => LanguageSelectionMixin.supportedLanguages
          .map(
            (lang) => PopupMenuItem<String>(
              value: lang['code']!,
              child: Row(
                children: [
                  Text(lang['flag']!),
                  const SizedBox(width: 8),
                  Text(lang['name']!),
                ],
              ),
            ),
          )
          .toList(growable: false),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: WebTheme.borderSubtle),
          color: WebTheme.surfaceHover,
        ),
        child: Row(
          mainAxisAlignment:
              showLabels ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            const Icon(Icons.language, size: 16, color: WebTheme.textSecondary),
            if (showLabels) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${l10n.sidebarLang}: ${selectedLanguage.toUpperCase()}',
                  style: const TextStyle(
                    color: WebTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Container(
      decoration: const BoxDecoration(
        color: WebTheme.surfaceSidebar,
        border: Border(right: BorderSide(color: WebTheme.borderSubtle)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
      child: Column(
        children: [
          // ── Logo Section ──────────────────────────────────────────────────
          // Displays app logo (expanded) or icon (collapsed)
          SizedBox(
            height: 44,
            child: showLabels
                ? const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: NanosolveLogo(height: 28),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.bubble_chart_outlined,
                        color: WebTheme.textSecondary),
                  ),
          ),

          const SizedBox(height: 4),
          const Divider(height: 1, color: WebTheme.borderSubtle),

          // ── Categories Header ─────────────────────────────────────────────
          // Shows category count when sidebar is expanded
          if (showLabels)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Row(
                children: [
                  const Text(
                    'CATEGORIES',
                    style: TextStyle(
                      color: WebTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${categories.length}',
                    style: const TextStyle(
                      color: WebTheme.textMuted,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 6),

          // ── Category List ─────────────────────────────────────────────────
          // Scrollable list organized in Human and Planet sections
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Human Impact Categories
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                  child: Text(
                    'Human',
                    style: TextStyle(
                      color: const Color(0xFF7DD3FC),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ...categories
                    .where((cat) => cat.categoryKey.startsWith('human_'))
                    .map((cat) => _CategoryRow(
                          cat: cat,
                          active: selectedCategory?.categoryKey == cat.categoryKey,
                          showLabel: showLabels,
                          onTap: () => onSelectCategory(cat),
                        )),
                const SizedBox(height: 12),
                // Planet Impact Categories
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                  child: Text(
                    'Planet',
                    style: TextStyle(
                      color: const Color(0xFF86EFAC),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ...categories
                    .where((cat) => cat.categoryKey.startsWith('planet_'))
                    .map((cat) => _CategoryRow(
                          cat: cat,
                          active: selectedCategory?.categoryKey == cat.categoryKey,
                          showLabel: showLabels,
                          onTap: () => onSelectCategory(cat),
                        )),
              ],
            ),
          ),

          const SizedBox(height: 8),
          // ── Language Selector ─────────────────────────────────────────────
          // Dropdown to change app language (EN, CS, ES, FR, RU)
          languagePicker,
        ],
      ),
    );
  }
}

// ── Category Row ─────────────────────────────────────────────────────────────
// Individual category item in the sidebar with hover/active states.
// Shows icon, category title (when expanded), and handles tap to select category.
class _CategoryRow extends StatefulWidget {
  final CategoryDetailData cat;
  final bool active;
  final bool showLabel;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.cat,
    required this.active,
    required this.showLabel,
    required this.onTap,
  });

  @override
  State<_CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<_CategoryRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.active,
      label: widget.cat.title,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Tooltip(
          message: widget.showLabel ? '' : widget.cat.title,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(WebTheme.itemRadius),
            child: AnimatedContainer(
              duration: WebTheme.fast,
              margin: const EdgeInsets.only(bottom: 1),
              padding: EdgeInsets.symmetric(
                horizontal: widget.showLabel ? 8 : 0,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(WebTheme.itemRadius),
                color: widget.active
                    ? WebTheme.accentDim
                    : (_hovered ? WebTheme.surfaceHover : Colors.transparent),
                border: Border(
                  left: BorderSide(
                    color:
                        widget.active ? WebTheme.accent : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: widget.showLabel
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: widget.cat.themeColor.withValues(alpha: 0.14),
                    ),
                    child: Icon(
                      widget.cat.icon,
                      size: 14,
                      color: widget.active
                          ? WebTheme.accent
                          : widget.cat.themeColor,
                    ),
                  ),
                  if (widget.showLabel) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.cat.title.replaceAll(RegExp(r'\s*\([^)]*\)'), ''),
                        style: TextStyle(
                          color: widget.active
                              ? WebTheme.textPrimary
                              : WebTheme.textSecondary,
                          fontWeight: widget.active
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
