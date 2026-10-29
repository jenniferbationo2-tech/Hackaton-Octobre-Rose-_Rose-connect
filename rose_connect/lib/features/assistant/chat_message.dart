import '../../models/education_item.dart';

enum ChatRole { user, assistant }

/// Origine d'une réponse de l'assistant.
enum ReplyKind {
  /// Rédigée par l'IA à partir de la base documentaire.
  ai,

  /// Réponse préparée à l'avance (IA indisponible ou hors ligne).
  prepared,

  /// Consigne d'urgence prédéfinie, sans appel à l'IA.
  urgent,

  /// Aucune réponse disponible.
  none,
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.kind = ReplyKind.ai,
    this.sources = const [],
    this.educationId,
    this.failed = false,
  });

  final String id;
  final ChatRole role;
  final String text;
  final ReplyKind kind;
  final List<Source> sources;
  final String? educationId;

  /// Question de l'utilisatrice restée sans réponse (erreur réseau).
  final bool failed;

  ChatMessage copyWith({bool? failed}) => ChatMessage(
        id: id,
        role: role,
        text: text,
        kind: kind,
        sources: sources,
        educationId: educationId,
        failed: failed ?? this.failed,
      );
}

class AssistantReply {
  const AssistantReply({
    required this.text,
    required this.kind,
    this.sources = const [],
    this.educationId,
  });

  factory AssistantReply.fromApi(Map<String, dynamic> json) => AssistantReply(
        text: json['answer'] as String,
        kind: json['urgent'] == true ? ReplyKind.urgent : ReplyKind.ai,
        sources: [
          for (final s in json['sources'] as List? ?? const [])
            Source.fromJson(s as Map<String, dynamic>),
        ],
      );

  final String text;
  final ReplyKind kind;
  final List<Source> sources;
  final String? educationId;
}
