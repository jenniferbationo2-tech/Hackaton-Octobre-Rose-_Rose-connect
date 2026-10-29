import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rose_connect/features/auth/auth_service.dart';

import 'test_app.dart';

/// Fait défiler jusqu'au widget, redessine, puis tape dessus.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

void main() {
  group('Identifiant', () {
    test('accepte un e-mail et le met en minuscules', () {
      expect(Identifier.normalize(' Aicha@Mail.BF '), 'aicha@mail.bf');
    });

    test('accepte un numéro burkinabè sous plusieurs formes', () {
      expect(Identifier.normalize('70 12 34 56'), '+22670123456');
      expect(Identifier.normalize('+226 70123456'), '+22670123456');
      expect(Identifier.normalize('0022670123456'), '+22670123456');
    });

    test('refuse les saisies invalides', () {
      expect(Identifier.normalize('7012'), isNull);
      expect(Identifier.normalize('aicha@'), isNull);
      expect(Identifier.normalize(''), isNull);
    });
  });

  testWidgets('premier lancement : bienvenue puis accueil sans compte',
      (tester) async {
    await tester.pumpWidget(await buildTestApp(prefs: {}));
    await tester.pumpAndSettle();

    expect(find.text('Créer un compte'), findsOneWidget);
    await tester.tap(find.text('Continuer sans compte'));
    await tester.pumpAndSettle();

    expect(find.text('ROSE Connect'), findsOneWidget);
    expect(find.text('Accueil'), findsOneWidget);
  });

  testWidgets('inscription, accueil personnalisé, déconnexion puis connexion',
      (tester) async {
    // Écran haut : tous les éléments des formulaires sont construits.
    tester.view
      ..devicePixelRatio = 2
      ..physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(await buildTestApp(prefs: {}));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();

    Finder field(String label) =>
        find.widgetWithText(TextFormField, label);

    // Envoi à vide : les erreurs s'affichent, aucun compte n'est créé.
    await tapVisible(tester, find.text('Créer mon compte'));
    await tester.pumpAndSettle();
    expect(
      find.text('Vous devez accepter les conditions pour créer un compte.'),
      findsOneWidget,
    );
    expect(find.textContaining(', Aïcha'), findsNothing);

    await tester.enterText(field('Prénom ou pseudonyme'), 'Aïcha');
    await tester.enterText(
        field('E-mail ou numéro de téléphone'), '70 12 34 56');
    await tester.enterText(field('Mot de passe'), 'motdepasse1');
    await tester.enterText(field('Confirmer le mot de passe'), 'motdepasse1');
    await tapVisible(tester, find.byType(Checkbox));
    await tapVisible(tester, find.text('Créer mon compte'));
    await tester.pumpAndSettle();

    expect(find.textContaining(', Aïcha'), findsOneWidget);

    // Mon espace puis déconnexion : retour en mode sans compte.
    await tester.tap(find.bySemanticsLabel('Mon espace'));
    await tester.pumpAndSettle();
    expect(find.text('+22670123456'), findsOneWidget);
    await tapVisible(tester, find.text('Se déconnecter'));
    await tester.pumpAndSettle();
    expect(find.text('Vous utilisez ROSE Connect sans compte.'), findsOneWidget);

    // Connexion avec un mauvais mot de passe, puis le bon.
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    await tester.enterText(
        field('E-mail ou numéro de téléphone'), '+226 70123456');
    await tester.enterText(field('Mot de passe'), 'mauvais');
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Identifiant ou mot de passe incorrect.'), findsOneWidget);

    await tester.enterText(field('Mot de passe'), 'motdepasse1');
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pumpAndSettle();
    expect(find.textContaining(', Aïcha'), findsOneWidget);
  });
}
