import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/project.dart';
import '../platform/native_gateway.dart';

enum ExportQuality {
  high,
  standard;

  String get key => name;
}

class ExportConfiguration {
  const ExportConfiguration({
    required this.quality,
    required this.width,
    required this.height,
    required this.estimatedBytes,
  });
  final ExportQuality quality;
  final int width;
  final int height;
  final int estimatedBytes;
}

class ExportException implements Exception {
  ExportException(this.code);
  final String code;
}

/// Travail de rendu démarré côté natif.
///
/// Le chemin de sortie est calculé **une seule fois**, au démarrage : `finish`
/// le reçoit ensuite pour vérifier le fichier et l'enregistrer dans la galerie.
class ExportHandle {
  const ExportHandle({required this.jobId, required this.path});
  final String jobId;
  final String path;
}

class ExportService {
  ExportService(this.gateway, this.exportDirectory);

  final NativeGateway gateway;
  final Future<Directory> Function() exportDirectory;

  static const _bitrateHigh = 6000000; // 6 Mbit/s moyen
  static const _bitrateStandard = 3000000;

  ExportConfiguration configuration(
    Project project,
    ExportQuality quality, {
    bool supports1080p = true,
  }) {
    final high = quality == ExportQuality.high && supports1080p;
    final longEdge = high ? 1080 : 720;
    final (w, h) = switch (project.format) {
      ProjectFormat.vertical => (high ? 1080 : 720, high ? 1920 : 1280),
      ProjectFormat.square => (longEdge, longEdge),
      ProjectFormat.horizontal => (high ? 1920 : 1280, high ? 1080 : 720),
      ProjectFormat.portrait => (high ? 1080 : 720, high ? 1350 : 900),
    };
    final seconds = project.durationMs / 1000;
    final bitrate = high ? _bitrateHigh : _bitrateStandard;
    final estimate = ((seconds * bitrate) / 8 * 1.08).round();
    return ExportConfiguration(
      quality: high ? ExportQuality.high : ExportQuality.standard,
      width: w,
      height: h,
      estimatedBytes: estimate,
    );
  }

  Future<ExportHandle> start(
    Project project,
    ExportConfiguration config,
  ) async {
    if (!gateway.isAndroid) {
      throw ExportException('unsupported_platform');
    }
    final clips = <Map<String, Object>>[];
    for (final clip in project.clips) {
      final media = project.mediaById(clip.mediaId);
      if (media == null || media.fileMissing) {
        throw ExportException('missing_media');
      }
      clips.add({
        'path': media.uri,
        'startMs': clip.trimStartMs,
        'endMs': clip.trimEndMs,
        'rotation': clip.rotation,
        'volume': (clip.volume / 100).clamp(0.0, 1.0),
        'videoVolume': (project.videoVolume / 100).clamp(0.0, 1.0),
      });
    }
    if (clips.isEmpty) throw ExportException('empty');
    final texts = project.texts
        .map(
          (t) => <String, Object>{
            'text': t.text,
            'startMs': t.startMs,
            'endMs': t.endMs,
            'x': t.x,
            'y': t.y,
            'size': t.size,
            'color': t.color,
            'opacity': (t.opacity / 100).clamp(0.0, 1.0),
            'align': t.align.name,
            'background': t.background,
          },
        )
        .toList();
    // La musique et les fondus sont rendus dans le film, comme dans
    // l'aperçu. Un élément dont le fichier a disparu est simplement ignoré :
    // la timeline le signale déjà.
    final audios = <Map<String, Object>>[];
    for (final audio in project.audios) {
      final media = project.mediaById(audio.mediaId);
      if (media == null || media.fileMissing) continue;
      audios.add({
        'path': media.uri,
        'startMs': audio.startMs,
        'trimStartMs': audio.trimStartMs,
        'trimEndMs': audio.trimEndMs,
        'volume': (audio.volume / 100).clamp(0.0, 1.0),
        'fadeInMs': audio.fadeInMs,
        'fadeOutMs': audio.fadeOutMs,
      });
    }
    final safeTitle = project.title
        .replaceAll(RegExp(r'[^\p{L}\p{N} _-]', unicode: true), '')
        .trim();
    // EXP-03 : le nom par défaut est le titre du projet (« Visite du
    // marché.mp4 »). En cas de doublon, on ajoute « (2) » plutôt qu'un
    // horodatage illisible.
    final base = safeTitle.isEmpty ? 'GraceEdit' : safeTitle;
    final dir = await exportDirectory();
    await dir.create(recursive: true);
    var name = '$base.mp4';
    var suffix = 2;
    while (await File(p.join(dir.path, name)).exists()) {
      name = '$base ($suffix).mp4';
      suffix++;
    }
    final outPath = p.join(dir.path, name);
    final jobId = await gateway.startExport(
      clips: clips,
      texts: texts,
      audios: audios,
      fit: project.fitMode.name,
      width: config.width,
      height: config.height,
      outPath: outPath,
    );
    return ExportHandle(jobId: jobId, path: outPath);
  }

  Future<ExportProgress> poll(String jobId) => gateway.exportProgress(jobId);

  Future<bool> cancel(String jobId) => gateway.cancelExport(jobId);

  Future<ExportRecord> finish(
    Project project,
    String path,
    ExportConfiguration config,
  ) async {
    final file = File(path);
    if (!await file.exists()) throw ExportException('output_missing');
    final size = await file.length();
    final galleryUri = await gateway.saveToGallery(path);
    final name = p.basename(path);
    return ExportRecord(
      path: galleryUri ?? path,
      name: name,
      width: config.width,
      height: config.height,
      durationMs: project.durationMs,
      sizeBytes: size,
      createdAt: DateTime.now(),
      inGallery: galleryUri != null,
    );
  }
}
