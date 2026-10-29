import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rangée de repères courts : une icône et deux ou trois mots chacun.
class IconFacts extends StatelessWidget {
  const IconFacts({super.key, required this.facts, this.tint = AppColors.surface});

  final List<(IconData, String)> facts;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < facts.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(facts[i].$1, color: AppColors.primaryStrong, size: 26),
                    const SizedBox(height: 8),
                    Text(
                      facts[i].$2,
                      textAlign: TextAlign.center,
                      style: textTheme.labelMedium,
                    ),
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
