import 'package:flutter_test/flutter_test.dart';

import 'package:rose_connect/features/education/education_detail_screen.dart';
import 'package:rose_connect/features/home/article_carousel.dart';

import 'test_app.dart';

void main() {
  testWidgets('les articles défilent d’eux-mêmes et ouvrent la fiche',
      (tester) async {
    await tester.pumpWidget(await buildTestApp());
    await tester.pumpAndSettle();

    // Premier article visible au départ.
    expect(find.bySemanticsLabel('Article 1 sur 5'), findsOneWidget);

    // Après l'intervalle, le carrousel passe à l'article suivant.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Article 2 sur 5'), findsOneWidget);

    // Toucher une bulle ouvre l'article correspondant.
    await tester.tap(find.descendant(
      of: find.byType(ArticleBubble),
      matching: find.text('Les signes à connaître'),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(EducationDetailScreen), findsOneWidget);
  });
}
