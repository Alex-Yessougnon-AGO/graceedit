import 'dart:io';

import 'package:flutter/material.dart';

/// Format de la vidéo finale.
enum ProjectFormat {
  vertical(9 / 16, '9:16'),
  square(1, '1:1'),
  horizontal(16 / 9, '16:9'),
  portrait(4 / 5, '4:5');

  const ProjectFormat(this.ratio, this.label);
  final double ratio;
  final String label;

  int get outputWidth => switch (this) {
    ProjectFormat.vertical => 1080,
    ProjectFormat.square => 1080,
    ProjectFormat.horizontal => 1920,
    ProjectFormat.portrait => 1080,
  };

  int get outputHeight => switch (this) {
    ProjectFormat.vertical => 1920,
    ProjectFormat.square => 1080,
    ProjectFormat.horizontal => 1080,
    ProjectFormat.portrait => 1350,
  };

  String get key => name;
  static ProjectFormat fromKey(String? key) => values.firstWhere(
    (f) => f.name == key,
    orElse: () => ProjectFormat.horizontal,
  );
}

enum FitMode {
  fill,
  fit;

  String get key => name;
  static FitMode fromKey(String? key) =>
      values.firstWhere((f) => f.name == key, orElse: () => FitMode.fill);
}

enum MediaKind {
  video,
  image,
  audio;

  static MediaKind fromKey(String? key) =>
      values.firstWhere((f) => f.name == key, orElse: () => MediaKind.video);
}

/// Un média choisi par l'utilisateur. Le fichier d'origine n'est jamais copié
/// ni modifié : le projet le référence.
@immutable
class MediaRef {
  const MediaRef({
    required this.id,
    required this.uri,
    required this.name,
    required this.kind,
    required this.durationMs,
    required this.sizeBytes,
    required this.width,
    required this.height,
    this.capturedAt,
    this.missing = false,
    this.unsupported = false,
  });

  final String id;
  final String uri;
  final String name;
  final MediaKind kind;
  final int durationMs;
  final int sizeBytes;
  final int width;
  final int height;
  final DateTime? capturedAt;
  final bool missing;
  final bool unsupported;

  bool get isVideo => kind == MediaKind.video;
  bool get isAudio => kind == MediaKind.audio;

  MediaRef copyWith({
    String? uri,
    String? name,
    bool? missing,
    bool? unsupported,
    int? durationMs,
    int? sizeBytes,
    int? width,
    int? height,
    DateTime? capturedAt,
  }) => MediaRef(
    id: id,
    uri: uri ?? this.uri,
    name: name ?? this.name,
    kind: kind,
    durationMs: durationMs ?? this.durationMs,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    width: width ?? this.width,
    height: height ?? this.height,
    capturedAt: capturedAt ?? this.capturedAt,
    missing: missing ?? this.missing,
    unsupported: unsupported ?? this.unsupported,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'uri': uri,
    'name': name,
    'kind': kind.name,
    'durationMs': durationMs,
    'sizeBytes': sizeBytes,
    'width': width,
    'height': height,
    'capturedAt': capturedAt?.toIso8601String(),
    'missing': missing,
    'unsupported': unsupported,
  };

  factory MediaRef.fromJson(Map<String, Object?> json) => MediaRef(
    id: json['id'] as String? ?? '',
    uri: json['uri'] as String? ?? '',
    name: json['name'] as String? ?? '',
    kind: MediaKind.fromKey(json['kind'] as String?),
    durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
    sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
    width: (json['width'] as num?)?.toInt() ?? 0,
    height: (json['height'] as num?)?.toInt() ?? 0,
    capturedAt: DateTime.tryParse(json['capturedAt'] as String? ?? ''),
    missing: json['missing'] == true,
    unsupported: json['unsupported'] == true,
  );

  /// Un média est introuvable si son chemin local n'existe plus. Les URI de
  /// contenu Android sont vérifiées par le service natif, pas ici.
  bool get fileMissing {
    if (missing) return true;
    if (uri.startsWith('content://')) return false;
    final path = uri.startsWith('file://') ? Uri.parse(uri).toFilePath() : uri;
    return path.isNotEmpty && !File(path).existsSync();
  }
}

@immutable
class Adjustments {
  const Adjustments({
    this.brightness = 0,
    this.contrast = 0,
    this.saturation = 0,
  });

  final double brightness;
  final double contrast;
  final double saturation;

  bool get isNeutral => brightness == 0 && contrast == 0 && saturation == 0;

  Adjustments copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
  }) => Adjustments(
    brightness: brightness ?? this.brightness,
    contrast: contrast ?? this.contrast,
    saturation: saturation ?? this.saturation,
  );

  Map<String, Object?> toJson() => {
    'brightness': brightness,
    'contrast': contrast,
    'saturation': saturation,
  };

  factory Adjustments.fromJson(Map<String, Object?>? json) => Adjustments(
    brightness: (json?['brightness'] as num?)?.toDouble() ?? 0,
    contrast: (json?['contrast'] as num?)?.toDouble() ?? 0,
    saturation: (json?['saturation'] as num?)?.toDouble() ?? 0,
  );
}

@immutable
class Clip {
  const Clip({
    required this.id,
    required this.mediaId,
    required this.trimStartMs,
    required this.trimEndMs,
    this.volume = 100,
    this.adjustments = const Adjustments(),
    this.rotation = 0,
    this.mirrored = false,
    this.straighten = 0,
  });

  final String id;
  final String mediaId;
  final int trimStartMs;
  final int trimEndMs;
  final double volume;
  final Adjustments adjustments;
  final int rotation;
  final bool mirrored;
  final double straighten;

  int get durationMs => (trimEndMs - trimStartMs).clamp(0, 1 << 62);

  Clip copyWith({
    String? id,
    String? mediaId,
    int? trimStartMs,
    int? trimEndMs,
    double? volume,
    Adjustments? adjustments,
    int? rotation,
    bool? mirrored,
    double? straighten,
  }) => Clip(
    id: id ?? this.id,
    mediaId: mediaId ?? this.mediaId,
    trimStartMs: trimStartMs ?? this.trimStartMs,
    trimEndMs: trimEndMs ?? this.trimEndMs,
    volume: volume ?? this.volume,
    adjustments: adjustments ?? this.adjustments,
    rotation: rotation ?? this.rotation,
    mirrored: mirrored ?? this.mirrored,
    straighten: straighten ?? this.straighten,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'mediaId': mediaId,
    'trimStartMs': trimStartMs,
    'trimEndMs': trimEndMs,
    'volume': volume,
    'adjustments': adjustments.toJson(),
    'rotation': rotation,
    'mirrored': mirrored,
    'straighten': straighten,
  };

  factory Clip.fromJson(Map<String, Object?> json) => Clip(
    id: json['id'] as String? ?? '',
    mediaId: json['mediaId'] as String? ?? '',
    trimStartMs: (json['trimStartMs'] as num?)?.toInt() ?? 0,
    trimEndMs: (json['trimEndMs'] as num?)?.toInt() ?? 0,
    volume: (json['volume'] as num?)?.toDouble() ?? 100,
    adjustments: Adjustments.fromJson(
      (json['adjustments'] as Map?)?.cast<String, Object?>(),
    ),
    rotation: (json['rotation'] as num?)?.toInt() ?? 0,
    mirrored: json['mirrored'] == true,
    straighten: (json['straighten'] as num?)?.toDouble() ?? 0,
  );
}

enum TextPreset {
  title,
  subtitle,
  caption;

  static TextPreset fromKey(String? key) =>
      values.firstWhere((p) => p.name == key, orElse: () => TextPreset.caption);
}

@immutable
class TextItem {
  const TextItem({
    required this.id,
    required this.text,
    required this.startMs,
    required this.durationMs,
    this.preset = TextPreset.caption,
    this.color = 0xFFF6F2EA,
    this.size = 28,
    this.opacity = 100,
    this.align = TextAlign.center,
    this.x = 0.5,
    this.y = 0.5,
    this.rotation = 0,
    this.background = false,
  });

  final String id;
  final String text;
  final int startMs;
  final int durationMs;
  final TextPreset preset;
  final int color;
  final double size;
  final double opacity;
  final TextAlign align;
  final double x;
  final double y;
  final double rotation;
  final bool background;

  int get endMs => startMs + durationMs;

  TextItem copyWith({
    String? id,
    String? text,
    int? startMs,
    int? durationMs,
    TextPreset? preset,
    int? color,
    double? size,
    double? opacity,
    TextAlign? align,
    double? x,
    double? y,
    double? rotation,
    bool? background,
  }) => TextItem(
    id: id ?? this.id,
    text: text ?? this.text,
    startMs: startMs ?? this.startMs,
    durationMs: durationMs ?? this.durationMs,
    preset: preset ?? this.preset,
    color: color ?? this.color,
    size: size ?? this.size,
    opacity: opacity ?? this.opacity,
    align: align ?? this.align,
    x: x ?? this.x,
    y: y ?? this.y,
    rotation: rotation ?? this.rotation,
    background: background ?? this.background,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'text': text,
    'startMs': startMs,
    'durationMs': durationMs,
    'preset': preset.name,
    'color': color,
    'size': size,
    'opacity': opacity,
    'align': align.name,
    'x': x,
    'y': y,
    'rotation': rotation,
    'background': background,
  };

  factory TextItem.fromJson(Map<String, Object?> json) => TextItem(
    id: json['id'] as String? ?? '',
    text: json['text'] as String? ?? '',
    startMs: (json['startMs'] as num?)?.toInt() ?? 0,
    durationMs: (json['durationMs'] as num?)?.toInt() ?? 3000,
    preset: TextPreset.fromKey(json['preset'] as String?),
    color: (json['color'] as num?)?.toInt() ?? 0xFFF6F2EA,
    size: (json['size'] as num?)?.toDouble() ?? 28,
    opacity: (json['opacity'] as num?)?.toDouble() ?? 100,
    align: TextAlign.values.firstWhere(
      (a) => a.name == json['align'],
      orElse: () => TextAlign.center,
    ),
    x: (json['x'] as num?)?.toDouble() ?? 0.5,
    y: (json['y'] as num?)?.toDouble() ?? 0.5,
    rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
    background: json['background'] == true,
  );
}

@immutable
class AudioItem {
  const AudioItem({
    required this.id,
    required this.mediaId,
    required this.startMs,
    required this.trimStartMs,
    required this.trimEndMs,
    this.volume = 100,
    this.fadeInMs = 0,
    this.fadeOutMs = 0,
  });

  final String id;
  final String mediaId;
  final int startMs;
  final int trimStartMs;
  final int trimEndMs;
  final double volume;
  final int fadeInMs;
  final int fadeOutMs;

  int get durationMs => (trimEndMs - trimStartMs).clamp(0, 1 << 62);
  int get endMs => startMs + durationMs;

  AudioItem copyWith({
    String? id,
    int? startMs,
    int? trimStartMs,
    int? trimEndMs,
    double? volume,
    int? fadeInMs,
    int? fadeOutMs,
  }) => AudioItem(
    id: id ?? this.id,
    mediaId: mediaId,
    startMs: startMs ?? this.startMs,
    trimStartMs: trimStartMs ?? this.trimStartMs,
    trimEndMs: trimEndMs ?? this.trimEndMs,
    volume: volume ?? this.volume,
    fadeInMs: fadeInMs ?? this.fadeInMs,
    fadeOutMs: fadeOutMs ?? this.fadeOutMs,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'mediaId': mediaId,
    'startMs': startMs,
    'trimStartMs': trimStartMs,
    'trimEndMs': trimEndMs,
    'volume': volume,
    'fadeInMs': fadeInMs,
    'fadeOutMs': fadeOutMs,
  };

  factory AudioItem.fromJson(Map<String, Object?> json) => AudioItem(
    id: json['id'] as String? ?? '',
    mediaId: json['mediaId'] as String? ?? '',
    startMs: (json['startMs'] as num?)?.toInt() ?? 0,
    trimStartMs: (json['trimStartMs'] as num?)?.toInt() ?? 0,
    trimEndMs: (json['trimEndMs'] as num?)?.toInt() ?? 0,
    volume: (json['volume'] as num?)?.toDouble() ?? 100,
    fadeInMs: (json['fadeInMs'] as num?)?.toInt() ?? 0,
    fadeOutMs: (json['fadeOutMs'] as num?)?.toInt() ?? 0,
  );
}

enum CoverSource {
  automatic,
  videoFrame,
  gallery;

  static CoverSource fromKey(String? key) => values.firstWhere(
    (c) => c.name == key,
    orElse: () => CoverSource.automatic,
  );
}

/// Résultat d'un export réellement produit.
@immutable
class ExportRecord {
  const ExportRecord({
    required this.path,
    required this.name,
    required this.width,
    required this.height,
    required this.durationMs,
    required this.sizeBytes,
    required this.createdAt,
    required this.inGallery,
  });

  final String path;
  final String name;
  final int width;
  final int height;
  final int durationMs;
  final int sizeBytes;
  final DateTime createdAt;
  final bool inGallery;

  Map<String, Object?> toJson() => {
    'path': path,
    'name': name,
    'width': width,
    'height': height,
    'durationMs': durationMs,
    'sizeBytes': sizeBytes,
    'createdAt': createdAt.toIso8601String(),
    'inGallery': inGallery,
  };

  factory ExportRecord.fromJson(Map<String, Object?> json) => ExportRecord(
    path: json['path'] as String? ?? '',
    name: json['name'] as String? ?? '',
    width: (json['width'] as num?)?.toInt() ?? 0,
    height: (json['height'] as num?)?.toInt() ?? 0,
    durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
    sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    inGallery: json['inGallery'] == true,
  );
}

@immutable
class Project {
  const Project({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.modifiedAt,
    this.format = ProjectFormat.horizontal,
    this.fitMode = FitMode.fill,
    this.media = const [],
    this.clips = const [],
    this.texts = const [],
    this.audios = const [],
    this.videoVolume = 100,
    this.musicMuted = false,
    this.coverSource = CoverSource.automatic,
    this.coverTimeMs = 0,
    this.coverPath,
    this.coverZoom = 1,
    this.coverOffsetX = 0,
    this.coverOffsetY = 0,
    this.trashedAt,
    this.recovered = false,
    this.lastExport,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final ProjectFormat format;
  final FitMode fitMode;
  final List<MediaRef> media;
  final List<Clip> clips;
  final List<TextItem> texts;
  final List<AudioItem> audios;
  final double videoVolume;

  /// Piste Musique coupée d'un geste (Phase 2) : les volumes individuels
  /// des éléments sont conservés, seul le rendu est mis à zéro.
  final bool musicMuted;
  final CoverSource coverSource;
  final int coverTimeMs;
  final String? coverPath;

  /// Recadrage de la couverture de galerie : zoom (1 à 4) et décalage
  /// normalisé par rapport à la taille affichée.
  final double coverZoom;
  final double coverOffsetX;
  final double coverOffsetY;
  final DateTime? trashedAt;
  final bool recovered;
  final ExportRecord? lastExport;

  bool get isTrashed => trashedAt != null;
  bool get isEmpty => clips.isEmpty;

  MediaRef? mediaById(String id) {
    for (final m in media) {
      if (m.id == id) return m;
    }
    return null;
  }

  List<MediaRef> get missingMedia =>
      media.where((m) => m.missing || m.fileMissing).toList();

  bool get hasMissingMedia => missingMedia.isNotEmpty;

  int get durationMs {
    var total = 0;
    for (final clip in clips) {
      total += clip.durationMs;
    }
    return total;
  }

  double get videoVolumeValue => videoVolume.clamp(0, 100).toDouble();

  bool get hasCustomClipVolume => clips.any((c) => c.volume != 100);

  MediaRef? get firstVideo {
    for (final m in media) {
      if (m.isVideo || m.kind == MediaKind.image) return m;
    }
    return null;
  }

  CoverSource get effectiveCoverSource => coverSource;

  /// La couverture automatique est la première image de la vidéo.
  String? get coverFilePath =>
      coverSource == CoverSource.gallery ? coverPath : null;

  Project copyWith({
    String? title,
    DateTime? modifiedAt,
    ProjectFormat? format,
    FitMode? fitMode,
    List<MediaRef>? media,
    List<Clip>? clips,
    List<TextItem>? texts,
    List<AudioItem>? audios,
    double? videoVolume,
    bool? musicMuted,
    CoverSource? coverSource,
    int? coverTimeMs,
    String? coverPath,
    double? coverZoom,
    double? coverOffsetX,
    double? coverOffsetY,
    DateTime? trashedAt,
    bool clearTrash = false,
    bool? recovered,
    ExportRecord? lastExport,
  }) => Project(
    id: id,
    title: title ?? this.title,
    createdAt: createdAt,
    modifiedAt: modifiedAt ?? this.modifiedAt,
    format: format ?? this.format,
    fitMode: fitMode ?? this.fitMode,
    media: media ?? this.media,
    clips: clips ?? this.clips,
    texts: texts ?? this.texts,
    audios: audios ?? this.audios,
    videoVolume: videoVolume ?? this.videoVolume,
    musicMuted: musicMuted ?? this.musicMuted,
    coverSource: coverSource ?? this.coverSource,
    coverTimeMs: coverTimeMs ?? this.coverTimeMs,
    coverPath: coverPath ?? this.coverPath,
    coverZoom: coverZoom ?? this.coverZoom,
    coverOffsetX: coverOffsetX ?? this.coverOffsetX,
    coverOffsetY: coverOffsetY ?? this.coverOffsetY,
    trashedAt: clearTrash ? null : (trashedAt ?? this.trashedAt),
    recovered: recovered ?? this.recovered,
    lastExport: lastExport ?? this.lastExport,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'modifiedAt': modifiedAt.toIso8601String(),
    'format': format.name,
    'fitMode': fitMode.name,
    'media': media.map((m) => m.toJson()).toList(),
    'clips': clips.map((c) => c.toJson()).toList(),
    'texts': texts.map((t) => t.toJson()).toList(),
    'audios': audios.map((a) => a.toJson()).toList(),
    'videoVolume': videoVolume,
    'musicMuted': musicMuted,
    'coverSource': coverSource.name,
    'coverTimeMs': coverTimeMs,
    'coverPath': coverPath,
    'coverZoom': coverZoom,
    'coverOffsetX': coverOffsetX,
    'coverOffsetY': coverOffsetY,
    'trashedAt': trashedAt?.toIso8601String(),
    'recovered': recovered,
    'lastExport': lastExport?.toJson(),
  };

  factory Project.fromJson(Map<String, Object?> json) {
    List<T> list<T>(String key, T Function(Map<String, Object?>) parse) =>
        ((json[key] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => parse(e.cast<String, Object?>()))
            .toList();
    return Project(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      modifiedAt:
          DateTime.tryParse(json['modifiedAt'] as String? ?? '') ??
          DateTime.now(),
      format: ProjectFormat.fromKey(json['format'] as String?),
      fitMode: FitMode.fromKey(json['fitMode'] as String?),
      media: list('media', MediaRef.fromJson),
      clips: list('clips', Clip.fromJson),
      texts: list('texts', TextItem.fromJson),
      audios: list('audios', AudioItem.fromJson),
      videoVolume: (json['videoVolume'] as num?)?.toDouble() ?? 100,
      musicMuted: json['musicMuted'] == true,
      coverSource: CoverSource.fromKey(json['coverSource'] as String?),
      coverTimeMs: (json['coverTimeMs'] as num?)?.toInt() ?? 0,
      coverPath: json['coverPath'] as String?,
      coverZoom: ((json['coverZoom'] as num?)?.toDouble() ?? 1).clamp(1, 4),
      coverOffsetX: (json['coverOffsetX'] as num?)?.toDouble() ?? 0,
      coverOffsetY: (json['coverOffsetY'] as num?)?.toDouble() ?? 0,
      trashedAt: DateTime.tryParse(json['trashedAt'] as String? ?? ''),
      recovered: json['recovered'] == true,
      lastExport: json['lastExport'] == null
          ? null
          : ExportRecord.fromJson(
              (json['lastExport'] as Map).cast<String, Object?>(),
            ),
    );
  }
}
