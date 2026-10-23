/// Real export orchestration: render plan -> native Media3 job ->
/// progress -> verify -> register output. No fake exports.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/grace_project.dart';
import '../platform/capabilities.dart';

enum NativeExportState { running, done, error, cancelled }

class NativeExportStatus {
  const NativeExportStatus({
    required this.state, required this.progress, this.error,
  });
  final NativeExportState state;
  final double progress;
  final String? error;
}

class ExportService {
  ExportService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('graceedit/export');
  final MethodChannel _channel;

  /// Output file of the last started export (null if none).
  String? lastOutputPath;

  /// Job id of the currently running native export (null if none).
  /// Used by the UI to really cancel the native job.
  String? currentJobId;

  /// Builds the render plan from the project and runs it natively.
  /// Emits progress 0..1. Throws on validation or native error.
  Stream<NativeExportStatus> export({
    required GraceProject project,
    required ExportProfile profile,
  }) async* {
    if (project.clips.isEmpty) {
      throw StateError('Timeline vide — ajoutez au moins un clip.');
    }
    final clips = <Map<String, dynamic>>[];
    for (final clip in project.clips) {
      MediaAsset? asset;
      for (final a in project.assets) {
        if (a.id == clip.assetId) asset = a;
      }
      if (asset == null) {
        throw StateError('Asset manquant pour un clip — projet incohérent.');
      }
      if (asset.kind != MediaKind.video) continue; // V1: photo clips skipped in render
      final file = File(asset.path);
      if (!await file.exists()) {
        throw StateError('Fichier introuvable : ${asset.path.split('/').last}');
      }
      clips.add({
        'path': asset.path,
        'startMs': clip.startMs,
        'endMs': clip.endMs,
        'rotation': clip.rotation,
      });
    }
    if (clips.isEmpty) {
      throw StateError('Aucun clip vidéo à exporter.');
    }

    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/graceedit_exports');
    if (!await dir.exists()) await dir.create(recursive: true);
    // A readable file name the user can recognise in the share sheet —
    // never a raw project UUID.
    final safeName = project.name
        .replaceAll(RegExp(r'[/\\:*?"<>|]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final stamp =
        '${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}';
    final base = safeName.isEmpty ? 'video' : safeName;
    var outPath = '${dir.path}/${base}_$stamp.mp4';
    var n = 2;
    while (File(outPath).existsSync()) {
      outPath = '${dir.path}/${base}_${stamp}_$n.mp4';
      n++;
    }
    lastOutputPath = outPath;

    late final String jobId;
    try {
      jobId = await _channel.invokeMethod<String>('startExport', {
        'clips': clips,
        'texts': project.texts.map((t) => t.text).toList(),
        'subtitles': project.subtitles
            .map((s) => {
                  'startMs': s.startMs,
                  'endMs': s.endMs,
                  'text': s.text,
                })
            .toList(),
        'subtitleStyle': project.subtitleStyle,
        'width': profile.width,
        'height': profile.height,
        'outPath': outPath,
      }) ?? (throw StateError('Le moteur d’export n’a pas répondu.'));
      currentJobId = jobId;
    } on MissingPluginException {
      throw StateError('Export natif indisponible sur cette plateforme.');
    }

    // Poll until terminal state.
    while (true) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final raw = await _channel.invokeMethod<Map>('exportProgress', {'jobId': jobId});
      final map = Map<String, dynamic>.from(raw as Map);
      final state = switch (map['state'] as String) {
        'done' => NativeExportState.done,
        'error' => NativeExportState.error,
        'cancelled' => NativeExportState.cancelled,
        _ => NativeExportState.running,
      };
      final progress = ((map['progress'] ?? 0) as num).toDouble().clamp(0.0, 1.0);
      yield NativeExportStatus(
          state: state, progress: progress, error: map['error'] as String?);
      if (state != NativeExportState.running) {
        if (currentJobId == jobId) currentJobId = null;
        return;
      }
    }
  }

  Future<bool> cancel(String jobId) async {
    try {
      return await _channel.invokeMethod<bool>(
              'cancelExport', {'jobId': jobId}) ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// Copies the finished file into the phone gallery (Movies/GraceEdit).
  /// Returns the MediaStore URI, or null when saving is not available.
  Future<String?> saveToGallery(String path) async {
    try {
      return await _channel.invokeMethod<String>('saveToGallery', {
        'path': path,
      });
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
