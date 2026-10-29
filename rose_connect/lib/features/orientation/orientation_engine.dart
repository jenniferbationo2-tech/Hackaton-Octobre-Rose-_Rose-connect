import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Answer { yes, no, unsure }

enum QuestionKind { sign, urgent }

/// Résultat d'orientation : jamais un diagnostic, jamais un score.
enum Guidance { urgent, change, unsure, none }

class OrientationQuestion {
  const OrientationQuestion({
    required this.id,
    required this.text,
    required this.kind,
    this.help,
  });

  factory OrientationQuestion.fromJson(Map<String, dynamic> json) =>
      OrientationQuestion(
        id: json['id'] as String,
        text: json['text'] as String,
        help: json['help'] as String?,
        kind: json['kind'] == 'urgent' ? QuestionKind.urgent : QuestionKind.sign,
      );

  final String id;
  final String text;
  final String? help;
  final QuestionKind kind;
}

class GuidanceMessage {
  const GuidanceMessage({required this.title, required this.message});

  factory GuidanceMessage.fromJson(Map<String, dynamic> json) =>
      GuidanceMessage(
        title: json['title'] as String,
        message: json['message'] as String,
      );

  final String title;
  final String message;
}

class OrientationContent {
  const OrientationContent({required this.questions, required this.messages});

  factory OrientationContent.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as Map<String, dynamic>;
    return OrientationContent(
      questions: [
        for (final q in json['questions'] as List)
          OrientationQuestion.fromJson(q as Map<String, dynamic>),
      ],
      messages: {
        for (final guidance in Guidance.values)
          guidance: GuidanceMessage.fromJson(
              results[guidance.name] as Map<String, dynamic>),
      },
    );
  }

  final List<OrientationQuestion> questions;
  final Map<Guidance, GuidanceMessage> messages;
}

final orientationContentProvider = FutureProvider<OrientationContent>((ref) async {
  final raw = await rootBundle.loadString('assets/data/orientation.json');
  return OrientationContent.fromJson(jsonDecode(raw) as Map<String, dynamic>);
});

/// Règles d'orientation, par ordre de priorité :
/// urgence > au moins un changement signalé > au moins un doute > aucun.
/// Règles à faire valider par un professionnel de santé.
Guidance computeGuidance(
  List<OrientationQuestion> questions,
  Map<String, Answer> answers,
) {
  Answer? answerFor(OrientationQuestion q) => answers[q.id];

  final urgent = questions.any(
      (q) => q.kind == QuestionKind.urgent && answerFor(q) == Answer.yes);
  if (urgent) return Guidance.urgent;

  final change = questions
      .any((q) => q.kind == QuestionKind.sign && answerFor(q) == Answer.yes);
  if (change) return Guidance.change;

  final unsure = questions.any((q) => answerFor(q) == Answer.unsure);
  if (unsure) return Guidance.unsure;

  return Guidance.none;
}

/// Réponses en cours, gardées uniquement en mémoire.
class OrientationAnswers extends Notifier<Map<String, Answer>> {
  @override
  Map<String, Answer> build() => const {};

  void answer(String questionId, Answer answer) =>
      state = {...state, questionId: answer};

  void reset() => state = const {};
}

final orientationAnswersProvider =
    NotifierProvider<OrientationAnswers, Map<String, Answer>>(
        OrientationAnswers.new);
