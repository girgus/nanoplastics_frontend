import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/category_detail_data.dart';
import 'category_detail_view.dart';
import 'category_showcase.dart';

class ExploreSection extends StatelessWidget {
  final AppLocalizations l10n;
  final List<CategoryDetailData> categories;
  final CategoryDetailData? selectedCategory;
  final String activeLanguageCode;
  final ValueChanged<CategoryDetailData> onSelectCategory;
  final VoidCallback onClearSelection;
  final ValueChanged<CategoryDetailData> onOpenSources;
  final ValueChanged<CategoryDetailData> onPostIdea;
  final ValueChanged<String> onSparkIdea;
  final Future<void> Function(String url) onOpenInNewTab;

  const ExploreSection({
    super.key,
    required this.l10n,
    required this.categories,
    required this.selectedCategory,
    required this.activeLanguageCode,
    required this.onSelectCategory,
    required this.onClearSelection,
    required this.onOpenSources,
    required this.onPostIdea,
    required this.onSparkIdea,
    required this.onOpenInNewTab,
  });

  @override
  Widget build(BuildContext context) {
    // Show category showcase when no category is selected
    if (selectedCategory == null) {
      return CategoryShowcase(
        categories: categories,
        onSelectCategory: onSelectCategory,
        l10n: l10n,
      );
    }

    // Show detailed category view when a category is selected
    return CategoryDetailView(
      data: selectedCategory!,
      l10n: l10n,
      onOpenInNewTab: onOpenInNewTab,
      onPostIdea: () => onPostIdea(selectedCategory!),
      onGoToSources: () => onOpenSources(selectedCategory!),
      onSparkIdea: onSparkIdea,
    );
  }
}
