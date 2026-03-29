import 'package:flutter/material.dart';

import '../../models/category_detail_data.dart';
import '../web_theme.dart';

class CategoryShowcaseCard extends StatefulWidget {
  final CategoryDetailData category;
  final int index;
  final String ctaLabel;
  final VoidCallback onTap;

  const CategoryShowcaseCard({
    super.key,
    required this.category,
    required this.index,
    required this.ctaLabel,
    required this.onTap,
  });

  @override
  State<CategoryShowcaseCard> createState() => _CategoryShowcaseCardState();
}

class _CategoryShowcaseCardState extends State<CategoryShowcaseCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final seq = (widget.index + 1).toString().padLeft(2, '0');

    return Semantics(
      button: true,
      label: '${category.title}: ${category.subtitle}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(WebTheme.cardRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(WebTheme.cardRadius),
              border: Border.all(
                color: _hovered
                    ? category.themeColor.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.08),
              ),
              color: _hovered
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.04),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(WebTheme.cardRadius),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        category.themeColor.withValues(alpha: 0.38),
                        category.themeColor.withValues(alpha: 0.10),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(category.icon, color: category.themeColor, size: 24),
                      const Spacer(),
                      Text(
                        seq,
                        style: TextStyle(
                          color: category.themeColor.withValues(alpha: 0.55),
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.ctaLabel,
                            style: TextStyle(
                              color: category.themeColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 11,
                            color: category.themeColor,
                          ),
                        ],
                      ),
                    ],
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
