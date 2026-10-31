import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../models/project.dart';
import '../platform/native_gateway.dart';
import '../store/app_store.dart';

enum PickFailure { unavailable, busy, cancelled }

class PickResult {
  const PickResult({this.media = const [], this.failure});
  final List<PickedMedia> media;
  final PickFailure? failure;
}

class MediaService {
  MediaService(this.gateway, this.store);

  final NativeGateway gateway;
  final AppStore store;

  Future<PickResult> pickVideos() async {
    if (gateway.isAndroid) {
      try {
        final picked = await gateway.pick(kind: 'video', multiple: true);
        return PickResult(media: picked);
      } catch (_) {
        return const PickResult(failure: PickFailure.unavailable);
      }
    }
    try {
      final picker = ImagePicker();
      final files = await picker.pickMultipleMedia();
      if (files.isEmpty) return const PickResult();
      final media = <PickedMedia>[];
      for (final file in files) {
        final size = await file.length();
        media.add(
          PickedMedia(
            uri: file.path,
            name: p.basename(file.path),
            mimeType:
                file.mimeType ??
                (file.name.toLowerCase().endsWith('.mp4')
                    ? 'video/mp4'
                    : 'image/jpeg'),
            sizeBytes: size,
            durationMs: 0,
            width: 0,
            height: 0,
            supported: true,
          ),
        );
      }
      return PickResult(media: media);
    } catch (_) {
      return const PickResult(failure: PickFailure.unavailable);
    }
  }

  Future<PickResult> pickAudio() async {
    if (gateway.isAndroid) {
      try {
        final picked = await gateway.pick(kind: 'audio', multiple: false);
        return PickResult(media: picked);
      } catch (_) {
        return const PickResult(failure: PickFailure.unavailable);
      }
    }
    return const PickResult(failure: PickFailure.unavailable);
  }

  Future<PickResult> pickImage() async {
    if (gateway.isAndroid) {
      try {
        final picked = await gateway.pick(kind: 'image', multiple: false);
        return PickResult(media: picked);
      } catch (_) {
        return const PickResult(failure: PickFailure.unavailable);
      }
    }
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file == null) return const PickResult();
      return PickResult(
        media: [
          PickedMedia(
            uri: file.path,
            name: p.basename(file.path),
            mimeType: file.mimeType ?? 'image/jpeg',
            sizeBytes: await file.length(),
            durationMs: 0,
            width: 0,
            height: 0,
            supported: true,
          ),
        ],
      );
    } catch (_) {
      return const PickResult(failure: PickFailure.unavailable);
    }
  }

  Future<PickedMedia?> describe(String uri) async {
    try {
      return await gateway.describe(uri);
    } catch (_) {
      return null;
    }
  }

  Future<String?> copyCoverImage(PickedMedia media) async {
    try {
      final dir = await store.coversDir();
      final out = File(
        p.join(dir.path, 'cover_${DateTime.now().microsecondsSinceEpoch}.jpg'),
      );
      return await gateway.copyImage(uri: media.uri, outPath: out.path);
    } catch (_) {
      return null;
    }
  }
}

/// Miniatures mises en cache à la taille d'affichage. Aucune animation de
/// chargement, aucun nouveau calcul à chaque reconstruction.
class ThumbnailService {
  ThumbnailService(this.gateway, this.store);

  final NativeGateway gateway;
  final AppStore store;
  final Map<String, Future<String?>> _pending = {};
  final Map<String, Future<List<double>?>> _waves = {};

  /// Plafond du cache disque des miniatures : au-delà, les plus anciennes
  /// sont supprimées (le vidage manuel reste disponible dans les réglages).
  static const int maxCachedFrames = 300;

  Future<String?> frame(MediaRef media, int timeMs, {int width = 192}) {
    if (!gateway.isAndroid) return Future.value(null);
    final key = '${media.id}_${timeMs ~/ 500}_$width';
    return _pending.putIfAbsent(key, () async {
      try {
        final dir = await store.cacheDir();
        final path = p.join(dir.path, '$key.jpg');
        if (await File(path).exists()) return path;
        final out = await gateway.thumbnail(
          uri: media.uri,
          timeMs: timeMs,
          maxWidth: width,
          outPath: path,
        );
        // Un échec ne doit pas rester en cache : l'utilisateur peut rouvrir le
        // projet après avoir reconnecté le média.
        if (out == null) {
          _pending.remove(key);
          return null;
        }
        await _evictOldest(dir);
        return out;
      } catch (_) {
        _pending.remove(key);
        return null;
      }
    });
  }

  Future<void> _evictOldest(Directory dir) async {
    try {
      final files = <File>[];
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.jpg')) files.add(entity);
      }
      if (files.length <= maxCachedFrames) return;
      final stats = <File, DateTime>{};
      for (final file in files) {
        stats[file] = await file.lastModified();
      }
      final ordered = files.toList()
        ..sort((a, b) => stats[a]!.compareTo(stats[b]!));
      for (var i = 0; i < ordered.length - maxCachedFrames; i++) {
        await ordered[i].delete();
      }
    } catch (_) {
      // Le nettoyage ne doit jamais faire échouer une miniature.
    }
  }

  /// `[]` : le média n'a pas de piste audio (aucune onde à dessiner).
  /// `null` : le décodage a échoué (EDT-04 affiche « Audio illisible »).
  Future<List<double>?> waveform(MediaRef media) {
    if (!gateway.isAndroid) return Future.value(const <double>[]);
    return _waves.putIfAbsent(media.id, () async {
      try {
        return await gateway.waveform(uri: media.uri, buckets: 90);
      } catch (_) {
        _waves.remove(media.id);
        return null;
      }
    });
  }
}
