import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/api_client.dart';
import '../../models/education_item.dart';

final educationRepositoryProvider = Provider<EducationRepository>(
  (ref) => EducationRepository(ref.watch(apiClientProvider)),
);

final educationListProvider = FutureProvider<List<EducationItem>>(
  (ref) => ref.watch(educationRepositoryProvider).fetchAll(),
);

/// Fiche par identifiant, ou null si elle n'existe pas.
final educationItemProvider =
    FutureProvider.family<EducationItem?, String>((ref, id) async {
  final items = await ref.watch(educationListProvider.future);
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
});

class EducationRepository {
  EducationRepository(this._api);

  final ApiClient _api;

  /// API si elle est configurée, sinon (ou en cas d'échec) contenus embarqués.
  Future<List<EducationItem>> fetchAll() async {
    if (ApiClient.isConfigured) {
      try {
        final data = await _api.get<List<dynamic>>('/education');
        return _parse(data);
      } on AppException {
        // Hors ligne ou serveur indisponible : repli sur les contenus locaux.
      }
    }
    final raw = await rootBundle.loadString('assets/data/education.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return _parse(json['items'] as List<dynamic>);
  }

  List<EducationItem> _parse(List<dynamic> data) => [
        for (final entry in data)
          EducationItem.fromJson(entry as Map<String, dynamic>),
      ].where((item) => item.published).toList();
}
