/// Thumbnail engine: representative frame extraction + disk cache.
/// Cache key covers assetId + sourceVersion + size + timestamp so that
/// edits invalidate correctly and the timeline adapts density to zoom.
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ThumbnailRequest {
  const ThumbnailRequest({
    required this.assetId,
    required this.sourcePath,
    required this.sourceVersion,
    this.maxWidth = 160,
    this.frameMs,
  });
  final String assetId;
  final String sourcePath;
  /// Bump when the underlying media changes to invalidate the cache.
  final int sourceVersion;
  final int maxWidth;
  /// Null => representative frame (NOT systematically the first frame).
  final int? frameMs;

  String get cacheKey =>
      '${assetId}_v${sourceVersion}_w${maxWidth}_f${frameMs ?? -1}';
}

class ThumbnailService {
  ThumbnailService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('graceedit/thumbnails');
  final MethodChannel _channel;
  Directory? _cacheDir;

  Future<Directory> _dir() async {
    if (_cacheDir != null) return _cacheDir!;
    final tmp = await getTemporaryDirectory();
    final d = Directory('${tmp.path}/grace_thumbs');
    if (!await d.exists()) await d.create(recursive: true);
    _cacheDir = d;
    return d;
  }

  /// Returns a cached thumbnail file, generating it on miss via the
  /// native MediaMetadataRetriever (Android). Returns null when the
  /// source cannot be read (caller shows placeholder).
  Future<File?> thumbnailFor(ThumbnailRequest req) async {
    final d = await _dir();
    final cached = File('${d.path}/${req.cacheKey}.jpg');
    if (await cached.exists()) return cached;
    try {
      final out = await _channel.invokeMethod<String>('frame', {
        'path': req.sourcePath,
        'timeMs': req.frameMs ?? 1000,
        'maxWidth': req.maxWidth,
        'outPath': cached.path,
      });
      if (out == null) return null;
      final file = File(out);
      return await file.exists() ? file : null;
    } catch (_) {
      return null;
    }
  }

  /// Representative frame heuristic: 10% into the clip, never 0.
  static int representativeFrameMs(int durationMs) {
    if (durationMs <= 0) return 500;
    final t = durationMs ~/ 10;
    return t.clamp(300, 5000);
  }

  Future<void> invalidateAsset(String assetId) async {
    final d = await _dir();
    await for (final e in d.list()) {
      if (e is File && e.path.contains(assetId)) {
        try {
          await e.delete();
        } catch (_) {}
      }
    }
  }
}
