import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../test_app.dart';

/// Téléphones de référence (taille logique en dp).
class Phone {
  const Phone(this.name, this.size, {this.top = 24, this.bottom = 16});

  final String name;
  final Size size;
  final double top;
  final double bottom;
}

const phones = [
  Phone('petit_360x640', Size(360, 640)),
  Phone('moyen_393x852', Size(393, 852), top: 47, bottom: 34),
  Phone('grand_412x915', Size(412, 915)),
];

const _dpr = 2.0;

/// Les tests utilisent une police de substitution : on charge les vraies.
Future<void> loadAppFonts() async {
  const families = {
    'PlusJakartaSans': ['Medium', 'SemiBold', 'Bold'],
    'Inter': ['Regular', 'Medium', 'SemiBold', 'Bold'],
  };
  for (final MapEntry(key: family, value: styles) in families.entries) {
    final loader = FontLoader(family);
    for (final style in styles) {
      loader.addFont(rootBundle.load('assets/fonts/$family-$style.ttf'));
    }
    await loader.load();
  }
  await (FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
      .load();
}

/// Lance l'application sur le téléphone simulé, barre d'état comprise.
Future<void> pumpOnPhone(
  WidgetTester tester,
  Phone phone, {
  double textScale = 1.0,
  double? height,
  Map<String, Object> prefs = guestPrefs,
  List<Override> overrides = const [],
}) async {
  final size = Size(phone.size.width, height ?? phone.size.height);
  tester.view
    ..devicePixelRatio = _dpr
    ..physicalSize = size * _dpr
    ..padding = FakeViewPadding(top: phone.top * _dpr, bottom: phone.bottom * _dpr)
    ..viewPadding =
        FakeViewPadding(top: phone.top * _dpr, bottom: phone.bottom * _dpr);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
      await buildTestApp(prefs: prefs, overrides: overrides));
  await tester.pumpAndSettle();
  // Décode les images (logo) avant la capture.
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      final image = element.widget as Image;
      await precacheImage(image.image, element);
    }
  });
  await tester.pumpAndSettle();
}

Future<void> snap(WidgetTester tester, String name) => expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );

/// Fait défiler la page principale (verticale) de [dy] pixels.
Future<void> scrollPage(WidgetTester tester, double dy) async {
  final page = find
      .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down)
      .first;
  await tester.drag(page, Offset(0, -dy));
  await tester.pumpAndSettle();
}
