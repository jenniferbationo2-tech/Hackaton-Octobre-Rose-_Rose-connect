import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/choice_tile.dart';
import '../../core/widgets/state_views.dart';
import '../../core/widgets/step_progress.dart';
import 'quiz_engine.dart';

class QuizPlayScreen extends ConsumerWidget {
  const QuizPlayScreen({super.key});

  Future<void> _exit(BuildContext context, WidgetRef ref) async {
    final state = ref.read(quizControllerProvider);
    if (state.answers.isNotEmpty) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quitter le quiz ?'),
          content: const Text('Votre progression sera perdue.'),
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
      if (leave != true) return;
    }
    if (context.mounted) context.go(AppRoutes.quiz);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(quizQuestionsProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit(context, ref);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          leading: IconButton(
            tooltip: 'Quitter le quiz',
            icon: const Icon(Icons.close),
            onPressed: () => _exit(context, ref),
          ),
        ),
        body: questions.when(
          loading: () => const LoadingView(),
          error: (_, _) => ErrorView(
            message: 'Le quiz n’a pas pu être chargé.',
            onRetry: () => ref.invalidate(quizQuestionsProvider),
          ),
          data: (questions) => _QuestionStep(questions: questions),
        ),
      ),
    );
  }
}

class _QuestionStep extends ConsumerStatefulWidget {
  const _QuestionStep({required this.questions});

  final List<QuizQuestion> questions;

  @override
  ConsumerState<_QuestionStep> createState() => _QuestionStepState();
}

class _QuestionStepState extends ConsumerState<_QuestionStep> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Après validation, amène l'explication à l'écran.
  void _validate(QuizQuestion question) {
    ref.read(quizControllerProvider.notifier).validate(question);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _next() {
    ref.read(quizControllerProvider.notifier).next();
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.questions;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(quizControllerProvider);
    final controller = ref.read(quizControllerProvider.notifier);
    if (state.index >= questions.length) {
      return const LoadingView();
    }
    final question = questions[state.index];
    final isLast = state.index == questions.length - 1;
    final isCorrect = state.selectedOptionId == question.correctOptionId;

    ChoiceState stateFor(QuizOption option) {
      if (!state.validated) {
        return option.id == state.selectedOptionId
            ? ChoiceState.selected
            : ChoiceState.idle;
      }
      if (option.id == question.correctOptionId) return ChoiceState.correct;
      if (option.id == state.selectedOptionId) return ChoiceState.wrong;
      return ChoiceState.idle;
    }

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen, 8, AppSpacing.screen, AppSpacing.md),
              children: [
                StepProgress(current: state.index + 1, total: questions.length),
                const SizedBox(height: AppSpacing.lg),
                Semantics(
                  header: true,
                  child: Text(question.question, style: textTheme.headlineSmall),
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final option in question.options) ...[
                  ChoiceTile(
                    label: option.label,
                    state: stateFor(option),
                    onTap: state.validated
                        ? null
                        : () => controller.select(option.id),
                  ),
                  const SizedBox(height: 12),
                ],
                if (state.validated)
                  _Explanation(
                      correct: isCorrect, explanation: question.explanation),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen, 8, AppSpacing.screen, AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: !state.validated
                  ? FilledButton(
                      onPressed: state.selectedOptionId == null
                          ? null
                          : () => _validate(question),
                      child: const Text('Valider'),
                    )
                  : FilledButton(
                      onPressed: () {
                        if (isLast) {
                          context.go(AppRoutes.quizResult);
                        } else {
                          _next();
                        }
                      },
                      child: Text(isLast ? 'Voir mon résultat' : 'Question suivante'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Explanation extends StatelessWidget {
  const _Explanation({required this.correct, required this.explanation});

  final bool correct;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = correct ? AppColors.tertiaryStrong : AppColors.error;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: correct ? AppColors.mintTint : AppColors.errorTint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(correct ? Icons.check_circle : Icons.cancel,
                    color: color, size: 22),
                const SizedBox(width: 8),
                Text(
                  correct ? 'Bonne réponse' : 'Ce n’est pas la bonne réponse',
                  style: textTheme.titleMedium?.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(explanation, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
