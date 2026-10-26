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

  Future<String?> frame(MediaRef media, int timeMs, {int width = 192}) {
    if (!gateway.isAndroid) return Future.value(null);
    final key = '${media.id}_${timeMs ~/ 500}_$width';
    return _pending.putIfAbsent(key, () async {
      try {
        final dir = await store.cacheDir();
        final path = p.join(dir.path, '$key.jpg');
        if (await File(path).exists()) return path;
        return await gateway.thumbnail(
          uri: media.uri,
          timeMs: timeMs,
          maxWidth: width,
          outPath: path,
        );
      } catch (_) {
        return null;
      }
    });
  }

  Future<List<double>?> waveform(MediaRef media) async {
    if (!gateway.isAndroid) return null;
    try {
      final values = await gateway.waveform(uri: media.uri, buckets: 90);
      return values.isEmpty ? null : values;
    } catch (_) {
      return null;
    }
  }
}
