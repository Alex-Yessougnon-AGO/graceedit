import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/models/project.dart';

/// Joue les éléments audio du projet pendant la lecture de l'aperçu.
///
/// Le moteur suit l'horloge de l'éditeur : à chaque battement il démarre, met
/// en pause, recale et applique volume et fondus. La musique démarre à la tête
/// de lecture, s'arrête à la fin du projet et n'est jamais bouclée (FLUX_V1,
/// EDT-04).
///
/// Un fichier absent ou illisible est ignoré : la timeline signale déjà le
/// média manquant, l'aperçu ne doit pas s'interrompre pour autant.
class PreviewAudioEngine {
  PreviewAudioEngine({bool? enabled}) : _enabled = enabled ?? _platformEnabled;

  /// Aucun moteur hors Android ni pendant les tests (pas de canal natif).
  static final bool _platformEnabled =
      !kIsWeb &&
      Platform.isAndroid &&
      !Platform.environment.containsKey('FLUTTER_TEST');

  final bool _enabled;
  final Map<String, _AudioTrack> _tracks = {};
  bool _busy = false;
  bool _disposed = false;

  bool get enabled => _enabled;

  Future<void> sync(Project project, int positionMs, bool playing) async {
    if (!_enabled || _disposed || _busy) return;
    _busy = true;
    try {
      final ids = {for (final a in project.audios) a.id};
      for (final id in _tracks.keys.toList()) {
        if (!ids.contains(id)) {
          final track = _tracks.remove(id)!;
          await track.dispose();
        }
      }
      for (final audio in project.audios) {
        final media = project.mediaById(audio.mediaId);
        if (media == null || media.fileMissing || media.uri.isEmpty) continue;
        final track = _tracks.putIfAbsent(
          audio.id,
          () => _AudioTrack(media.uri),
        );
        await track.load();
        if (_disposed) return;
        final local = positionMs - audio.startMs;
        final inside = local >= 0 && local < audio.durationMs;
        if (!inside || !playing) {
          await track.stop();
          continue;
        }
        await track.playFrom(
          Duration(milliseconds: local + audio.trimStartMs),
          gainFor(audio, local),
        );
      }
    } finally {
      _busy = false;
    }
  }

  /// Gain effectif : volume de l'élément, réduit par les fondus d'entrée et de
  /// sortie. [localMs] est la position à l'intérieur de l'élément.
  @visibleForTesting
  static double gainFor(AudioItem audio, int localMs) {
    var gain = (audio.volume / 100).clamp(0.0, 1.0);
    if (audio.fadeInMs > 0 && localMs < audio.fadeInMs) {
      gain *= localMs / audio.fadeInMs;
    }
    final outStart = audio.durationMs - audio.fadeOutMs;
    if (audio.fadeOutMs > 0 && localMs > outStart) {
      final remaining = audio.durationMs - localMs;
      gain *= (remaining / audio.fadeOutMs).clamp(0.0, 1.0);
    }
    return gain.clamp(0.0, 1.0);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final tracks = _tracks.values.toList();
    _tracks.clear();
    for (final track in tracks) {
      await track.dispose();
    }
  }
}

class _AudioTrack {
  _AudioTrack(this.uri);

  final String uri;
  AudioPlayer? _player;
  bool _loading = false;
  bool _failed = false;
  bool _started = false;

  Future<void> load() async {
    if (_player != null || _loading || _failed) return;
    _loading = true;
    try {
      final player = AudioPlayer(handleInterruptions: false);
      await player.setLoopMode(LoopMode.off);
      await player.setAudioSource(_source(uri));
      _player = player;
    } catch (_) {
      // Fichier supprimé, format non pris en charge, droits révoqués.
      _failed = true;
    } finally {
      _loading = false;
    }
  }

  static AudioSource _source(String uri) {
    if (uri.startsWith('content://') || uri.startsWith('file://')) {
      return AudioSource.uri(Uri.parse(uri));
    }
    return AudioSource.file(uri);
  }

  double? _appliedGain;

  Future<void> playFrom(Duration target, double gain) async {
    final player = _player;
    if (player == null) return;
    try {
      final drift = (player.position - target).abs();
      if (!_started || drift > const Duration(milliseconds: 500)) {
        await player.seek(target);
        _started = true;
      }
      // Le volume n'est renvoyé au lecteur que s'il a vraiment changé : à
      // 20 battements par seconde, chaque appel compte.
      final last = _appliedGain;
      if (last == null || (gain - last).abs() > 0.01) {
        _appliedGain = gain;
        await player.setVolume(gain);
      }
      // `play()` ne se termine qu'à la fin du morceau : ne jamais l'attendre.
      if (!player.playing) unawaited(player.play());
    } catch (_) {
      // Ne jamais interrompre l'aperçu vidéo pour un souci de son.
    }
  }

  Future<void> stop() async {
    final player = _player;
    if (player == null) return;
    _started = false;
    try {
      if (player.playing) await player.pause();
    } catch (_) {}
  }

  Future<void> dispose() async {
    final player = _player;
    _player = null;
    if (player == null) return;
    try {
      await player.dispose();
    } catch (_) {}
  }
}
