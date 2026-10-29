import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/rose_card.dart';
import '../../core/widgets/state_views.dart';
import 'quiz_engine.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(quizQuestionsProvider);
    final state = ref.watch(quizControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Votre résultat'),
        automaticallyImplyLeading: false,
      ),
      body: questions.when(
        loading: () => const LoadingView(),
        error: (_, _) =>
            ErrorView(onRetry: () => ref.invalidate(quizQuestionsProvider)),
        data: (questions) {
          if (state.answers.length < questions.length) {
            return EmptyView(
              message: 'Terminez le quiz pour voir votre résultat.',
              icon: Icons.quiz_outlined,
              action: FilledButton(
                onPressed: () => context.go(AppRoutes.quiz),
                child: const Text('Commencer le quiz'),
              ),
            );
          }
          return _ResultBody(questions: questions, state: state);
        },
      ),
    );
  }
}

class _ResultBody extends ConsumerWidget {
  const _ResultBody({required this.questions, required this.state});

  final List<QuizQuestion> questions;
  final QuizState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final correct = state.correctCount(questions);
    final total = questions.length;
    final percent = (correct * 100 / total).round();
    final comment = switch (correct / total) {
      >= 0.8 => 'Très bien, vous connaissez l’essentiel.',
      >= 0.5 => 'Bonne base. Les explications ci-dessous complètent vos connaissances.',
      _ => 'Les fiches éducatives vous aideront à approfondir ces sujets.',
    };

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen, 8, AppSpacing.screen, AppSpacing.xl),
        children: [
          RoseCard(
            color: AppColors.roseTint,
            borderColor: AppColors.roseTint,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bonnes réponses',
                    style: textTheme.labelMedium
                        ?.copyWith(color: AppColors.deepBerry)),
                const SizedBox(height: 4),
                Semantics(
                  label: '$correct bonnes réponses sur $total',
                  excludeSemantics: true,
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: '$correct',
                        style: textTheme.headlineLarge
                            ?.copyWith(fontSize: 40, color: AppColors.deepBerry),
                      ),
                      TextSpan(
                        text: ' / $total',
                        style: textTheme.headlineSmall
                            ?.copyWith(color: AppColors.deepBerry),
                      ),
                    ]),
                  ),
                ),
                Text('$percent % de réussite',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.deepBerry)),
                const SizedBox(height: 12),
                Text(comment, style: textTheme.bodyLarge),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ce score mesure vos connaissances, pas votre santé.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Revoir les réponses', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          RoseCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < questions.length; i++) ...[
                  if (i > 0) const Divider(),
                  _AnswerReview(
                    number: i + 1,
                    question: questions[i],
                    answerId: state.answers[questions[i].id],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () {
              ref.read(quizControllerProvider.notifier).restart();
              context.go(AppRoutes.quizPlay);
            },
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Recommencer le quiz'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.education),
            icon: const Icon(Icons.menu_book_rounded, size: 20),
            label: const Text('Consulter les fiches'),
          ),
        ],
      ),
    );
  }
}

class _AnswerReview extends StatelessWidget {
  const _AnswerReview({
    required this.number,
    required this.question,
    required this.answerId,
  });

  final int number;
  final QuizQuestion question;
  final String? answerId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final correct = answerId == question.correctOptionId;
    final correctLabel = question.options
        .firstWhere((o) => o.id == question.correctOptionId)
        .label;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        leading: Icon(
          correct ? Icons.check_circle : Icons.cancel,
          color: correct ? AppColors.tertiaryStrong : AppColors.error,
          semanticLabel: correct ? 'Bonne réponse' : 'Mauvaise réponse',
        ),
        title: Text('$number. ${question.question}',
            style: textTheme.bodyMedium),
        children: [
          Text('Bonne réponse : $correctLabel',
              style: textTheme.titleSmall
                  ?.copyWith(color: AppColors.tertiaryStrong)),
          const SizedBox(height: 6),
          Text(question.explanation, style: textTheme.bodyMedium),
          if (question.educationId != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context
                    .go(AppRoutes.educationDetail(question.educationId!)),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Lire la fiche'),
              ),
            ),
        ],
      ),
    );
  }
}
