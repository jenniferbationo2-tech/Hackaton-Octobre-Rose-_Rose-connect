import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/listen_button.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/icon_badge.dart';
import '../../core/widgets/icon_facts.dart';
import 'orientation_engine.dart';

class OrientationIntroScreen extends ConsumerWidget {
  const OrientationIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final count = ref.watch(orientationContentProvider).value?.questions.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Questionnaire d’orientation')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen, 8, AppSpacing.screen, AppSpacing.md),
                children: [
                  const IconBadge(Icons.fact_check_outlined,
                      color: AppColors.tertiaryStrong,
                      tint: AppColors.mintTint,
                      size: 56),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Faisons le point sur ce que vous avez remarqué',
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: ListenButton(clipId: 'orientation-intro'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  IconFacts(facts: [
                    (Icons.format_list_numbered,
                        '${count ?? 'Quelques'} questions'),
                    (Icons.schedule, '1 minute'),
                    (Icons.phonelink_lock, 'Rien n’est enregistré'),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ce n’est pas un diagnostic : il ne dit pas si vous avez un cancer.',
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ),
                    ],
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
                  onPressed: () {
                    ref.read(orientationAnswersProvider.notifier).reset();
                    context.go(AppRoutes.orientationQuestions);
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
