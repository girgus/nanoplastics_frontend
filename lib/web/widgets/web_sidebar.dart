import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../mixins/language_selection_mixin.dart';
import '../../widgets/nanosolve_logo.dart';
import '../web_state.dart';
import '../web_theme.dart';

class WebSidebar extends StatelessWidget {
  final AppLocalizations l10n;
  final bool expanded;
  final bool compactMode;
  final WebDomain domain;
  final WebSection section;
  final bool isChatOpen;
  final String selectedLanguage;
  final ValueChanged<WebDomain> onDomainChanged;
  final ValueChanged<WebSection> onSectionChanged;
  final VoidCallback onGoHome;
  final VoidCallback onToggleChat;
  final ValueChanged<String> onSelectLanguage;

  const WebSidebar({
    super.key,
    required this.l10n,
    required this.expanded,
    required this.compactMode,
    required this.domain,
    required this.section,
    required this.isChatOpen,
    required this.selectedLanguage,
    required this.onDomainChanged,
    required this.onSectionChanged,
    required this.onGoHome,
    required this.onToggleChat,
    required this.onSelectLanguage,
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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          color: Colors.white.withValues(alpha: 0.03),
        ),
        child: Row(
          mainAxisAlignment:
              showLabels ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            const Icon(Icons.language, size: 16, color: Colors.white70),
            if (showLabels) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${l10n.sidebarLang}: ${selectedLanguage.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white70,
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
      width: expanded ? WebTheme.sidebarExpanded : WebTheme.sidebarCollapsed,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 52,
                  child: showLabels
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: onGoHome,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: NanosolveLogo(height: 30),
                            ),
                          ),
                        )
                      : Center(
                          child: IconButton(
                            onPressed: onGoHome,
                            icon: const Icon(Icons.bubble_chart_outlined,
                                color: Colors.white70),
                            tooltip: l10n.navExplore,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                _DomainSwitch(
                  showLabels: showLabels,
                  active: domain,
                  onChange: onDomainChanged,
                  l10n: l10n,
                ),
                const SizedBox(height: 12),
                _NavItem(
                  icon: Icons.explore_outlined,
                  label: l10n.navExplore,
                  selected: section == WebSection.explore,
                  showLabel: showLabels,
                  onTap: () => onSectionChanged(WebSection.explore),
                ),
                _NavItem(
                  icon: Icons.menu_book_outlined,
                  label: l10n.navSources,
                  selected: section == WebSection.sources,
                  showLabel: showLabels,
                  onTap: () => onSectionChanged(WebSection.sources),
                ),
                _NavItem(
                  icon: Icons.lightbulb_outline,
                  label: l10n.categoryDetailIdeas,
                  selected: section == WebSection.ideas,
                  showLabel: showLabels,
                  onTap: () => onSectionChanged(WebSection.ideas),
                ),
                _NavItem(
                  icon: Icons.leaderboard_outlined,
                  label: l10n.navResults,
                  selected: section == WebSection.leaderboard,
                  showLabel: showLabels,
                  onTap: () => onSectionChanged(WebSection.leaderboard),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.12),
                    height: 1,
                  ),
                ),
                _NavItem(
                  icon: Icons.smart_toy_outlined,
                  label: l10n.sidebarAiChat,
                  selected: isChatOpen,
                  showLabel: showLabels,
                  badge: isChatOpen,
                  onTap: onToggleChat,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          languagePicker,
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool showLabel;
  final bool badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.showLabel,
    required this.onTap,
    this.badge = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Tooltip(
          message: widget.showLabel ? '' : widget.label,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: WebTheme.fast,
              margin: const EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.symmetric(
                horizontal: widget.showLabel ? 10 : 0,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: widget.selected
                    ? AppColors.pastelAqua.withValues(alpha: 0.18)
                    : (_hovered
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.transparent),
                border: Border.all(
                  color: widget.selected
                      ? AppColors.pastelAqua.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                mainAxisAlignment: widget.showLabel
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.selected
                            ? AppColors.pastelAqua
                            : Colors.white70,
                      ),
                      if (widget.badge)
                        const Positioned(
                          right: -2,
                          top: -2,
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: AppColors.pastelMint,
                          ),
                        ),
                    ],
                  ),
                  if (widget.showLabel) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.selected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.82),
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
          ),
        ),
      ),
    );
  }
}

class _DomainSwitch extends StatelessWidget {
  final bool showLabels;
  final WebDomain active;
  final ValueChanged<WebDomain> onChange;
  final AppLocalizations l10n;

  const _DomainSwitch({
    required this.showLabels,
    required this.active,
    required this.onChange,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (!showLabels) {
      return Column(
        children: [
          _DomainChip(
            label: l10n.tabHuman,
            icon: Icons.person_outline,
            active: active == WebDomain.human,
            showLabel: false,
            onTap: () => onChange(WebDomain.human),
            color: AppColors.neonCyan,
          ),
          const SizedBox(height: 6),
          _DomainChip(
            label: l10n.tabPlanet,
            icon: Icons.public,
            active: active == WebDomain.planet,
            showLabel: false,
            onTap: () => onChange(WebDomain.planet),
            color: AppColors.neonOcean,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _DomainChip(
            label: l10n.tabHuman,
            icon: Icons.person_outline,
            active: active == WebDomain.human,
            showLabel: showLabels,
            onTap: () => onChange(WebDomain.human),
            color: AppColors.neonCyan,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _DomainChip(
            label: l10n.tabPlanet,
            icon: Icons.public,
            active: active == WebDomain.planet,
            showLabel: showLabels,
            onTap: () => onChange(WebDomain.planet),
            color: AppColors.neonOcean,
          ),
        ),
      ],
    );
  }
}

class _DomainChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final bool showLabel;
  final VoidCallback onTap;
  final Color color;

  const _DomainChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.showLabel,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: active ? color : Colors.white70),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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
  }
}
