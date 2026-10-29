import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import 'audio.dart';

/// Bouton « Écouter » d'un contenu. N'apparaît que si un enregistrement
/// existe dans la langue choisie ou en français.
class ListenButton extends ConsumerWidget {
  const ListenButton({super.key, required this.clipId, this.compact = false});

  final String clipId;

  /// Version réduite (icône seule), pour les listes et les cartes.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(audioCatalogProvider).value;
    if (catalog == null) return const SizedBox.shrink();
    final language = ref.watch(listenLanguageProvider);
    final path = resolveClip(catalog, language, clipId);
    if (path == null) return const SizedBox.shrink();

    final playing = ref.watch(audioControllerProvider) == path;
    final played = languageOf(path) ?? ListenLanguage.fr;
    final label = playing ? 'Arrêter' : 'Écouter';
    final semantic = '$label en ${played.label}';
    void onTap() => ref.read(audioControllerProvider.notifier).toggle(path);
    final icon = Icon(
      playing ? Icons.stop_circle_outlined : Icons.volume_up_rounded,
      color: AppColors.primaryStrong,
    );

    if (compact) {
      return IconButton(
        tooltip: semantic,
        onPressed: onTap,
        icon: icon,
        style: IconButton.styleFrom(backgroundColor: AppColors.roseTint),
      );
    }
    return Semantics(
      button: true,
      label: semantic,
      excludeSemantics: true,
      child: Material(
        color: AppColors.roseTint,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 8),
                Text(
                  '$label · ${played.label}',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: AppColors.primaryStrong),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Choix de la langue d'écoute.
Future<void> showListenLanguagePicker(BuildContext context, WidgetRef ref) {
  final current = ref.read(listenLanguageProvider);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Langue d’écoute',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final language in ListenLanguage.values)
              ListTile(
                leading: Icon(
                  language == current
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: AppColors.primaryStrong,
                ),
                title: Text(language.label),
                onTap: () {
                  ref.read(listenLanguageProvider.notifier).select(language);
                  ref.read(audioControllerProvider.notifier).stop();
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    ),
  );
}

/// Pastille de la langue d'écoute, ouvre le choix de la langue.
class ListenLanguageChip extends ConsumerWidget {
  const ListenLanguageChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(listenLanguageProvider);
    return Semantics(
      button: true,
      label: 'Langue d’écoute : ${language.label}. Changer',
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => showListenLanguagePicker(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.record_voice_over_outlined,
                    size: 18, color: AppColors.primaryStrong),
                const SizedBox(width: 6),
                Text(language.label,
                    style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
