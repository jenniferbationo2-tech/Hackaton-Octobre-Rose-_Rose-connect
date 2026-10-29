class Source {
  const Source({required this.label, this.url});

  factory Source.fromJson(Map<String, dynamic> json) =>
      Source(label: json['label'] as String, url: json['url'] as String?);

  final String label;
  final String? url;
}

/// Bloc de contenu d'une fiche éducative.
sealed class EducationBlock {
  const EducationBlock();

  static EducationBlock? fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'heading' => HeadingBlock(json['text'] as String),
        'paragraph' => ParagraphBlock(json['text'] as String),
        'bullets' => BulletsBlock(List<String>.from(json['items'] as List)),
        'callout' => CalloutBlock(json['text'] as String),
        'myth' => MythBlock(
            myth: json['myth'] as String, fact: json['fact'] as String),
        // Type inconnu (contenu plus récent que l'app) : ignoré.
        _ => null,
      };
}

class HeadingBlock extends EducationBlock {
  const HeadingBlock(this.text);
  final String text;
}

class ParagraphBlock extends EducationBlock {
  const ParagraphBlock(this.text);
  final String text;
}

class BulletsBlock extends EducationBlock {
  const BulletsBlock(this.items);
  final List<String> items;
}

class CalloutBlock extends EducationBlock {
  const CalloutBlock(this.text);
  final String text;
}

class MythBlock extends EducationBlock {
  const MythBlock({required this.myth, required this.fact});
  final String myth;
  final String fact;
}

/// Point clé d'une fiche : une icône et quelques mots.
class KeyPoint {
  const KeyPoint({required this.icon, required this.text});

  factory KeyPoint.fromJson(Map<String, dynamic> json) =>
      KeyPoint(icon: json['icon'] as String, text: json['text'] as String);

  final String icon;
  final String text;
}

class EducationItem {
  const EducationItem({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.blocks,
    required this.sources,
    this.keyPoints = const [],
    this.published = true,
  });

  factory EducationItem.fromJson(Map<String, dynamic> json) => EducationItem(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        summary: json['summary'] as String,
        published: json['published'] as bool? ?? true,
        keyPoints: [
          for (final point in (json['keyPoints'] as List? ?? const []))
            KeyPoint.fromJson(point as Map<String, dynamic>),
        ],
        blocks: [
          for (final block in (json['blocks'] as List? ?? const []))
            ?EducationBlock.fromJson(block as Map<String, dynamic>),
        ],
        sources: [
          for (final source in (json['sources'] as List? ?? const []))
            Source.fromJson(source as Map<String, dynamic>),
        ],
      );

  final String id;
  final String title;
  final String category;
  final String summary;
  final List<EducationBlock> blocks;
  final List<Source> sources;
  final List<KeyPoint> keyPoints;
  final bool published;
}
