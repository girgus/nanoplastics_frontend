import 'package:flutter/material.dart';

class DigestPaper {
  final String id;
  final String title;
  final String? perex;
  final String? category;
  final String? subcategory;
  final List<String> labels;
  final List<String> matchedKeywords;
  final String sourceUrl;
  final String? publishedDate;
  final String? doi;
  final String authors;
  final String? journal;
  final String source;

  const DigestPaper({
    required this.id,
    required this.title,
    this.perex,
    this.category,
    this.subcategory,
    required this.labels,
    required this.matchedKeywords,
    required this.sourceUrl,
    this.publishedDate,
    this.doi,
    required this.authors,
    this.journal,
    required this.source,
  });

  factory DigestPaper.fromJson(Map<String, dynamic> json) => DigestPaper(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        perex: json['perex'] as String?,
        category: json['category'] as String?,
        subcategory: json['subcategory'] as String?,
        labels: (json['labels'] as List<dynamic>?)?.cast<String>() ?? [],
        matchedKeywords:
            (json['matched_keywords'] as List<dynamic>?)?.cast<String>() ?? [],
        sourceUrl: json['source_url'] as String? ?? '',
        publishedDate: json['published_date'] as String?,
        doi: json['doi'] as String?,
        authors: json['authors'] as String? ?? '',
        journal: json['journal'] as String?,
        source: json['source'] as String? ?? '',
      );

  /// Category color for chip display — matches backend taxonomy.
  Color categoryColor(BuildContext context) {
    switch (category) {
      case 'human':
        return const Color(0xFFF43F5E);
      case 'planet':
        return const Color(0xFF00B4D8);
      case 'electricity':
        return const Color(0xFFFBBF24);
      case 'animals':
        return const Color(0xFF4ADE80);
      case 'experiment':
        return const Color(0xFFA855F7);
      default:
        return const Color(0xFFB0B0B0);
    }
  }

  IconData categoryIcon() {
    switch (category) {
      case 'human':
        return Icons.person_outline;
      case 'planet':
        return Icons.public;
      case 'electricity':
        return Icons.bolt;
      case 'animals':
        return Icons.pets;
      case 'experiment':
        return Icons.science_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
