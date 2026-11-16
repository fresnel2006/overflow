import '../../../core/utils/formatters.dart';

enum ArticleIcon {
  waste,
  shield,
  warning,
  levels,
  kit,
  drain;

  static ArticleIcon fromName(String? v) => ArticleIcon.values.where((e) => e.name == v).firstOrNull ?? ArticleIcon.shield;
}

/// Fiche de sensibilisation (onglet "Conseils").
class AwarenessArticle {
  const AwarenessArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.paragraphs,
    required this.icon,
    required this.publishedAt,
    this.tips = const [],
  });

  final String id;
  final String title;
  final String summary;
  final List<String> paragraphs;
  final ArticleIcon icon;
  final DateTime publishedAt;

  /// Points cles affiches en liste a puces.
  final List<String> tips;

  factory AwarenessArticle.fromJson(Map<String, dynamic> j) => AwarenessArticle(
    id: j['id'].toString(),
    title: j['title'] as String,
    summary: j['summary'] as String,
    paragraphs: ((j['paragraphs'] as List?) ?? const []).cast<String>(),
    icon: ArticleIcon.fromName(j['icon'] as String?),
    publishedAt: parseDate(j['published_at']),
    tips: ((j['tips'] as List?) ?? const []).cast<String>(),
  );
}
