import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/category_detail_data.dart';
import '../web_theme.dart';

class CategoryShowcase extends StatelessWidget {
  final List<CategoryDetailData> categories;
  final ValueChanged<CategoryDetailData> onSelectCategory;
  final AppLocalizations l10n;

  const CategoryShowcase({
    super.key,
    required this.categories,
    required this.onSelectCategory,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Research Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _CategoryCard(
                category: categories[index],
                onTap: () => onSelectCategory(categories[index]),
              ),
              childCount: categories.length,
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

class _CategoryCard extends StatelessWidget {
  final CategoryDetailData category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(WebTheme.itemRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(WebTheme.itemRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
            color: Colors.white.withValues(alpha: 0.04),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + Title row
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.themeColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          category.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Study count
              Text(
                '${category.evidenceStudyCount} studies',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontFamily: 'Roboto Mono',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
