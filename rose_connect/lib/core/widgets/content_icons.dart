import 'package:flutter/material.dart';

/// Icônes utilisables dans les contenus (JSON), par nom.
const contentIcons = <String, IconData>{
  'cells': Icons.bubble_chart_outlined,
  'search': Icons.search,
  'women': Icons.woman_outlined,
  'check': Icons.check_circle_outline,
  'lump': Icons.radio_button_checked,
  'shape': Icons.aspect_ratio,
  'skin': Icons.texture,
  'nipple': Icons.adjust,
  'drop': Icons.water_drop_outlined,
  'doctor': Icons.medical_services_outlined,
  'age': Icons.hourglass_empty,
  'family': Icons.family_restroom,
  'alcohol': Icons.no_drinks_outlined,
  'weight': Icons.monitor_weight_outlined,
  'activity': Icons.directions_walk,
  'info': Icons.info_outline,
  'calendar': Icons.event_available_outlined,
  'nopain': Icons.sentiment_neutral_outlined,
  'heart': Icons.favorite_border,
};

IconData contentIcon(String name) => contentIcons[name] ?? Icons.circle_outlined;
