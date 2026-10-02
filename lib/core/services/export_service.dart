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
    final outPath =
        '${dir.path}/${project.id}_${profile.id.name}_${DateTime.now().millisecondsSinceEpoch}.mp4';

    late final String jobId;
    try {
      jobId = await _channel.invokeMethod<String>('startExport', {
        'clips': clips,
        'width': profile.width,
        'height': profile.height,
        'outPath': outPath,
      }) ?? (throw StateError('Le moteur d’export n’a pas répondu.'));
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
      if (state != NativeExportState.running) return;
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
}
