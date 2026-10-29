import 'package:flutter/material.dart';

/// Pastille d'icône carrée à coins arrondis.
class IconBadge extends StatelessWidget {
  const IconBadge(
    this.icon, {
    super.key,
    required this.color,
    required this.tint,
    this.size = 40,
  });

  final IconData icon;
  final Color color;
  final Color tint;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Align garde la taille fixe même dans une liste qui impose sa largeur.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: 1,
      heightFactor: 1,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Icon(icon, color: color, size: size * 0.55),
      ),
    );
  }
}
