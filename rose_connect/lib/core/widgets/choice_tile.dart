import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum ChoiceState { idle, selected, correct, wrong }

/// Réponse sélectionnable, en pleine largeur (cible tactile ≥ 56 dp).
/// Les états corrects ou faux sont signalés par une icône en plus de la
/// couleur.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.label,
    required this.state,
    this.onTap,
    this.symbol,
  });

  final String label;
  final ChoiceState state;
  final VoidCallback? onTap;

  /// Pictogramme de la réponse (✓, ✗, ?), compréhensible sans lire.
  /// Remplace le bouton radio tant que la réponse n'est pas corrigée.
  final IconData? symbol;

  @override
  Widget build(BuildContext context) {
    final (background, border, foreground, icon) = switch (state) {
      ChoiceState.idle => (
          AppColors.surface,
          AppColors.border,
          AppColors.textDark,
          Icons.radio_button_unchecked,
        ),
      ChoiceState.selected => (
          AppColors.roseTint,
          AppColors.primary,
          AppColors.deepBerry,
          Icons.radio_button_checked,
        ),
      ChoiceState.correct => (
          AppColors.mintTint,
          AppColors.tertiary,
          AppColors.tertiaryStrong,
          Icons.check_circle,
        ),
      ChoiceState.wrong => (
          AppColors.errorTint,
          AppColors.error,
          AppColors.error,
          Icons.cancel,
        ),
    };
    final emphasized = state != ChoiceState.idle;
    final shownIcon = symbol != null &&
            (state == ChoiceState.idle || state == ChoiceState.selected)
        ? symbol!
        : icon;

    return Semantics(
      button: true,
      selected: state == ChoiceState.selected,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border, width: emphasized ? 1.5 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(shownIcon,
                      color: emphasized ? foreground : AppColors.textMuted,
                      size: symbol != null ? 28 : 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: foreground,
                            fontWeight:
                                emphasized ? FontWeight.w600 : FontWeight.w400,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
