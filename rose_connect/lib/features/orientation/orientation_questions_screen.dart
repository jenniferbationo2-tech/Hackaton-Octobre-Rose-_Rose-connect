import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/audio.dart';
import '../../core/audio/listen_button.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/choice_tile.dart';
import '../../core/widgets/state_views.dart';
import '../../core/widgets/step_progress.dart';
import 'orientation_engine.dart';

const _answerLabels = {
  Answer.yes: 'Oui',
  Answer.no: 'Non',
  Answer.unsure: 'Je ne sais pas',
};

// Pictogrammes : les réponses se reconnaissent sans lire.
const _answerSymbols = {
  Answer.yes: Icons.check_circle_outline,
  Answer.no: Icons.highlight_off,
  Answer.unsure: Icons.help_outline,
};

class OrientationQuestionsScreen extends ConsumerStatefulWidget {
  const OrientationQuestionsScreen({super.key});

  @override
  ConsumerState<OrientationQuestionsScreen> createState() =>
      _OrientationQuestionsScreenState();
}

class _OrientationQuestionsScreenState
    extends ConsumerState<OrientationQuestionsScreen> {
  int _index = 0;

  /// Change de question et arrête l'écoute en cours.
  void _move(int delta) {
    ref.read(audioControllerProvider.notifier).stop();
    setState(() => _index += delta);
  }

  Future<bool> _confirmExit() async {
    if (ref.read(orientationAnswersProvider).isEmpty) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter le questionnaire ?'),
        content: const Text('Vos réponses ne seront pas conservées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuer'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  Future<void> _exit() async {
    if (await _confirmExit() && mounted) {
      ref.read(orientationAnswersProvider.notifier).reset();
      context.go(AppRoutes.orientation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(orientationContentProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_index > 0) {
          _move(-1);
        } else {
          _exit();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Questionnaire'),
          leading: IconButton(
            tooltip: 'Quitter le questionnaire',
            icon: const Icon(Icons.close),
            onPressed: _exit,
          ),
        ),
        body: content.when(
          loading: () => const LoadingView(),
          error: (_, _) => ErrorView(
            message: 'Le questionnaire n’a pas pu être chargé.',
            onRetry: () => ref.invalidate(orientationContentProvider),
          ),
          data: (content) => _buildStep(context, content),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, OrientationContent content) {
    final textTheme = Theme.of(context).textTheme;
    final questions = content.questions;
    final question = questions[_index];
    final answers = ref.watch(orientationAnswersProvider);
    final selected = answers[question.id];
    final isLast = _index == questions.length - 1;

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              // Nouvelle question : on repart du haut de l'écran.
              key: ValueKey(question.id),
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen, 8, AppSpacing.screen, AppSpacing.md),
              children: [
                StepProgress(current: _index + 1, total: questions.length),
                const SizedBox(height: AppSpacing.lg),
                Semantics(
                  header: true,
                  child: Text(question.text, style: textTheme.headlineSmall),
                ),
                if (question.help != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    question.help!,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ListenButton(clipId: 'orientation-${question.id}'),
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final answer in Answer.values) ...[
                  ChoiceTile(
                    label: _answerLabels[answer]!,
                    symbol: _answerSymbols[answer],
                    state: selected == answer
                        ? ChoiceState.selected
                        : ChoiceState.idle,
                    onTap: () => ref
                        .read(orientationAnswersProvider.notifier)
                        .answer(question.id, answer),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen, 8, AppSpacing.screen, AppSpacing.md),
            child: Row(
              children: [
                if (_index > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _move(-1),
                      child: const Text('Précédent'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: selected == null
                        ? null
                        : () {
                            if (isLast) {
                              context.go(AppRoutes.orientationResult);
                            } else {
                              _move(1);
                            }
                          },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(isLast ? 'Voir le résultat' : 'Suivant'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
