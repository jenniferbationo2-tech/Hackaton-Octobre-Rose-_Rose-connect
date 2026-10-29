import 'package:flutter/material.dart';

import '../../core/widgets/coming_soon_view.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Notre communauté',
      icon: Icons.forum,
      description:
          'Un espace d’échange bienveillant et modéré, bientôt disponible.',
    );
  }
}
