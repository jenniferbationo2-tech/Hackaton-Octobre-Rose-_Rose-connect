import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rappel permanent : l'application informe mais ne diagnostique pas.
class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({
    super.key,
    this.message =
        'ROSE Connect informe et oriente. Il ne remplace pas un professionnel de santé et ne pose aucun diagnostic.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sky,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.skyBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              color: AppColors.secondaryStrong, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
