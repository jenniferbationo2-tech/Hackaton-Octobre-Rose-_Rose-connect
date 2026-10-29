import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/api_client.dart';
import 'assistant_repository.dart';
import 'chat_message.dart';

class AssistantState {
  const AssistantState({
    this.messages = const [],
    this.sending = false,
    this.error,
  });

  /// Du plus ancien au plus récent.
  final List<ChatMessage> messages;
  final bool sending;

  /// Message d'erreur affichable pour la dernière question.
  final String? error;
}

/// Conversation de la session, gardée en mémoire uniquement.
class AssistantController extends Notifier<AssistantState> {
  static const maxLength = 500;
  int _counter = 0;

  @override
  AssistantState build() => const AssistantState();

  String _nextId() => '${DateTime.now().microsecondsSinceEpoch}-${_counter++}';

  Future<void> send(String rawQuestion) async {
    final question = rawQuestion.trim();
    if (question.isEmpty || question.length > maxLength || state.sending) {
      return;
    }
    final message =
        ChatMessage(id: _nextId(), role: ChatRole.user, text: question);
    await _ask(message, [...state.messages, message]);
  }

  /// Renvoie la dernière question restée sans réponse.
  Future<void> retry() async {
    if (state.sending || state.messages.isEmpty) return;
    final last = state.messages.last;
    if (last.role != ChatRole.user) return;
    final messages = [
      ...state.messages.take(state.messages.length - 1),
      last.copyWith(failed: false),
    ];
    await _ask(last, messages);
  }

  void reset() => state = const AssistantState();

  Future<void> _ask(ChatMessage question, List<ChatMessage> messages) async {
    state = AssistantState(messages: messages, sending: true);
    // Contexte transmis : les 3 derniers échanges précédant la question.
    final previous = messages.take(messages.length - 1).toList();
    final history =
        previous.skip(previous.length > 6 ? previous.length - 6 : 0).toList();
    try {
      final reply = await ref
          .read(assistantRepositoryProvider)
          .ask(question.text, history: history);
      state = AssistantState(messages: [
        ...messages,
        ChatMessage(
          id: _nextId(),
          role: ChatRole.assistant,
          text: reply.text,
          kind: reply.kind,
          sources: reply.sources,
          educationId: reply.educationId,
        ),
      ]);
    } on AppException catch (e) {
      state = AssistantState(
        messages: [
          ...messages.take(messages.length - 1),
          question.copyWith(failed: true),
        ],
        error: e.type == AppErrorType.rateLimited
            ? e.message
            : 'Le service est temporairement indisponible.',
      );
    }
  }
}

final assistantControllerProvider =
    NotifierProvider<AssistantController, AssistantState>(
        AssistantController.new);
