import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/icon_badge.dart';
import 'auth_controller.dart';

/// Premier écran : créer un compte, se connecter ou continuer sans compte.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Center(
                      child: Image.asset(
                        'assets/images/logo_full.png',
                        height: 120,
                        semanticLabel: 'ROSE Connect',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Reconnaître les signes du cancer du sein et savoir quand consulter',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _Point(
                      Icons.menu_book_outlined,
                      'Des fiches simples et sourcées',
                      AppColors.secondaryStrong,
                      AppColors.sky,
                    ),
                    const _Point(
                      Icons.auto_awesome_outlined,
                      'Un assistant pour vos questions',
                      AppColors.primaryStrong,
                      AppColors.roseTint,
                    ),
                    const _Point(
                      Icons.fact_check_outlined,
                      'Savoir quand consulter',
                      AppColors.tertiaryStrong,
                      AppColors.mintTint,
                    ),
                    const Spacer(),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: () => context.push(AppRoutes.register),
                      child: const Text('Créer un compte'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => context.push(AppRoutes.login),
                      child: const Text('Se connecter'),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => ref
                          .read(authControllerProvider.notifier)
                          .continueAsGuest(),
                      child: const Text('Continuer sans compte'),
                    ),
                    Text(
                      'Le compte est facultatif.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point(this.icon, this.text, this.color, this.tint);

  final IconData icon;
  final String text;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          IconBadge(icon, color: color, tint: tint),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
