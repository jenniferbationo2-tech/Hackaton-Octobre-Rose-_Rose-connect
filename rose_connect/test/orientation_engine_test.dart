import 'package:flutter_test/flutter_test.dart';

import 'package:rose_connect/features/orientation/orientation_engine.dart';

void main() {
  const questions = [
    OrientationQuestion(id: 'q1', text: 'boule', kind: QuestionKind.sign),
    OrientationQuestion(id: 'q2', text: 'peau', kind: QuestionKind.sign),
    OrientationQuestion(id: 'q5', text: 'urgence', kind: QuestionKind.urgent),
  ];

  Guidance run(Answer q1, Answer q2, Answer q5) =>
      computeGuidance(questions, {'q1': q1, 'q2': q2, 'q5': q5});

  test('aucun changement signalé', () {
    expect(run(Answer.no, Answer.no, Answer.no), Guidance.none);
  });

  test('un changement signalé recommande une consultation', () {
    expect(run(Answer.yes, Answer.no, Answer.no), Guidance.change);
  });

  test('un changement prime sur un doute', () {
    expect(run(Answer.yes, Answer.unsure, Answer.no), Guidance.change);
  });

  test('un doute sans changement', () {
    expect(run(Answer.no, Answer.unsure, Answer.no), Guidance.unsure);
    expect(run(Answer.no, Answer.no, Answer.unsure), Guidance.unsure);
  });

  test('l’urgence prime sur tout le reste', () {
    expect(run(Answer.yes, Answer.unsure, Answer.yes), Guidance.urgent);
    expect(run(Answer.no, Answer.no, Answer.yes), Guidance.urgent);
  });
}
