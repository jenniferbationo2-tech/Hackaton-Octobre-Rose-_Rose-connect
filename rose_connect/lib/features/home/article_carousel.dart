import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/typography.dart';
import '../../models/education_item.dart';
import '../education/education_visuals.dart';

/// Temps de lecture estimé (environ 180 mots par minute).
int readingMinutes(EducationItem item) {
  var words = item.summary.split(RegExp(r'\s+')).length;
  for (final block in item.blocks) {
    final text = switch (block) {
      HeadingBlock(:final text) => text,
      ParagraphBlock(:final text) => text,
      CalloutBlock(:final text) => text,
      BulletsBlock(:final items) => items.join(' '),
      MythBlock(:final myth, :final fact) => '$myth $fact',
    };
    words += text.split(RegExp(r'\s+')).length;
  }
  return (words / 180).ceil().clamp(1, 60);
}

/// Bulles d'articles qui défilent doucement d'elles-mêmes.
/// Le défilement s'arrête dès que l'utilisatrice touche le carrousel, et
/// n'a pas lieu si le téléphone demande de réduire les animations.
class ArticleCarousel extends StatefulWidget {
  const ArticleCarousel({super.key, required this.items});

  final List<EducationItem> items;

  @override
  State<ArticleCarousel> createState() => _ArticleCarouselState();
}

class _ArticleCarouselState extends State<ArticleCarousel> {
  static const _interval = Duration(seconds: 6);

  PageController? _controller;
  double? _viewportFraction;
  Timer? _timer;
  int _page = 0;
  bool _userInteracting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sur petit écran, la bulle suivante dépasse légèrement : on comprend
    // qu'on peut faire défiler.
    final width = MediaQuery.sizeOf(context).width;
    final fraction = width < 400 ? 0.86 : 0.8;
    if (fraction != _viewportFraction) {
      _viewportFraction = fraction;
      _controller?.dispose();
      _controller = PageController(viewportFraction: fraction, initialPage: _page);
    }
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion || widget.items.length < 2) return;
    _timer = Timer.periodic(_interval, (_) => _advance());
  }

  void _advance() {
    final controller = _controller;
    if (_userInteracting || controller == null || !controller.hasClients) return;
    final next = (_page + 1) % widget.items.length;
    controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    // La hauteur suit la taille du texte choisie sur le téléphone.
    final height = 232 * textScale.clamp(1.0, 1.3);

    return Column(
      children: [
        SizedBox(
          height: height,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _userInteracting = true;
                _timer?.cancel();
              } else if (notification is ScrollEndNotification &&
                  _userInteracting) {
                _userInteracting = false;
                _restartTimer();
              }
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              padEnds: false,
              itemCount: widget.items.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 16 : 6,
                  right: index == widget.items.length - 1 ? 16 : 6,
                ),
                child: ArticleBubble(item: widget.items[index]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _PageDots(count: widget.items.length, current: _page),
      ],
    );
  }
}

class ArticleBubble extends StatelessWidget {
  const ArticleBubble({super.key, required this.item});

  final EducationItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visual = visualFor(item.category);
    final minutes = readingMinutes(item);

    return Semantics(
      button: true,
      label: '${item.title}. $minutes minutes de lecture.',
      excludeSemantics: true,
      child: Material(
        color: visual.tint,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go(AppRoutes.educationDetail(item.id)),
          child: Stack(
            children: [
              // Motif discret : l'icône de la catégorie en filigrane.
              Positioned(
                right: -18,
                bottom: -18,
                child: Icon(
                  visual.icon,
                  size: 120,
                  color: visual.color.withValues(alpha: 0.07),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            visual.label,
                            style: textTheme.labelSmall
                                ?.copyWith(color: visual.color),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.schedule,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '$minutes min',
                          style: textTheme.labelSmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      frenchSpacing(item.title),
                      style: textTheme.titleLarge?.copyWith(height: 1.25),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      frenchSpacing(item.summary),
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.textDark),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'Lire l’article',
                          style: textTheme.labelLarge
                              ?.copyWith(color: visual.color),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 18, color: visual.color),
                      ],
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

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Article ${current + 1} sur $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == current ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == current ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
        ],
      ),
    );
  }
}
