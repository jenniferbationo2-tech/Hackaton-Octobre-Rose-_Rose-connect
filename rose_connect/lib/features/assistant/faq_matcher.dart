import '../../models/education_item.dart';

class FaqItem {
  const FaqItem({
    required this.id,
    required this.question,
    required this.keywords,
    required this.answer,
    required this.sources,
    this.educationId,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) => FaqItem(
        id: json['id'] as String,
        question: json['question'] as String,
        keywords: List<String>.from(json['keywords'] as List),
        answer: json['answer'] as String,
        educationId: json['educationId'] as String?,
        sources: [
          for (final s in json['sources'] as List? ?? const [])
            Source.fromJson(s as Map<String, dynamic>),
        ],
      );

  final String id;
  final String question;
  final List<String> keywords;
  final String answer;
  final List<Source> sources;
  final String? educationId;
}

class FaqData {
  const FaqData({
    required this.items,
    required this.suggestions,
    required this.urgentKeywords,
    this.urgentCombinations = const [],
    required this.urgentAnswer,
  });

  factory FaqData.fromJson(Map<String, dynamic> json) {
    final items = [
      for (final i in json['items'] as List)
        FaqItem.fromJson(i as Map<String, dynamic>),
    ];
    final urgent = json['urgent'] as Map<String, dynamic>;
    return FaqData(
      items: items,
      suggestions: [
        for (final id in json['suggestions'] as List)
          items.firstWhere((item) => item.id == id),
      ],
      urgentKeywords: List<String>.from(urgent['keywords'] as List),
      urgentCombinations: [
        for (final combo in urgent['combinations'] as List? ?? const [])
          List<String>.from(combo as List),
      ],
      urgentAnswer: urgent['answer'] as String,
    );
  }

  final List<FaqItem> items;
  final List<FaqItem> suggestions;
  final List<String> urgentKeywords;
  final List<List<String>> urgentCombinations;
  final String urgentAnswer;
}

/// Recherche locale par mots-clés, utilisée hors ligne ou quand l'IA est
/// indisponible. Volontairement simple et prévisible.
abstract final class FaqMatcher {
  static const _accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'î': 'i', 'ï': 'i', 'í': 'i',
    'ô': 'o', 'ö': 'o', 'ó': 'o',
    'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
    'ç': 'c', 'œ': 'oe', 'æ': 'ae', 'ÿ': 'y',
  };

  static const _stopWords = {
    'le', 'la', 'les', 'un', 'une', 'des', 'de', 'du', 'd', 'l', 'au', 'aux',
    'et', 'ou', 'a', 'en', 'dans', 'sur', 'sous', 'pour', 'par', 'avec',
    'je', 'j', 'tu', 'il', 'elle', 'on', 'nous', 'vous', 'ils', 'elles',
    'me', 'm', 'te', 't', 'se', 's', 'mon', 'ma', 'mes', 'ton', 'ta', 'tes',
    'son', 'sa', 'ses', 'est', 'sont', 'ai', 'as', 'avez', 'ont', 'etre',
    'ce', 'cet', 'cette', 'ces', 'qui', 'que', 'qu', 'quoi', 'quel', 'quels',
    'quelle', 'quelles', 'comment', 'pourquoi', 'ne', 'pas', 'plus',
    'si', 'y', 'c', 'n', 'faut', 'peut', 'peux', 'cancer', 'sein',
    'seins', 'bonjour', 'svp', 'merci',
  };

  /// Minuscules, sans accents ni ponctuation.
  static String normalize(String text) {
    final lower = text.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_accents[char] ?? char);
    }
    return buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }

  static Set<String> tokens(String text) => normalize(text)
      .split(' ')
      .where((t) => t.isNotEmpty && !_stopWords.contains(t))
      .toSet();

  /// Urgence si une expression est présente telle quelle, ou si tous les
  /// mots d'une combinaison apparaissent dans la question.
  static bool isUrgent(
    String question,
    List<String> urgentKeywords, [
    List<List<String>> combinations = const [],
  ]) {
    final text = ' ${normalize(question)} ';
    if (urgentKeywords.any((k) => text.contains(' ${normalize(k)} '))) {
      return true;
    }
    final words = normalize(question).split(' ').toSet();
    return combinations.any((combo) => combo.every(words.contains));
  }

  /// Meilleure réponse préparée, ou null si aucune ne correspond assez.
  static FaqItem? match(String question, List<FaqItem> items) {
    final words = tokens(question);
    if (words.isEmpty) return null;

    FaqItem? best;
    var bestScore = 0.0;
    for (final item in items) {
      // Chaque mot de la question compte au plus une fois.
      var score = 0.0;
      for (final word in words) {
        if (item.keywords.any((k) => word == k || _sameStem(word, k))) {
          score += 1;
        }
      }
      // Recoupement avec la formulation de la question préparée.
      score += 0.5 * tokens(item.question).intersection(words).length;
      if (score > bestScore) {
        bestScore = score;
        best = item;
      }
    }
    return bestScore >= 1 ? best : null;
  }

  /// Singulier / pluriel et formes proches (« examens », « examen »).
  static bool _sameStem(String a, String b) {
    if (a.length < 5 || b.length < 5) return false;
    final n = a.length < b.length ? a.length : b.length;
    final prefix = n - 1;
    return a.substring(0, prefix) == b.substring(0, prefix);
  }
}
