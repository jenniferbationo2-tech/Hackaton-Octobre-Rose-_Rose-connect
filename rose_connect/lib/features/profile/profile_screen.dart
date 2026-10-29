import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/audio.dart';
import '../../core/audio/listen_button.dart';
import '../../core/constants/app_info.dart';
import '../../core/router/app_router.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/rose_card.dart';
import '../../core/widgets/user_avatar.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon espace')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen, 8, AppSpacing.screen, AppSpacing.xl),
          children: [
            RoseCard(
              padding: const EdgeInsets.all(20),
              child: user == null ? const _GuestCard() : _UserCard(user: user),
            ),
            if (user != null) ...[
              const SizedBox(height: 12),
              const _AccountActions(),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text('À propos', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            const _AboutCard(),
            const SizedBox(height: AppSpacing.md),
            RoseCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.record_voice_over_outlined),
                    title: const Text('Langue d’écoute'),
                    subtitle: Text(ref.watch(listenLanguageProvider).label),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showListenLanguagePicker(context, ref),
                  ),
                  const Divider(indent: 56),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Politique de confidentialité'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.privacy),
                  ),
                  const Divider(indent: 56),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Conditions générales d’utilisation'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.terms),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                '${AppInfo.name} · version ${AppInfo.version}',
                style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        UserAvatar(initial: user.initial, size: 56),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.firstName, style: textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                user.identifier,
                style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const UserAvatar(size: 56),
            const SizedBox(width: 16),
            Expanded(
              child: Text('Vous utilisez ROSE Connect sans compte.',
                  style: textTheme.titleMedium),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Un compte vous permettra de participer à la communauté avec un '
          'pseudonyme. Les informations restent accessibles sans compte.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed: () => context.push(AppRoutes.register),
          child: const Text('Créer un compte'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => context.push(AppRoutes.login),
          child: const Text('Se connecter'),
        ),
      ],
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return RoseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROSE Connect vous aide à comprendre le cancer du sein, à reconnaître '
            'les signes qui méritent une consultation et à savoir vers qui vous tourner.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text('Ce que l’application ne fait pas', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final limit in const [
            'Elle ne pose aucun diagnostic.',
            'Elle ne remplace pas une consultation ou un examen médical.',
            'Elle ne recommande aucun traitement.',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.remove_circle_outline,
                        size: 18, color: AppColors.primaryStrong),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(limit, style: textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountActions extends ConsumerWidget {
  const _AccountActions();

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer votre compte ?'),
        content: const Text(
            'Votre compte et votre pseudonyme seront supprimés définitivement. '
            'Vous pourrez continuer à utiliser l’application sans compte.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(authControllerProvider.notifier).deleteAccount();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre compte a été supprimé.')),
        );
      }
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoseCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter'),
            onTap: () => ref.read(authControllerProvider.notifier).logout(),
          ),
          const Divider(indent: 56),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: Text('Supprimer mon compte',
                style: TextStyle(color: AppColors.error)),
            onTap: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }
}
