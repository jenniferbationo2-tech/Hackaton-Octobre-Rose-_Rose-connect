import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rose_connect/features/assistant/faq_matcher.dart';

import 'test_app.dart';

final faq = FaqData.fromJson(
  jsonDecode(File('assets/data/faq.json').readAsStringSync())
      as Map<String, dynamic>,
);

Future<void> settle(WidgetTester tester) => tester.pumpAndSettle();

/// Ouvre l'onglet Assistant, la FAQ étant fournie directement.
Future<void> openAssistant(WidgetTester tester) async {
  await tester.pumpWidget(await buildTestApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text('Assistant').last);
  await settle(tester);
}

void main() {
  String? matchId(String question) => FaqMatcher.match(question, faq.items)?.id;

  group('Recherche dans la FAQ', () {
    test('chaque question préparée retrouve sa propre réponse', () {
      for (final item in faq.items) {
        expect(matchId(item.question), item.id, reason: item.question);
      }
    });

    test('les reformulations courantes sont comprises', () {
      expect(matchId('j’ai trouvé une grosseur, c’est grave ?'), 'boule');
      expect(matchId('Quels symptômes doivent alerter ?'), 'signes');
      expect(matchId('ça se passe comment une mammographie'), 'examen');
      expect(matchId('ma sœur est malade, comment l’aider'), 'soutenir');
      expect(matchId('Est ce que c’est héréditaire ?'), 'facteurs');
      expect(matchId('Est-ce que ça s’attrape ?'), 'contagieux');
    });

    test('aucune réponse pour une question hors sujet', () {
      expect(matchId('Quelle est la capitale du Japon ?'), isNull);
      expect(matchId('   '), isNull);
    });

    test('les situations urgentes sont détectées par des règles fixes', () {
      bool urgent(String q) => FaqMatcher.isUrgent(
          q, faq.urgentKeywords, faq.urgentCombinations);
      expect(urgent('J’ai du mal à respirer depuis ce matin'), isTrue);
      expect(urgent('Mon sein est rouge et chaud, j’ai de la fièvre'), isTrue);
      expect(urgent('je saigne beaucoup du mamelon'), isTrue);
      expect(urgent('Quels sont les signes ?'), isFalse);
      expect(urgent('Ma peau est un peu rouge, est-ce normal ?'), isFalse);
    });
  });

  testWidgets('poser une question suggérée affiche une réponse préparée',
      (tester) async {
    await openAssistant(tester);

    expect(find.text('Questions fréquentes'), findsOneWidget);
    await tester.ensureVisible(find.text('Quand faut-il consulter ?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quand faut-il consulter ?'));
    await settle(tester);

    expect(find.text('Réponse préparée à l’avance'), findsOneWidget);
    expect(find.text('Lire la fiche'), findsOneWidget);
    expect(find.text('Information générale, pas un diagnostic médical.'),
        findsOneWidget);
  });

  testWidgets('une situation urgente affiche la consigne d’urgence',
      (tester) async {
    await openAssistant(tester);

    await tester.enterText(
        find.byType(TextField), 'je saigne beaucoup du mamelon');
    // Le bouton d'envoi s'active au rendu suivant la saisie.
    await tester.pump();
    await tester.tap(find.byTooltip('Envoyer'));
    await settle(tester);

    expect(find.text('Consultez rapidement'), findsOneWidget);
    // Nouvelle conversation : retour aux questions fréquentes.
    await tester.tap(find.byTooltip('Nouvelle conversation'));
    await tester.pumpAndSettle();
    expect(find.text('Questions fréquentes'), findsOneWidget);
  });
}
