import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../services/preferences.dart';

/// Langues d'écoute. Les enregistrements se trouvent dans
/// `assets/audio/{code}/{identifiant}.m4a` (voir docs/ENREGISTREMENTS_AUDIO.md).
enum ListenLanguage {
  fr('fr', 'Français'),
  dyu('dyu', 'Dioula');

  const ListenLanguage(this.code, this.label);

  final String code;
  final String label;
}

const _languageKey = 'listen_language';
const _extensions = ['m4a', 'mp3', 'aac', 'wav'];

/// Langue d'écoute choisie, mémorisée sur le téléphone.
class ListenLanguageController extends Notifier<ListenLanguage> {
  @override
  ListenLanguage build() {
    final code = ref.watch(sharedPreferencesProvider).getString(_languageKey);
    return ListenLanguage.values.firstWhere(
      (l) => l.code == code,
      orElse: () => ListenLanguage.fr,
    );
  }

  Future<void> select(ListenLanguage language) async {
    state = language;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_languageKey, language.code);
  }
}

final listenLanguageProvider =
    NotifierProvider<ListenLanguageController, ListenLanguage>(
        ListenLanguageController.new);

/// Enregistrements réellement présents dans l'application.
final audioCatalogProvider = FutureProvider<Set<String>>((ref) async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  return manifest
      .listAssets()
      .where((path) => path.startsWith('assets/audio/'))
      .toSet();
});

/// Fichier à jouer pour un contenu : dans la langue choisie, sinon en
/// français, sinon null (le bouton d'écoute n'est pas affiché).
String? resolveClip(Set<String> catalog, ListenLanguage language, String clipId) {
  for (final lang in {language, ListenLanguage.fr}) {
    for (final ext in _extensions) {
      final path = 'assets/audio/${lang.code}/$clipId.$ext';
      if (catalog.contains(path)) return path;
    }
  }
  return null;
}

/// Langue réellement jouée pour un fichier (utile pour l'afficher).
ListenLanguage? languageOf(String? path) {
  if (path == null) return null;
  for (final lang in ListenLanguage.values) {
    if (path.startsWith('assets/audio/${lang.code}/')) return lang;
  }
  return null;
}

/// Lecteur unique : un seul enregistrement à la fois.
/// L'état est le chemin en cours de lecture, ou null.
class AudioController extends Notifier<String?> {
  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _subscription;

  @override
  String? build() {
    ref.onDispose(() {
      _subscription?.cancel();
      _player?.dispose();
    });
    return null;
  }

  AudioPlayer get _audio {
    if (_player == null) {
      _player = AudioPlayer();
      _subscription = _player!.playerStateStream.listen((s) {
        if (s.processingState == ProcessingState.completed) state = null;
      });
    }
    return _player!;
  }

  /// Lance l'enregistrement, ou l'arrête s'il est déjà en cours.
  Future<void> toggle(String path) async {
    if (state == path) return stop();
    state = path;
    try {
      await _audio.stop();
      await _audio.setAsset(path);
      unawaited(_audio.play());
    } on Object {
      state = null;
    }
  }

  Future<void> stop() async {
    state = null;
    await _player?.stop();
  }
}

final audioControllerProvider =
    NotifierProvider<AudioController, String?>(AudioController.new);
