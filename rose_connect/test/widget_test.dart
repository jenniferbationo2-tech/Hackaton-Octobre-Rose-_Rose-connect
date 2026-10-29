import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';

void main() {
  testWidgets('L’accueil s’affiche et la navigation change d’onglet',
      (tester) async {
    await tester.pumpWidget(await buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('À lire'), findsOneWidget);
    expect(find.text('Lire l’article'), findsWidgets);

    await tester.tap(find.text('Quiz').last);
    await tester.pumpAndSettle();
    expect(find.text('Testez vos connaissances'), findsWidgets);
  });

  testWidgets('Les pages légales s’ouvrent depuis l’accueil', (tester) async {
    await tester.pumpWidget(await buildTestApp());
    await tester.pumpAndSettle();

    final pageScroll = find
        .byWidgetPredicate((w) =>
            w is Scrollable && w.axisDirection == AxisDirection.down)
        .first;
    await tester.scrollUntilVisible(find.text('Confidentialité'), 300,
        scrollable: pageScroll);
    await tester.tap(find.text('Confidentialité'));
    await tester.pumpAndSettle();
    expect(find.text('Politique de confidentialité'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Conditions d’utilisation'));
    await tester.pumpAndSettle();
    expect(find.text('Conditions générales d’utilisation'), findsOneWidget);
  });
}
