import 'package:flutter_test/flutter_test.dart';

import 'package:rose_connect/core/audio/audio.dart';
import 'package:rose_connect/core/audio/listen_button.dart';

import 'test_app.dart';

void main() {
  group('choix de l’enregistrement', () {
    const catalog = {
      'assets/audio/dyu/orientation-q1.m4a',
      'assets/audio/fr/orientation-q1.m4a',
      'assets/audio/fr/orientation-q2.mp3',
    };

    test('joue la langue choisie si elle existe', () {
      expect(resolveClip(catalog, ListenLanguage.dyu, 'orientation-q1'),
          'assets/audio/dyu/orientation-q1.m4a');
    });

    test('revient au français si la langue choisie manque', () {
      final path = resolveClip(catalog, ListenLanguage.dyu, 'orientation-q2');
      expect(path, 'assets/audio/fr/orientation-q2.mp3');
      expect(languageOf(path), ListenLanguage.fr);
    });

    test('aucun bouton si aucun enregistrement', () {
      expect(resolveClip(catalog, ListenLanguage.dyu, 'orientation-q3'), isNull);
    });
  });

  Future<void> openQuestionnaire(WidgetTester tester, Set<String> catalog) async {
    await tester.pumpWidget(await buildTestApp(
      prefs: {...guestPrefs, 'listen_language': 'dyu'},
      overrides: [audioCatalogProvider.overrideWith((ref) async => catalog)],
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Orientation').last);
    await tester.pumpAndSettle();
  }

  testWidgets('sans enregistrement, pas de bouton Écouter', (tester) async {
    await openQuestionnaire(tester, {});
    expect(find.byType(ListenButton), findsOneWidget);
    expect(find.textContaining('Écouter'), findsNothing);
  });

  testWidgets('avec un enregistrement en dioula, le bouton apparaît',
      (tester) async {
    await openQuestionnaire(tester, {'assets/audio/dyu/orientation-intro.m4a'});
    expect(find.text('Écouter · Dioula'), findsOneWidget);
  });
}
