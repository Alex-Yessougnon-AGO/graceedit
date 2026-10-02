/// GraceEdit project model — platform-independent, serializable.
/// See docs/08_TECHNICAL_ARCHITECTURE.md and 22_CREATIVE_PROJECT_MODEL.md.
library;

import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const int graceProjectSchemaVersion = 1;

enum ProjectKind { video, poster, image, audio, scenario, thumbnail, campaign, uxui }

enum CanvasPreset {
  landscape1080p(1920, 1080),
  portrait1080x1920(1080, 1920),
  square1080(1080, 1080),
  hd720p(1280, 720);

  const CanvasPreset(this.width, this.height);
  final int width;
  final int height;
}

class CanvasSettings {
  const CanvasSettings({required this.width, required this.height, this.fps = 30});
  final int width;
  final int height;
  final int fps;

  factory CanvasSettings.fromPreset(CanvasPreset p, {int fps = 30}) =>
      CanvasSettings(width: p.width, height: p.height, fps: fps);

  Map<String, dynamic> toJson() => {'width': width, 'height': height, 'fps': fps};
  factory CanvasSettings.fromJson(Map<String, dynamic> j) => CanvasSettings(
        width: (j['width'] as num).toInt(),
        height: (j['height'] as num).toInt(),
        fps: ((j['fps'] ?? 30) as num).toInt(),
      );
}

enum MediaKind { video, image, audio, text, subtitle }

class MediaAsset {
  const MediaAsset({
    required this.id,
    required this.kind,
    required this.path,
    this.durationMs,
    this.width,
    this.height,
    this.source = 'import',
  });
  final String id;
  final MediaKind kind;
  final String path;
  final int? durationMs;
  final int? width;
  final int? height;
  /// 'import' | 'camera' | 'generated' | 'template'
  final String source;

  Map<String, dynamic> toJson() => {
        'id': id, 'kind': kind.name, 'path': path,
        'durationMs': durationMs, 'width': width, 'height': height,
        'source': source,
      };
  factory MediaAsset.fromJson(Map<String, dynamic> j) => MediaAsset(
        id: j['id'] as String,
        kind: MediaKind.values.byName(j['kind'] as String),
        path: j['path'] as String,
        durationMs: (j['durationMs'] as num?)?.toInt(),
        width: (j['width'] as num?)?.toInt(),
        height: (j['height'] as num?)?.toInt(),
        source: (j['source'] ?? 'import') as String,
      );
}

class VideoClip {
  const VideoClip({
    required this.id,
    required this.assetId,
    required this.startMs,
    required this.endMs,
    this.speed = 1.0,
    this.volume = 1.0,
    this.rotation = 0,
  });
  final String id;
  final String assetId;
  final int startMs;
  final int endMs;
  final double speed;
  final double volume;
  final int rotation;

  int get durationMs => ((endMs - startMs) / speed).round();

  VideoClip copyWith({int? startMs, int? endMs, double? speed, double? volume, int? rotation}) =>
      VideoClip(
        id: id, assetId: assetId,
        startMs: startMs ?? this.startMs, endMs: endMs ?? this.endMs,
        speed: speed ?? this.speed, volume: volume ?? this.volume,
        rotation: rotation ?? this.rotation,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'assetId': assetId, 'startMs': startMs, 'endMs': endMs,
        'speed': speed, 'volume': volume, 'rotation': rotation,
      };
  factory VideoClip.fromJson(Map<String, dynamic> j) => VideoClip(
        id: j['id'] as String, assetId: j['assetId'] as String,
        startMs: (j['startMs'] as num).toInt(), endMs: (j['endMs'] as num).toInt(),
        speed: ((j['speed'] ?? 1.0) as num).toDouble(),
        volume: ((j['volume'] ?? 1.0) as num).toDouble(),
        rotation: ((j['rotation'] ?? 0) as num).toInt(),
      );
}

class TextLayer {
  const TextLayer({required this.id, required this.text, this.positionMs = 0, this.durationMs = 3000, this.fontSize = 32});
  final String id;
  final String text;
  final int positionMs;
  final int durationMs;
  final double fontSize;

  Map<String, dynamic> toJson() => {
        'id': id, 'text': text, 'positionMs': positionMs,
        'durationMs': durationMs, 'fontSize': fontSize,
      };
  factory TextLayer.fromJson(Map<String, dynamic> j) => TextLayer(
        id: j['id'] as String, text: j['text'] as String,
        positionMs: ((j['positionMs'] ?? 0) as num).toInt(),
        durationMs: ((j['durationMs'] ?? 3000) as num).toInt(),
        fontSize: ((j['fontSize'] ?? 32) as num).toDouble(),
      );
}

class SubtitleCue {
  const SubtitleCue({required this.id, required this.text, required this.startMs, required this.endMs});
  final String id;
  final String text;
  final int startMs;
  final int endMs;

  Map<String, dynamic> toJson() =>
      {'id': id, 'text': text, 'startMs': startMs, 'endMs': endMs};
  factory SubtitleCue.fromJson(Map<String, dynamic> j) => SubtitleCue(
        id: j['id'] as String, text: j['text'] as String,
        startMs: (j['startMs'] as num).toInt(), endMs: (j['endMs'] as num).toInt(),
      );
}

class GraceProject {
  GraceProject({
    String? id,
    required this.name,
    required this.kind,
    CanvasSettings? canvas,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        canvas = canvas ?? CanvasSettings.fromPreset(CanvasPreset.portrait1080x1920),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  String name;
  final ProjectKind kind;
  CanvasSettings canvas;
  final List<MediaAsset> assets = [];
  final List<VideoClip> clips = [];
  final List<TextLayer> texts = [];
  final List<SubtitleCue> subtitles = [];
  DateTime createdAt;
  DateTime updatedAt;

  void touch() => updatedAt = DateTime.now();

  int get totalDurationMs => clips.fold(0, (s, c) => s + c.durationMs);

  String formatDuration() {
    final totalSec = totalDurationMs ~/ 1000;
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': graceProjectSchemaVersion,
        'id': id, 'name': name, 'kind': kind.name,
        'canvas': canvas.toJson(),
        'assets': assets.map((a) => a.toJson()).toList(),
        'clips': clips.map((c) => c.toJson()).toList(),
        'texts': texts.map((t) => t.toJson()).toList(),
        'subtitles': subtitles.map((s) => s.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory GraceProject.fromJson(Map<String, dynamic> j) {
    final p = GraceProject(
      id: j['id'] as String,
      name: j['name'] as String,
      kind: ProjectKind.values.byName(j['kind'] as String),
      canvas: CanvasSettings.fromJson(j['canvas'] as Map<String, dynamic>),
      createdAt: DateTime.parse(j['createdAt'] as String),
      updatedAt: DateTime.parse(j['updatedAt'] as String),
    );
    for (final a in (j['assets'] as List? ?? [])) {
      p.assets.add(MediaAsset.fromJson(a as Map<String, dynamic>));
    }
    for (final c in (j['clips'] as List? ?? [])) {
      p.clips.add(VideoClip.fromJson(c as Map<String, dynamic>));
    }
    for (final t in (j['texts'] as List? ?? [])) {
      p.texts.add(TextLayer.fromJson(t as Map<String, dynamic>));
    }
    for (final s in (j['subtitles'] as List? ?? [])) {
      p.subtitles.add(SubtitleCue.fromJson(s as Map<String, dynamic>));
    }
    return p;
  }

  static String newId() => _uuid.v4();
}
