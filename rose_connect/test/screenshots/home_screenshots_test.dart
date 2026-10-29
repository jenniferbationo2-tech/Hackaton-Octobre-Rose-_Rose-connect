@Tags(['screenshots'])
library;

import 'package:flutter_test/flutter_test.dart';

import 'screenshot_helpers.dart';

/// Captures d'écran de contrôle visuel (non comparées en CI).
/// flutter test --tags screenshots --run-skipped --update-goldens
void main() {
  setUpAll(loadAppFonts);

  for (final phone in phones) {
    testWidgets('accueil ${phone.name}', (tester) async {
      await pumpOnPhone(tester, phone);
      await snap(tester, 'home_${phone.name}_1');
      await scrollPage(tester, phone.size.height * 0.7);
      await snap(tester, 'home_${phone.name}_2');
      await scrollPage(tester, phone.size.height * 0.7);
      await snap(tester, 'home_${phone.name}_3');
    });
  }

  testWidgets('accueil texte agrandi 130 %', (tester) async {
    await pumpOnPhone(tester, phones.first, textScale: 1.3, height: 2600);
    await snap(tester, 'home_petit_texte130_pleine_page');
  });
}
