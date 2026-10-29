import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rose_connect/features/orientation/orientation_engine.dart';
import 'package:rose_connect/features/quiz/quiz_engine.dart';
import 'package:rose_connect/models/education_item.dart';

Map<String, dynamic> _load(String name) =>
    jsonDecode(File('assets/data/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  final education = [
    for (final e in _load('education.json')['items'] as List)
      EducationItem.fromJson(e as Map<String, dynamic>),
  ];
  final quiz = [
    for (final q in _load('quiz.json')['questions'] as List)
      QuizQuestion.fromJson(q as Map<String, dynamic>),
  ];

  test('les fiches liées depuis l’app existent', () {
    final ids = education.map((e) => e.id).toSet();
    // Identifiants utilisés par l'accueil et le questionnaire.
    expect(
      ids,
      containsAll([
        'cancer-du-sein',
        'signes-sein',
        'facteurs-risque',
        'pourquoi-consulter',
        'idees-recues',
      ]),
    );
    for (final q in quiz) {
      expect(ids, contains(q.educationId), reason: 'quiz ${q.id}');
    }
  });

  test('chaque fiche a un contenu et une source', () {
    for (final item in education) {
      expect(item.blocks, isNotEmpty, reason: item.id);
      expect(item.sources, isNotEmpty, reason: item.id);
    }
  });

  test('chaque question du quiz a une bonne réponse valide', () {
    for (final q in quiz) {
      expect(q.options.map((o) => o.id), contains(q.correctOptionId),
          reason: q.id);
      expect(q.options.length, inInclusiveRange(3, 4), reason: q.id);
    }
  });

  test('le questionnaire définit un message pour chaque résultat', () {
    final content = OrientationContent.fromJson(_load('orientation.json'));
    expect(content.questions, isNotEmpty);
    expect(content.messages.keys, containsAll(Guidance.values));
  });

  test('aucun tiret cadratin dans les contenus ni dans le code', () {
    final files = [
      ...Directory('assets/data').listSync().whereType<File>(),
      ...Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')),
    ];
    for (final file in files) {
      expect(file.readAsStringSync().contains('—'), isFalse,
          reason: file.path);
    }
  });

  test('le quiz compte correctement les bonnes réponses', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(quizControllerProvider.notifier);

    for (final (i, q) in quiz.indexed) {
      // Une question sur deux juste.
      final option = i.isEven
          ? q.correctOptionId
          : q.options.firstWhere((o) => o.id != q.correctOptionId).id;
      controller.select(option);
      controller.validate(q);
      // Un second choix après validation est ignoré.
      controller.select(q.correctOptionId);
      if (i < quiz.length - 1) controller.next();
    }

    final state = container.read(quizControllerProvider);
    expect(state.answers.length, quiz.length);
    expect(state.correctCount(quiz), (quiz.length + 1) ~/ 2);
  });
}
