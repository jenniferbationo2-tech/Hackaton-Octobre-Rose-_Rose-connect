import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/listen_button.dart';
import '../../core/router/app_router.dart';
import '../../core/services/links.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/typography.dart';
import '../../core/widgets/content_icons.dart';
import '../../core/widgets/icon_badge.dart';
import '../../core/widgets/state_views.dart';
import '../../core/widgets/true_false_card.dart';
import '../../models/education_item.dart';
import 'education_repository.dart';
import 'education_visuals.dart';

class EducationDetailScreen extends ConsumerWidget {
  const EducationDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(educationItemProvider(id));
    return Scaffold(
      appBar: AppBar(),
      body: item.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          message: 'Ce contenu n’a pas pu être chargé.',
          onRetry: () => ref.invalidate(educationListProvider),
        ),
        data: (item) => item == null
            ? EmptyView(
                message: 'Ce contenu est introuvable ou n’est plus disponible.',
                icon: Icons.search_off,
                action: FilledButton(
                  onPressed: () => context.go(AppRoutes.education),
                  child: const Text('Retour à la liste'),
                ),
              )
            : _Article(item: item),
      ),
    );
  }
}

class _Article extends StatelessWidget {
  const _Article({required this.item});

  final EducationItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visual = visualFor(item.category);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
      children: [
        Row(
          children: [
            IconBadge(visual.icon,
                color: visual.color, tint: visual.tint, size: 32),
            const SizedBox(width: 10),
            Text(
              visual.label.toUpperCase(),
              style: textTheme.labelSmall
                  ?.copyWith(color: visual.color, letterSpacing: 0.6),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(frenchSpacing(item.title),
              style: textTheme.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (hasKeyPoints) ...[
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('L’essentiel', style: textTheme.titleLarge),
              ListenButton(clipId: 'edu-${item.id}'),
            ],
          ),
          const SizedBox(height: 12),
          _KeyPointsGrid(points: item.keyPoints, color: visual.color, tint: visual.tint),
          const SizedBox(height: AppSpacing.md),
          // Le texte complet reste disponible, replié.
          _Details(
            children: [
              for (final block in item.blocks) _BlockView(block: block),
              if (item.sources.isNotEmpty) _Sources(sources: item.sources),
            ],
          ),
        ] else ...[
          for (final block in item.blocks) _BlockView(block: block),
          if (item.sources.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _Sources(sources: item.sources),
          ],
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.auto_awesome,
                label: 'Poser une question',
                color: AppColors.secondaryStrong,
                tint: AppColors.sky,
                onTap: () => context.go(AppRoutes.assistant),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                icon: Icons.fact_check_outlined,
                label: 'Faire le point',
                color: AppColors.tertiaryStrong,
                tint: AppColors.mintTint,
                onTap: () => context.go(AppRoutes.orientation),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Information générale, pas un diagnostic.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }

  bool get hasKeyPoints => item.keyPoints.isNotEmpty;
}

/// Points clés en tuiles : une icône et quelques mots.
class _KeyPointsGrid extends StatelessWidget {
  const _KeyPointsGrid({
    required this.points,
    required this.color,
    required this.tint,
  });

  final List<KeyPoint> points;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rows = <List<KeyPoint>>[
      for (var i = 0; i < points.length; i += 2) points.skip(i).take(2).toList(),
    ];
    return Column(
      children: [
        for (final row in rows) ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = 0; j < 2; j++) ...[
                  if (j > 0) const SizedBox(width: 12),
                  Expanded(
                    child: j < row.length
                        ? Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: tint,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(contentIcon(row[j].icon),
                                    color: color, size: 28),
                                const SizedBox(height: 10),
                                Text(frenchSpacing(row[j].text),
                                    style: textTheme.titleSmall),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Texte complet de la fiche, replié par défaut.
class _Details extends StatelessWidget {
  const _Details({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          leading: const Icon(Icons.menu_book_outlined,
              color: AppColors.primaryStrong),
          title: Text('Lire la fiche complète',
              style: Theme.of(context).textTheme.titleMedium),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tint,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlockView extends StatelessWidget {
  const _BlockView({required this.block});

  final EducationBlock block;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return switch (block) {
      HeadingBlock(:final text) => Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Semantics(
            header: true,
            child: Text(text, style: textTheme.titleLarge),
          ),
        ),
      ParagraphBlock(:final text) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(text, style: textTheme.bodyLarge),
        ),
      BulletsBlock(:final items) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              for (final entry in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10, right: 12),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(child: Text(entry, style: textTheme.bodyLarge)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      CalloutBlock(:final text) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.mintTint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.tertiaryStrong, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: textTheme.bodyMedium)),
            ],
          ),
        ),
      MythBlock(:final myth, :final fact) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TrueFalseCard(statement: myth, answer: fact),
        ),
    };
  }
}

class _Sources extends StatelessWidget {
  const _Sources({required this.sources});

  final List<Source> sources;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sources.length > 1 ? 'Sources' : 'Source',
              style: textTheme.labelMedium
                  ?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          for (final source in sources)
            source.url == null
                ? Text(source.label, style: textTheme.bodySmall)
                : InkWell(
                    onTap: () => openExternalLink(context, source.url!),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              source.label,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryStrong,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.secondaryStrong,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.open_in_new,
                              size: 16, color: AppColors.secondaryStrong),
                        ],
                      ),
                    ),
                  ),
        ],
      ),
    );
  }
}
