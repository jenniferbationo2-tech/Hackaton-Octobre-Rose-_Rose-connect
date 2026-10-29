import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rose_connect/app.dart';
import 'package:rose_connect/core/services/preferences.dart';
import 'package:rose_connect/features/assistant/assistant_repository.dart';
import 'package:rose_connect/features/assistant/faq_matcher.dart';
import 'package:rose_connect/features/education/education_repository.dart';
import 'package:rose_connect/models/education_item.dart';

/// Préférences d'une utilisatrice qui a déjà choisi « Continuer sans compte ».
const guestPrefs = <String, Object>{'auth_status': 'guest'};

Map<String, dynamic> _readAsset(String name) =>
    jsonDecode(File('assets/data/$name').readAsStringSync())
        as Map<String, dynamic>;

/// Contenus lus directement sur le disque : le chargement par le bundle
/// d'assets ne se termine pas toujours dans l'environnement de test.
final testEducation = [
  for (final e in _readAsset('education.json')['items'] as List)
    EducationItem.fromJson(e as Map<String, dynamic>),
];
final testFaq = FaqData.fromJson(_readAsset('faq.json'));

/// Application prête à tester, avec des préférences simulées.
Future<Widget> buildTestApp({
  Map<String, Object> prefs = guestPrefs,
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final instance = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(instance),
      educationListProvider.overrideWith((ref) async => testEducation),
      faqProvider.overrideWith((ref) async => testFaq),
      ...overrides,
    ],
    child: const RoseConnectApp(),
  );
}
