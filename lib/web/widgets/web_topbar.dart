import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../web_state.dart';
import '../web_theme.dart';

class WebTopBar extends StatelessWidget {
  final AppLocalizations l10n;
  final WebSection section;
  final String? selectedCategoryTitle;
  final ValueChanged<WebSection>? onSectionChanged;
  final VoidCallback? onGoHome;

  const WebTopBar({
    super.key,
    required this.l10n,
    required this.section,
    this.selectedCategoryTitle,
    this.onSectionChanged,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final crumbLabel = switch (section) {
      WebSection.explore => selectedCategoryTitle ?? 'Workspace',
      WebSection.sources => l10n.navSources,
      WebSection.ideas => 'Ideas',
      WebSection.leaderboard => 'Leaderboard',
      WebSection.settings => l10n.settingsTitle,
    };

    return Container(
      height: WebTheme.topbarHeight,
      decoration: const BoxDecoration(
        color: WebTheme.surfaceTopbar,
        border: Border(bottom: BorderSide(color: WebTheme.borderSubtle)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // ── Breadcrumb ────────────────────────────────────────────────
          InkWell(
            onTap: onGoHome,
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                'NanoSolve',
                style: TextStyle(
                  color: WebTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: Icon(Icons.chevron_right, size: 13, color: WebTheme.textMuted),
          ),
          Text(
            crumbLabel,
            style: const TextStyle(
              color: WebTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          // ── Divider ───────────────────────────────────────────────────
          Container(
            width: 1,
            height: 18,
            color: WebTheme.borderSubtle,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // ── Nav tabs ──────────────────────────────────────────────────
          _NavTab(
            icon: Icons.menu_book_outlined,
            label: l10n.navSources,
            active: section == WebSection.sources,
            onTap: () => onSectionChanged?.call(WebSection.sources),
          ),
          const SizedBox(width: 2),
          _NavTab(
            icon: Icons.lightbulb_outline,
            label: 'Ideas',
            active: section == WebSection.ideas,
            onTap: () => onSectionChanged?.call(WebSection.ideas),
          ),
          const SizedBox(width: 2),
          _NavTab(
            icon: Icons.leaderboard_outlined,
            label: 'Leaderboard',
            active: section == WebSection.leaderboard,
            onTap: () => onSectionChanged?.call(WebSection.leaderboard),
          ),
          const SizedBox(width: 2),
          _NavTab(
            icon: Icons.tune_outlined,
            label: l10n.settingsTitle,
            active: section == WebSection.settings,
            onTap: () => onSectionChanged?.call(WebSection.settings),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

// ── Nav tab (index.html style: filled bg active, hover border) ────────────────
class _NavTab extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color fg = widget.active
        ? WebTheme.accent
        : (_hovered ? WebTheme.textSecondary : WebTheme.textMuted);

    return Semantics(
      button: true,
      selected: widget.active,
      label: widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: WebTheme.fast,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: widget.active
                  ? WebTheme.accentDim
                  : (_hovered ? WebTheme.surfaceHover : Colors.transparent),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.active
                    ? WebTheme.accent.withValues(alpha: 0.3)
                    : (_hovered ? WebTheme.borderSubtle : Colors.transparent),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 13, color: fg),
                const SizedBox(width: 5),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 12,
                    fontWeight: widget.active ? FontWeight.w600 : FontWeight.w400,
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
