import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/listen_button.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/icon_badge.dart';
import '../../core/widgets/rose_card.dart';
import '../../core/widgets/true_false_card.dart';
import '../../core/widgets/user_avatar.dart';
import '../../models/education_item.dart';
import '../auth/auth_controller.dart';
import '../education/education_repository.dart';
import 'article_carousel.dart';

/// Accueil volontairement épuré : un message d'accueil, des articles à lire,
/// une idée reçue du jour et trois façons d'être accompagnée.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _TopBar()),
            SliverToBoxAdapter(child: _Greeting()),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'À lire',
                actionLabel: 'Tout voir',
                route: AppRoutes.education,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverToBoxAdapter(child: _Articles()),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.screen),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  _DailyFact(),
                  SizedBox(height: AppSpacing.xl),
                  _SectionTitle('Pour vous accompagner'),
                  SizedBox(height: 14),
                  _Support(),
                  SizedBox(height: AppSpacing.xl),
                  _Footer(),
                  SizedBox(height: AppSpacing.md),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 8, 8, 0),
      child: Row(
        children: [
          Image.asset('assets/images/logo_mark.png',
              height: 30, semanticLabel: 'Logo ROSE Connect'),
          const SizedBox(width: 8),
          Flexible(
            child: Text('ROSE Connect',
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const Spacer(),
          const ListenLanguageChip(),
          Semantics(
            button: true,
            label: 'Mon espace',
            excludeSemantics: true,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.push(AppRoutes.profile),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: UserAvatar(initial: user?.initial, size: 38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Greeting extends ConsumerWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authControllerProvider).user;
    final hello = DateTime.now().hour >= 18 ? 'Bonsoir' : 'Bonjour';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, AppSpacing.lg, AppSpacing.screen, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              user == null ? hello : '$hello, ${user.firstName}',
              style: textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'La santé de vos seins, expliquée simplement.',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.route,
  });

  final String title;
  final String actionLabel;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.screen, right: 4),
      child: Row(
        children: [
          Expanded(child: _SectionTitle(title)),
          TextButton(
            onPressed: () => context.go(route),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _Articles extends ConsumerWidget {
  const _Articles();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(educationListProvider);
    return items.when(
      loading: () => const SizedBox(
        height: 232,
        child: Center(child: CircularProgressIndicator()),
      ),
      // Les contenus sont embarqués : une erreur ici reste exceptionnelle.
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        child: Text('Les articles n’ont pas pu être chargés.',
            style: Theme.of(context).textTheme.bodyMedium),
      ),
      data: (items) => ArticleCarousel(items: items),
    );
  }
}

/// Une idée reçue corrigée, différente chaque jour.
class _DailyFact extends ConsumerWidget {
  const _DailyFact();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(educationItemProvider('idees-recues')).value;
    final myths = item?.blocks.whereType<MythBlock>().toList() ?? const [];
    if (myths.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    final myth = myths[dayOfYear % myths.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: _SectionTitle('Vrai ou faux ?')),
            TextButton(
              onPressed: () =>
                  context.go(AppRoutes.educationDetail('idees-recues')),
              child: const Text('Plus'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TrueFalseCard(
          statement: myth.myth,
          answer: myth.fact,
          color: AppColors.mintTint.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}

class _Support extends StatelessWidget {
  const _Support();

  static const _rows = [
    (Icons.auto_awesome_outlined, 'Poser une question', '24 h/24',
        AppRoutes.assistant, AppColors.secondaryStrong, AppColors.sky),
    (Icons.fact_check_outlined, 'Faire le point', '1 min',
        AppRoutes.orientation, AppColors.tertiaryStrong, AppColors.mintTint),
    (Icons.quiz_outlined, 'Tester mes connaissances', '3 min',
        AppRoutes.quiz, AppColors.primaryStrong, AppColors.roseTint),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return RoseCard(
      padding: EdgeInsets.zero,
      radius: 24,
      child: Column(
        children: [
          for (var i = 0; i < _rows.length; i++) ...[
            if (i > 0) const Divider(indent: 72),
            InkWell(
              onTap: () => context.go(_rows[i].$4),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
                child: Row(
                  children: [
                    IconBadge(_rows[i].$1,
                        color: _rows[i].$5, tint: _rows[i].$6, size: 44),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(_rows[i].$2, style: textTheme.titleMedium),
                    ),
                    Text(
                      _rows[i].$3,
                      style: textTheme.labelMedium
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: AppColors.textMuted);
    return Column(
      children: [
        Text(
          'Information générale, pas un diagnostic.',
          textAlign: TextAlign.center,
          style: style,
        ),
        const SizedBox(height: 4),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            TextButton(
              onPressed: () => context.push(AppRoutes.privacy),
              child: Text('Confidentialité', style: style),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.terms),
              child: Text('Conditions d’utilisation', style: style),
            ),
          ],
        ),
      ],
    );
  }
}
