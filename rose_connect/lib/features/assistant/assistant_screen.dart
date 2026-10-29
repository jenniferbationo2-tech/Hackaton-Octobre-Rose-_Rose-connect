import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_views.dart';
import 'assistant_controller.dart';
import 'assistant_repository.dart';
import 'chat_widgets.dart';
import 'faq_matcher.dart';

class AssistantScreen extends ConsumerWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assistantControllerProvider);
    final controller = ref.read(assistantControllerProvider.notifier);
    final hasConversation = state.messages.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant ROSE Connect'),
        actions: [
          if (hasConversation)
            IconButton(
              tooltip: 'Nouvelle conversation',
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: state.sending ? null : controller.reset,
            ),
        ],
      ),
      body: Column(
        children: [
          const _NoticeBar(),
          Expanded(
            child: hasConversation
                ? _Conversation(state: state)
                : const _Welcome(),
          ),
          ChatInputBar(
            enabled: !state.sending,
            maxLength: AssistantController.maxLength,
            onSend: controller.send,
          ),
        ],
      ),
    );
  }
}

/// Rappel permanent des limites de l'assistant.
class _NoticeBar extends StatelessWidget {
  const _NoticeBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.sky,
        border: Border(bottom: BorderSide(color: AppColors.skyBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              size: 18, color: AppColors.secondaryStrong),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Information générale, pas un diagnostic.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Welcome extends ConsumerWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final faq = ref.watch(faqProvider);
    final send = ref.read(assistantControllerProvider.notifier).send;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, AppSpacing.md, AppSpacing.screen, AppSpacing.md),
      children: [
        const AssistantBubbleFrame(
          child: Text(
            'Bonjour. Posez-moi votre question sur la santé des seins.',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Questions fréquentes', style: textTheme.titleMedium),
        const SizedBox(height: 10),
        faq.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: LoadingView(),
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (faq) => Column(
            children: [
              for (final FaqItem item in faq.suggestions) ...[
                SuggestionTile(
                  label: item.question,
                  onTap: () => send(item.question),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Conversation extends ConsumerWidget {
  const _Conversation({required this.state});

  final AssistantState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(assistantControllerProvider.notifier);
    // Liste inversée : le dernier message reste collé en bas de l'écran.
    final items = <Widget>[
      if (state.sending) const TypingIndicator(),
      if (state.error != null)
        ChatErrorCard(message: state.error!, onRetry: controller.retry),
      for (final message in state.messages.reversed) MessageView(message: message),
    ];

    return ListView.separated(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, AppSpacing.md, AppSpacing.screen, AppSpacing.md),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => items[index],
    );
  }
}
