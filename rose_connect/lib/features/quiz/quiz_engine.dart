import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizOption {
  const QuizOption({required this.id, required this.label});

  factory QuizOption.fromJson(Map<String, dynamic> json) =>
      QuizOption(id: json['id'] as String, label: json['label'] as String);

  final String id;
  final String label;
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionId,
    required this.explanation,
    this.educationId,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as String,
        question: json['question'] as String,
        options: [
          for (final o in json['options'] as List)
            QuizOption.fromJson(o as Map<String, dynamic>),
        ],
        correctOptionId: json['correctOptionId'] as String,
        explanation: json['explanation'] as String,
        educationId: json['educationId'] as String?,
      );

  final String id;
  final String question;
  final List<QuizOption> options;
  final String correctOptionId;
  final String explanation;
  final String? educationId;
}

final quizQuestionsProvider = FutureProvider<List<QuizQuestion>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/quiz.json');
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return [
    for (final q in json['questions'] as List)
      QuizQuestion.fromJson(q as Map<String, dynamic>),
  ];
});

/// État d'une partie : question courante, choix en cours, réponses validées.
class QuizState {
  const QuizState({
    this.index = 0,
    this.selectedOptionId,
    this.validated = false,
    this.answers = const {},
  });

  final int index;
  final String? selectedOptionId;
  final bool validated;

  /// Réponse validée pour chaque question (id question -> id option).
  final Map<String, String> answers;

  int correctCount(List<QuizQuestion> questions) => questions
      .where((q) => answers[q.id] == q.correctOptionId)
      .length;

  QuizState copyWith({
    int? index,
    String? Function()? selectedOptionId,
    bool? validated,
    Map<String, String>? answers,
  }) =>
      QuizState(
        index: index ?? this.index,
        selectedOptionId:
            selectedOptionId == null ? this.selectedOptionId : selectedOptionId(),
        validated: validated ?? this.validated,
        answers: answers ?? this.answers,
      );
}

class QuizController extends Notifier<QuizState> {
  @override
  QuizState build() => const QuizState();

  void restart() => state = const QuizState();

  void select(String optionId) {
    if (state.validated) return;
    state = state.copyWith(selectedOptionId: () => optionId);
  }

  void validate(QuizQuestion question) {
    final selected = state.selectedOptionId;
    if (selected == null || state.validated) return;
    state = state.copyWith(
      validated: true,
      answers: {...state.answers, question.id: selected},
    );
  }

  void next() => state = state.copyWith(
        index: state.index + 1,
        selectedOptionId: () => null,
        validated: false,
      );
}

final quizControllerProvider =
    NotifierProvider<QuizController, QuizState>(QuizController.new);
