import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/api_client.dart';
import 'chat_message.dart';
import 'faq_matcher.dart';

final faqProvider = FutureProvider<FaqData>((ref) async {
  final raw = await rootBundle.loadString('assets/data/faq.json');
  return FaqData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
});

final assistantRepositoryProvider = Provider<AssistantRepository>(
  (ref) => AssistantRepository(ref.watch(apiClientProvider), ref),
);

class AssistantRepository {
  AssistantRepository(this._api, this._ref);

  final ApiClient _api;
  final Ref _ref;

  /// Réponse de l'IA via l'API ; à défaut, réponse préparée.
  /// Lève [AppException] si l'IA échoue et qu'aucune réponse préparée
  /// ne correspond, pour permettre de réessayer.
  Future<AssistantReply> ask(
    String question, {
    List<ChatMessage> history = const [],
  }) async {
    final faq = await _ref.read(faqProvider.future);

    // L'urgence est détectée par des règles fixes, jamais par le modèle.
    if (FaqMatcher.isUrgent(
        question, faq.urgentKeywords, faq.urgentCombinations)) {
      return AssistantReply(text: faq.urgentAnswer, kind: ReplyKind.urgent);
    }

    if (ApiClient.isConfigured) {
      try {
        final data = await _api.post<Map<String, dynamic>>(
          '/assistant/chat',
          {
            'question': question,
            'history': [
              for (final m in history)
                {
                  'role': m.role == ChatRole.user ? 'user' : 'assistant',
                  'content': m.text,
                },
            ],
          },
          timeout: const Duration(seconds: 30),
        );
        return AssistantReply.fromApi(data);
      } on AppException {
        final prepared = _prepared(question, faq);
        if (prepared != null) return prepared;
        rethrow;
      }
    }

    // Pas d'API configurée : réponses préparées uniquement.
    return _prepared(question, faq) ??
        const AssistantReply(
          text: 'Je n’ai pas de réponse préparée pour cette question, et '
              'l’assistant en ligne n’est pas disponible pour le moment. '
              'Vous pouvez consulter les fiches de l’application ou poser '
              'votre question à un professionnel de santé.',
          kind: ReplyKind.none,
        );
  }

  AssistantReply? _prepared(String question, FaqData faq) {
    final item = FaqMatcher.match(question, faq.items);
    if (item == null) return null;
    return AssistantReply(
      text: item.answer,
      kind: ReplyKind.prepared,
      sources: item.sources,
      educationId: item.educationId,
    );
  }
}
