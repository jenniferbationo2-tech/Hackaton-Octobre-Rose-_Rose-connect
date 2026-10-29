import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Barre de progression avec libellé « Question 2 sur 5 ».
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.current, required this.total});

  /// Étape courante, à partir de 1.
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question $current sur $total',
          style: textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current / total,
            minHeight: 6,
            // Valeur numérique exigée : pourcentage d'avancement.
            semanticsLabel: 'Progression du questionnaire',
            semanticsValue: '${(current * 100 / total).round()}',
          ),
        ),
      ],
    );
  }
}
