import 'dart:io';

import 'package:flutter/services.dart';

/// Métadonnées d'un média choisi dans le sélecteur du système.
class PickedMedia {
  const PickedMedia({
    required this.uri,
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
    required this.durationMs,
    required this.width,
    required this.height,
    this.capturedAt,
    this.supported = true,
  });

  final String uri;
  final String name;
  final String mimeType;
  final int sizeBytes;
  final int durationMs;
  final int width;
  final int height;
  final DateTime? capturedAt;
  final bool supported;

  bool get isVideo => mimeType.startsWith('video/');
  bool get isAudio => mimeType.startsWith('audio/');
  bool get isImage => mimeType.startsWith('image/');

  factory PickedMedia.fromMap(Map<Object?, Object?> map) => PickedMedia(
    uri: '${map['uri']}',
    name: '${map['name'] ?? ''}',
    mimeType: '${map['mimeType'] ?? ''}',
    sizeBytes: (map['sizeBytes'] as num?)?.toInt() ?? 0,
    durationMs: (map['durationMs'] as num?)?.toInt() ?? 0,
    width: (map['width'] as num?)?.toInt() ?? 0,
    height: (map['height'] as num?)?.toInt() ?? 0,
    capturedAt: map['capturedAt'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            (map['capturedAt'] as num).toInt(),
          ),
    supported: map['supported'] == true,
  );
}

class DeviceInfo {
  const DeviceInfo({
    required this.supports1080p,
    required this.sdkInt,
    required this.model,
    required this.freeBytes,
    required this.totalBytes,
  });
  final bool supports1080p;
  final int sdkInt;
  final String model;
  final int freeBytes;
  final int totalBytes;
}

class ExportProgress {
  const ExportProgress({
    required this.state,
    required this.progress,
    this.error,
  });
  final String state;
  final double progress;
  final String? error;

  bool get isDone => state == 'done';
  bool get isError => state == 'error';
  bool get isCancelled => state == 'cancelled';
}

/// Toutes les API Android passent par ici. Aucun accès réseau.
class NativeGateway {
  NativeGateway({
    this._picker = const MethodChannel('graceedit/picker'),
    this._system = const MethodChannel('graceedit/system'),
    this._thumbnails = const MethodChannel('graceedit/thumbnails'),
    this._export = const MethodChannel('graceedit/export'),
  });

  final MethodChannel _picker;
  final MethodChannel _system;
  final MethodChannel _thumbnails;
  final MethodChannel _export;

  bool get isAndroid => Platform.isAndroid;

  Future<List<PickedMedia>> pick({
    required String kind,
    bool multiple = true,
  }) async {
    final result = await _picker.invokeMethod<List<Object?>>('pick', {
      'kind': kind,
      'multiple': multiple,
    });
    return (result ?? const [])
        .whereType<Map<Object?, Object?>>()
        .map(PickedMedia.fromMap)
        .toList();
  }

  Future<PickedMedia?> describe(String uri) async {
    final result = await _picker.invokeMethod<Map<Object?, Object?>>(
      'describe',
      {'uri': uri},
    );
    return result == null ? null : PickedMedia.fromMap(result);
  }

  Future<String?> copyImage({
    required String uri,
    required String outPath,
    int maxWidth = 1280,
  }) => _system.invokeMethod<String>('copyImage', {
    'uri': uri,
    'outPath': outPath,
    'maxWidth': maxWidth,
  });

  Future<String?> thumbnail({
    required String uri,
    required int timeMs,
    required int maxWidth,
    required String outPath,
  }) => _thumbnails.invokeMethod<String>('frame', {
    'path': uri,
    'timeMs': timeMs,
    'maxWidth': maxWidth,
    'outPath': outPath,
  });

  Future<List<double>> waveform({
    required String uri,
    int buckets = 120,
  }) async {
    final result = await _thumbnails.invokeMethod<List<Object?>>('waveform', {
      'path': uri,
      'buckets': buckets,
    });
    return (result ?? const [])
        .whereType<num>()
        .map((v) => v.toDouble())
        .toList();
  }

  Future<DeviceInfo> deviceInfo() async {
    final storage = await _system.invokeMethod<Map<Object?, Object?>>(
      'storage',
    );
    final caps = await _system.invokeMethod<Map<Object?, Object?>>(
      'capabilities',
    );
    return DeviceInfo(
      supports1080p: caps?['supports1080p'] != false,
      sdkInt: (caps?['sdkInt'] as num?)?.toInt() ?? 0,
      model: '${caps?['deviceModel'] ?? ''}',
      freeBytes: (storage?['freeBytes'] as num?)?.toInt() ?? 0,
      totalBytes: (storage?['totalBytes'] as num?)?.toInt() ?? 0,
    );
  }

  Future<bool> notificationsAllowed() async =>
      await _system.invokeMethod<bool>('notificationsAllowed') ?? false;

  Future<bool> requestNotifications() async =>
      await _system.invokeMethod<bool>('requestNotifications') ?? false;

  Future<void> openGallery(String uri) =>
      _system.invokeMethod<void>('openGallery', {'uri': uri});

  Future<void> openAppSettings() =>
      _system.invokeMethod<void>('openAppSettings');

  Future<void> shareFile(String path, String mimeType) => _system
      .invokeMethod<void>('shareFile', {'path': path, 'mimeType': mimeType});

  Future<String> startExport({
    required List<Map<String, Object>> clips,
    required List<Map<String, Object>> texts,
    required int width,
    required int height,
    required String outPath,
  }) async {
    final jobId = await _export.invokeMethod<String>('startExport', {
      'clips': clips,
      'texts': const <String>[],
      'subtitles': texts,
      'width': width,
      'height': height,
      'outPath': outPath,
    });
    if (jobId == null || jobId.isEmpty) {
      // Code d'erreur, jamais un texte affiché : l'écran EXP-04 traduit.
      throw StateError('export_not_started');
    }
    return jobId;
  }

  Future<ExportProgress> exportProgress(String jobId) async {
    final result = await _export.invokeMethod<Map<Object?, Object?>>(
      'exportProgress',
      {'jobId': jobId},
    );
    return ExportProgress(
      state: '${result?['state'] ?? 'error'}',
      progress: (result?['progress'] as num?)?.toDouble() ?? 0,
      error: result?['error'] as String?,
    );
  }

  Future<bool> cancelExport(String jobId) async =>
      await _export.invokeMethod<bool>('cancelExport', {'jobId': jobId}) ??
      false;

  Future<String?> saveToGallery(String path) =>
      _export.invokeMethod<String>('saveToGallery', {'path': path});
}
