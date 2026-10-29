import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'legal_content.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(document.title)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen, 8, AppSpacing.screen, AppSpacing.xl),
          children: [
            Text(
              'Dernière mise à jour : ${AppInfo.legalUpdatedAt}',
              style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(document.intro, style: textTheme.bodyLarge),
            for (final section in document.sections) ...[
              const SizedBox(height: AppSpacing.lg),
              Semantics(
                header: true,
                child: Text(section.title, style: textTheme.titleLarge),
              ),
              for (final paragraph in section.paragraphs) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(paragraph, style: textTheme.bodyMedium),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
