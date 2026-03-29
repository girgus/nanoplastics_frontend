import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../web_state.dart';
import '../web_theme.dart';

class WebTopBar extends StatelessWidget {
  final AppLocalizations l10n;
  final WebSection section;
  final WebDomain domain;
  final String? selectedCategoryTitle;
  final ValueChanged<WebDomain> onDomainChanged;

  const WebTopBar({
    super.key,
    required this.l10n,
    required this.section,
    required this.domain,
    required this.selectedCategoryTitle,
    required this.onDomainChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: WebTheme.topbarHeight,
      decoration: BoxDecoration(
        color: WebTheme.surfaceTopbar(context),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _Breadcrumb(
              section: section,
              selectedCategoryTitle: selectedCategoryTitle,
              l10n: l10n,
            ),
          ),
          if (section == WebSection.explore)
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: _DomainPill(
                    l10n: l10n,
                    domain: domain,
                    onDomainChanged: onDomainChanged,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DomainPill extends StatelessWidget {
  final AppLocalizations l10n;
  final WebDomain domain;
  final ValueChanged<WebDomain> onDomainChanged;

  const _DomainPill({
    required this.l10n,
    required this.domain,
    required this.onDomainChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _segment(
            icon: Icons.person_outline,
            text: l10n.tabHuman,
            active: domain == WebDomain.human,
            onTap: () => onDomainChanged(WebDomain.human),
          ),
          _segment(
            icon: Icons.public,
            text: l10n.tabPlanet,
            active: domain == WebDomain.planet,
            onTap: () => onDomainChanged(WebDomain.planet),
          ),
        ],
      ),
    );
  }

  Widget _segment({
    required IconData icon,
    required String text,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: WebTheme.normal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? AppColors.pastelAqua.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 14,
                color: active ? AppColors.pastelAqua : Colors.white70),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  final WebSection section;
  final String? selectedCategoryTitle;
  final AppLocalizations l10n;

  const _Breadcrumb({
    required this.section,
    required this.selectedCategoryTitle,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final items = <String>[
      switch (section) {
        WebSection.explore => l10n.navExplore,
        WebSection.sources => l10n.navSources,
        WebSection.ideas => l10n.categoryDetailIdeas,
        WebSection.leaderboard => l10n.navResults,
      },
      if (selectedCategoryTitle != null && section == WebSection.explore)
        selectedCategoryTitle!,
    ];

    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: items.asMap().entries.map((entry) {
        final isLast = entry.key == items.length - 1;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              entry.value,
              style: TextStyle(
                color: isLast
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.65),
                fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  l10n.breadcrumbSeparator,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
                ),
              ),
          ],
        );
      }).toList(growable: false),
    );
  }
}
