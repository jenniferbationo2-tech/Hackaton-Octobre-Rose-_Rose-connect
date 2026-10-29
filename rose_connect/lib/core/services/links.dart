import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ouvre un lien externe dans le navigateur, avec un message en cas d'échec.
Future<void> openExternalLink(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  final opened = uri != null &&
      await launchUrl(uri, mode: LaunchMode.externalApplication)
          .catchError((_) => false);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossible d’ouvrir ce lien.')),
    );
  }
}
