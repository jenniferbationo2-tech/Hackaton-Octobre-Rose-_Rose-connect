import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/listen_button.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../core/widgets/icon_badge.dart';
import '../../core/widgets/state_views.dart';
import 'orientation_engine.dart';

class OrientationResultScreen extends ConsumerWidget {
  const OrientationResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(orientationContentProvider);
    final answers = ref.watch(orientationAnswersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat'),
        automaticallyImplyLeading: false,
      ),
      body: content.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          onRetry: () => ref.invalidate(orientationContentProvider),
        ),
        data: (content) {
          final complete =
              content.questions.every((q) => answers.containsKey(q.id));
          if (!complete) {
            // Accès direct sans avoir répondu : pas de résultat à montrer.
            return EmptyView(
              message: 'Répondez au questionnaire pour obtenir un message '
                  'd’orientation.',
              icon: Icons.fact_check_outlined,
              action: FilledButton(
                onPressed: () => context.go(AppRoutes.orientation),
                child: const Text('Commencer le questionnaire'),
              ),
            );
          }
          final guidance = computeGuidance(content.questions, answers);
          return _Result(
            guidance: guidance,
            message: content.messages[guidance]!,
          );
        },
      ),
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.guidance, required this.message});

  final Guidance guidance;
  final GuidanceMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final (icon, color, tint) = switch (guidance) {
      Guidance.urgent => (
          Icons.local_hospital_outlined,
          AppColors.urgent,
          AppColors.urgentTint,
        ),
      Guidance.change => (
          Icons.event_available_outlined,
          AppColors.primaryStrong,
          AppColors.roseTint,
        ),
      Guidance.unsure => (
          Icons.help_outline,
          AppColors.secondaryStrong,
          AppColors.sky,
        ),
      Guidance.none => (
          Icons.check_circle_outline,
          AppColors.tertiaryStrong,
          AppColors.mintTint,
        ),
    };

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen, 8, AppSpacing.screen, AppSpacing.xl),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: guidance == Guidance.urgent
                  ? Border.all(color: AppColors.urgent, width: 1.5)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBadge(icon,
                    color: color, tint: AppColors.surface, size: 48),
                const SizedBox(height: 14),
                Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(message.title,
                      style: textTheme.headlineSmall?.copyWith(color: color)),
                ),
                const SizedBox(height: 8),
                Text(message.message, style: textTheme.bodyLarge),
                const SizedBox(height: 12),
                ListenButton(clipId: 'orientation-result-${guidance.name}'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Ce questionnaire ne permet ni de confirmer ni d’exclure une maladie. '
            'Il ne remplace pas l’avis d’un professionnel de santé.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Et maintenant ?', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () =>
                context.go(AppRoutes.educationDetail('signes-sein')),
            icon: const Icon(Icons.menu_book_rounded, size: 20),
            label: const Text('Lire les signes à connaître'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.assistant),
            icon: const Icon(Icons.auto_awesome, size: 20),
            label: const Text('Poser une question à l’assistant'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              ref.read(orientationAnswersProvider.notifier).reset();
              context.go(AppRoutes.orientation);
            },
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Recommencer le questionnaire'),
          ),
          const SizedBox(height: AppSpacing.md),
          const DisclaimerBanner(),
        ],
      ),
    );
  }
}
