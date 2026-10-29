import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/services/links.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/education_item.dart';
import 'chat_message.dart';

const _bubbleRadius = 18.0;

/// Bulle de l'assistant, alignée à gauche.
class AssistantBubbleFrame extends StatelessWidget {
  const AssistantBubbleFrame({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
  });

  final Widget child;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.86),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(_bubbleRadius),
              bottomLeft: Radius.circular(_bubbleRadius),
              bottomRight: Radius.circular(_bubbleRadius),
            ),
          ),
          child: DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.bodyMedium,
            child: child,
          ),
        ),
      ),
    );
  }
}

class MessageView extends StatelessWidget {
  const MessageView({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) => message.role == ChatRole.user
      ? _UserBubble(message: message)
      : _AssistantMessage(message: message);
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.primaryStrong,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_bubbleRadius),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(_bubbleRadius),
                  bottomRight: Radius.circular(_bubbleRadius),
                ),
              ),
              child: Text(
                message.text,
                style: textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
            if (message.failed)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 14, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text('Sans réponse',
                        style: textTheme.labelSmall
                            ?.copyWith(color: AppColors.error)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AssistantMessage extends StatelessWidget {
  const _AssistantMessage({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final urgent = message.kind == ReplyKind.urgent;

    return AssistantBubbleFrame(
      color: urgent ? AppColors.urgentTint : AppColors.surface,
      borderColor: urgent ? AppColors.urgent : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (urgent)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.local_hospital_outlined,
                      color: AppColors.urgent, size: 20),
                  const SizedBox(width: 8),
                  Text('Consultez rapidement',
                      style: textTheme.titleSmall
                          ?.copyWith(color: AppColors.urgent)),
                ],
              ),
            ),
          if (message.kind == ReplyKind.prepared)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Réponse préparée à l’avance',
                      style: textTheme.labelSmall
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          Text(message.text),
          if (message.sources.isNotEmpty) ...[
            const SizedBox(height: 10),
            _SourcesLine(sources: message.sources),
          ],
          if (message.educationId != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 40),
                ),
                onPressed: () =>
                    context.go(AppRoutes.educationDetail(message.educationId!)),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Lire la fiche'),
              ),
            ),
          if (message.kind != ReplyKind.none) ...[
            const SizedBox(height: 6),
            Text(
              'Information générale, pas un diagnostic médical.',
              style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _SourcesLine extends StatelessWidget {
  const _SourcesLine({required this.sources});

  final List<Source> sources;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sources.length > 1 ? 'Sources' : 'Source',
            style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
        for (final source in sources)
          InkWell(
            onTap: source.url == null
                ? null
                : () => openExternalLink(context, source.url!),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                source.label,
                style: textTheme.bodySmall?.copyWith(
                  color: source.url == null
                      ? AppColors.textMuted
                      : AppColors.secondaryStrong,
                  decoration:
                      source.url == null ? null : TextDecoration.underline,
                  decorationColor: AppColors.secondaryStrong,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SuggestionTile extends StatelessWidget {
  const SuggestionTile({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_outline,
                  size: 18, color: AppColors.primaryStrong),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              const Icon(Icons.north_east, size: 18, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bulle « L'assistant écrit… » avec trois points animés.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'L’assistant écrit une réponse',
      child: AssistantBubbleFrame(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) => Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textMuted.withValues(
                          alpha: _dotOpacity(_animation.value, i),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'L’assistant écrit…',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  double _dotOpacity(double t, int index) {
    final phase = (t - index * 0.2) % 1.0;
    return phase < 0.5 ? 0.3 + phase * 1.4 : 1.0 - (phase - 0.5) * 1.4;
  }
}

class ChatErrorCard extends StatelessWidget {
  const ChatErrorCard({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.errorTint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.cloud_off_outlined,
                    color: AppColors.error, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$message Vérifiez votre connexion puis réessayez.',
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Réessayer'),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.education),
                  child: const Text('Consulter les fiches'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Zone de saisie : bouton désactivé si vide ou pendant le traitement.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.enabled,
    required this.maxLength,
    required this.onSend,
  });

  final bool enabled;
  final int maxLength;
  final ValueChanged<String> onSend;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSend => widget.enabled && _controller.text.trim().isNotEmpty;

  void _send() {
    if (!_canSend) return;
    widget.onSend(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final length = _controller.text.length;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: widget.maxLength,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Écrivez votre question',
                    fillColor: AppColors.canvas,
                    // Compteur affiché seulement près de la limite.
                    counterText: length > widget.maxLength - 100
                        ? '$length / ${widget.maxLength}'
                        : '',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: EdgeInsets.only(
                    bottom: length > widget.maxLength - 100 ? 22 : 0),
                child: IconButton.filled(
                  tooltip: 'Envoyer',
                  onPressed: _canSend ? _send : null,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryStrong,
                    disabledBackgroundColor: AppColors.border,
                    minimumSize: const Size(48, 48),
                  ),
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
