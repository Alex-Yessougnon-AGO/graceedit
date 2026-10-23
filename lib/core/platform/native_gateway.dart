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

  final bool supported;
  final String uri;
  final String name;
  final String mimeType;
  final int sizeBytes;
  final int durationMs;
  final int width;
  final int height;
  final DateTime? capturedAt;

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

class DeviceCapabilities {
  const DeviceCapabilities({
    required this.supports1080p,
    required this.sdkInt,
    required this.deviceModel,
  });

  final bool supports1080p;
  final int sdkInt;
  final String deviceModel;
}

class StorageInfo {
  const StorageInfo({required this.freeBytes, required this.totalBytes});
  final int freeBytes;
  final int totalBytes;
}

/// Passerelle vers les API natives Android. Chaque service externe reste
/// derrière cette interface : aucun accès réseau, aucun balayage du stockage.
class NativeGateway {
  NativeGateway({
    MethodChannel picker = const MethodChannel('graceedit/picker'),
    MethodChannel system = const MethodChannel('graceedit/system'),
    MethodChannel thumbnails = const MethodChannel('graceedit/thumbnails'),
  }) : _picker = picker,
       _system = system,
       _thumbnails = thumbnails;

  final MethodChannel _picker;
  final MethodChannel _system;
  final MethodChannel _thumbnails;

  Future<List<PickedMedia>> pick({
    required String kind,
    bool multiple = true,
  }) async {
    final result = await _picker.invokeMethod<List<Object?>>('pick', {
      'kind': kind,
      'multiple': multiple,
    });
    if (result == null) return const [];
    return result
        .whereType<Map<Object?, Object?>>()
        .map(PickedMedia.fromMap)
        .toList();
  }

  /// Relit les métadonnées d'un média pour vérifier qu'il est lisible.
  Future<PickedMedia?> describe(String uri) async {
    final result = await _picker.invokeMethod<Map<Object?, Object?>>('describe', {
      'uri': uri,
    });
    return result == null ? null : PickedMedia.fromMap(result);
  }

  /// Copie une image du sélecteur dans le projet, réduite à [maxWidth].
  Future<String?> copyImage({
    required String uri,
    required String outPath,
    int maxWidth = 1280,
  }) async {
    return _system.invokeMethod<String>('copyImage', {
      'uri': uri,
      'outPath': outPath,
      'maxWidth': maxWidth,
    });
  }

  /// Extrait une image d'une vidéo vers [outPath].
  Future<String?> thumbnail({
    required String uri,
    required int timeMs,
    required int maxWidth,
    required String outPath,
  }) async {
    return _thumbnails.invokeMethod<String>('frame', {
      'path': uri,
      'timeMs': timeMs,
      'maxWidth': maxWidth,
      'outPath': outPath,
    });
  }

  /// Forme d'onde d'une piste audio : liste d'amplitudes 0..1.
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
        .map((value) => value.toDouble())
        .toList();
  }

  Future<StorageInfo> storage() async {
    final result = await _system.invokeMethod<Map<Object?, Object?>>('storage');
    return StorageInfo(
      freeBytes: (result?['freeBytes'] as num?)?.toInt() ?? 0,
      totalBytes: (result?['totalBytes'] as num?)?.toInt() ?? 0,
    );
  }

  Future<DeviceCapabilities> capabilities() async {
    final result = await _system.invokeMethod<Map<Object?, Object?>>(
      'capabilities',
    );
    return DeviceCapabilities(
      supports1080p: result?['supports1080p'] == true,
      sdkInt: (result?['sdkInt'] as num?)?.toInt() ?? 0,
      deviceModel: '${result?['deviceModel'] ?? ''}',
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

  /// Ouvre le panneau de partage du système pour un fichier exporté.
  Future<void> shareFile(String path, String mimeType) async {
    await _system.invokeMethod<void>('shareFile', {
      'path': path,
      'mimeType': mimeType,
    });
  }
}
