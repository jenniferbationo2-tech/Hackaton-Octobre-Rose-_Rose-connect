import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/icon_badge.dart';
import '../../core/widgets/rose_card.dart';
import '../../core/widgets/state_views.dart';
import '../../core/utils/typography.dart';
import '../../models/education_item.dart';
import '../home/article_carousel.dart' show readingMinutes;
import 'education_repository.dart';
import 'education_visuals.dart';

class EducationListScreen extends ConsumerWidget {
  const EducationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(educationListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Comprendre le cancer du sein')),
      body: items.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          message: 'Les contenus n’ont pas pu être chargés.',
          onRetry: () => ref.invalidate(educationListProvider),
        ),
        data: (items) => items.isEmpty
            ? const EmptyView(
                message: 'Aucun contenu n’est disponible pour le moment.',
                icon: Icons.menu_book_outlined,
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(educationListProvider.future),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen, 8, AppSpacing.screen, AppSpacing.lg),
                  children: [
                    for (final item in items) ...[
                      _EducationCard(item: item),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard({required this.item});

  final EducationItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visual = visualFor(item.category);
    return RoseCard(
      onTap: () => context.go(AppRoutes.educationDetail(item.id)),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(visual.icon, color: visual.color, tint: visual.tint),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visual.label.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: visual.color,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(frenchSpacing(item.title), style: textTheme.titleMedium),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${readingMinutes(item)} min de lecture',
                      style: textTheme.labelSmall
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Icon(Icons.chevron_right, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
