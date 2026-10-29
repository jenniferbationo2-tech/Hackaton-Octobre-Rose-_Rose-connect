import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/icon_badge.dart';
import '../../core/widgets/icon_facts.dart';
import 'quiz_engine.dart';

class QuizIntroScreen extends ConsumerWidget {
  const QuizIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final count = ref.watch(quizQuestionsProvider).value?.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen, 8, AppSpacing.screen, AppSpacing.md),
                children: [
                  const IconBadge(Icons.quiz_outlined,
                      color: AppColors.primaryStrong,
                      tint: AppColors.roseTint,
                      size: 56),
                  const SizedBox(height: AppSpacing.md),
                  Text('Testez vos connaissances',
                      style: textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.lg),
                  IconFacts(facts: [
                    (Icons.format_list_numbered,
                        '${count ?? 'Quelques'} questions'),
                    (Icons.schedule, '3 minutes'),
                    (Icons.lightbulb_outline, 'Réponses expliquées'),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Le score mesure vos connaissances, pas votre santé.',
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen, 8, AppSpacing.screen, AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: count == null
                      ? null
                      : () {
                          ref.read(quizControllerProvider.notifier).restart();
                          context.go(AppRoutes.quizPlay);
                        },
                  child: const Text('Commencer'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
