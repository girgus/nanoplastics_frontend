class SolverIdea {
  final String id;
  final String abstractText;
  final String description;
  final String? category;
  final String createdAt;

  const SolverIdea({
    required this.id,
    required this.abstractText,
    required this.description,
    this.category,
    required this.createdAt,
  });

  factory SolverIdea.fromJson(Map<String, dynamic> json) {
    return SolverIdea(
      id: json['id'] as String,
      abstractText: json['abstract_text'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}
