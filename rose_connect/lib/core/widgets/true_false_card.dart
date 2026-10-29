import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/typography.dart';

/// Carte « Vrai ou faux ? » : l'affirmation d'abord, la réponse au toucher.
/// Les idées reçues présentées ici sont toutes fausses.
class TrueFalseCard extends StatefulWidget {
  const TrueFalseCard({
    super.key,
    required this.statement,
    required this.answer,
    this.color = AppColors.surface,
  });

  final String statement;
  final String answer;
  final Color color;

  @override
  State<TrueFalseCard> createState() => _TrueFalseCardState();
}

class _TrueFalseCardState extends State<TrueFalseCard> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: widget.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _revealed = !_revealed),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                frenchSpacing('« ${widget.statement} »'),
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topLeft,
                child: _revealed
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.cancel,
                                  color: AppColors.error, size: 20),
                              const SizedBox(width: 6),
                              Text('Faux',
                                  style: textTheme.labelLarge
                                      ?.copyWith(color: AppColors.error)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Semantics(
                            liveRegion: true,
                            child: Text(frenchSpacing(widget.answer),
                                style: textTheme.bodyMedium),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          const Icon(Icons.touch_app_outlined,
                              size: 18, color: AppColors.primaryStrong),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                                'Touchez pour voir la réponse',
                                style: textTheme.labelLarge?.copyWith(
                                    color: AppColors.primaryStrong)),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
