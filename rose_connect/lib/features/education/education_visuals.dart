import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Icône, couleurs et libellé associés à chaque catégorie de fiche.
class CategoryVisual {
  const CategoryVisual(this.label, this.icon, this.color, this.tint);

  final String label;
  final IconData icon;
  final Color color;
  final Color tint;
}

const _visuals = {
  'comprendre': CategoryVisual('Comprendre', Icons.help_outline_rounded,
      AppColors.primaryStrong, AppColors.roseTint),
  'signes': CategoryVisual('Signes', Icons.visibility_outlined,
      AppColors.secondaryStrong, AppColors.sky),
  'risques': CategoryVisual('Facteurs de risque', Icons.insights_outlined,
      AppColors.tertiaryStrong, AppColors.mintTint),
  'consulter': CategoryVisual('Consulter', Icons.medical_services_outlined,
      AppColors.primaryStrong, AppColors.roseTint),
  'idees-recues': CategoryVisual('Idées reçues',
      Icons.lightbulb_outline_rounded, AppColors.secondaryStrong, AppColors.sky),
};

CategoryVisual visualFor(String category) =>
    _visuals[category] ??
    const CategoryVisual('Information', Icons.article_outlined,
        AppColors.textMuted, AppColors.border);
