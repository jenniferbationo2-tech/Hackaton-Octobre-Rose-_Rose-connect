@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rose_connect/core/router/app_router.dart';

import 'screenshot_helpers.dart';


/// Captures des écrans de modules sur un petit téléphone (360 dp),
/// le cas le plus contraint.
/// flutter test --tags screenshots --run-skipped --update-goldens
void main() {
  setUpAll(loadAppFonts);
  const phone = Phone('petit_360x640', Size(360, 640));

  Future<void> goTo(WidgetTester tester, String location) async {
    final container =
        ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
    container.read(routerProvider).go(location);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  testWidgets('éducation', (tester) async {
    await pumpOnPhone(tester, phone);
    await goTo(tester, AppRoutes.education);
    await snap(tester, 'education_liste');
    await goTo(tester, AppRoutes.educationDetail('signes-sein'));
    await snap(tester, 'education_fiche_1');
    await scrollPage(tester, 450);
    await snap(tester, 'education_fiche_2');
    await goTo(tester, AppRoutes.educationDetail('idees-recues'));
    await scrollPage(tester, 200);
    await snap(tester, 'education_idees_recues');
  });

  testWidgets('questionnaire', (tester) async {
    await pumpOnPhone(tester, phone);
    await goTo(tester, AppRoutes.orientation);
    await snap(tester, 'orientation_intro');
    await tapText(tester, 'Commencer');
    await tapText(tester, 'Non');
    await snap(tester, 'orientation_question');
    await tapText(tester, 'Suivant');
    await tapText(tester, 'Oui');
    await tapText(tester, 'Suivant');
    for (var i = 0; i < 3; i++) {
      await tapText(tester, 'Non');
      await tapText(tester, i == 2 ? 'Voir le résultat' : 'Suivant');
    }
    await snap(tester, 'orientation_resultat');
  });

  testWidgets('quiz', (tester) async {
    await pumpOnPhone(tester, phone);
    await goTo(tester, AppRoutes.quiz);
    await snap(tester, 'quiz_intro');
    await tapText(tester, 'Commencer');
    await tapText(tester, 'Oui, toujours.');
    await snap(tester, 'quiz_question');
    await tapText(tester, 'Valider');
    await snap(tester, 'quiz_correction');
  });

  testWidgets('bienvenue et inscription', (tester) async {
    await pumpOnPhone(tester, phone, prefs: {});
    await snap(tester, 'bienvenue');
    await tapText(tester, 'Créer un compte');
    await snap(tester, 'inscription_1');
    await scrollPage(tester, 400);
    await snap(tester, 'inscription_2');
  });

  testWidgets('connectée : accueil et mon espace', (tester) async {
    const session = '{"token":"t","user":{"id":"1","firstName":"Aïcha",'
        '"identifier":"+22670123456"}}';
    await pumpOnPhone(tester, phone,
        prefs: {'auth_status': 'signedIn', 'auth_session': session});
    await snap(tester, 'accueil_connectee');
    await goTo(tester, AppRoutes.profile);
    await snap(tester, 'mon_espace');
  });

  testWidgets('assistant', (tester) async {
    await pumpOnPhone(tester, phone);
    await goTo(tester, AppRoutes.assistant);
    await snap(tester, 'assistant_accueil');
    await tapText(tester, 'Une boule dans le sein signifie-t-elle toujours un cancer ?');
    await snap(tester, 'assistant_reponse');
    await tester.enterText(find.byType(TextField),
        'Mon sein est rouge et chaud, j’ai de la fièvre');
    await tester.pump();
    await tester.tap(find.byTooltip('Envoyer'));
    await tester.pumpAndSettle();
    await snap(tester, 'assistant_urgence');
  });

  testWidgets('confidentialité', (tester) async {
    await pumpOnPhone(tester, phone);
    await goTo(tester, AppRoutes.privacy);
    await snap(tester, 'confidentialite');
  });
}
