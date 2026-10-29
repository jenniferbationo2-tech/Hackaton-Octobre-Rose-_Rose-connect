import 'package:flutter/material.dart';

/// Palette issue de la charte « Warm Healthcare Sanctuary » (Stitch).
abstract final class AppColors {
  // Rose : identité de la marque.
  static const primary = Color(0xFFE91E63);
  // Rose foncé : boutons et textes sur fond clair (contraste ≥ 4,5:1 avec le blanc).
  static const primaryStrong = Color(0xFFB80049);
  static const deepBerry = Color(0xFF9C1542);
  static const roseTint = Color(0xFFFCE4EC);
  static const roseBorder = Color(0xFFF48FB1);

  // Bleu : informations et contenus éducatifs.
  static const secondary = Color(0xFF3B82F6);
  static const secondaryStrong = Color(0xFF0058BE);
  static const sky = Color(0xFFEFF6FF);
  static const skyBorder = Color(0xFFBFDBFE);

  // Menthe : succès, étapes terminées.
  static const tertiary = Color(0xFF10B981);
  static const tertiaryStrong = Color(0xFF006947);
  static const mintTint = Color(0xFFD1FAE5);

  // Neutres.
  static const canvas = Color(0xFFF8F7F4);
  static const surface = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1F2937);
  static const textMuted = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);

  // États.
  static const error = Color(0xFFBA1A1A);
  static const errorTint = Color(0xFFFFDAD6);
  static const urgent = Color(0xFFE65100);
  static const urgentTint = Color(0xFFFFF3E0);
}
