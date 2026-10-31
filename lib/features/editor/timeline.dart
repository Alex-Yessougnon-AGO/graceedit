import 'dart:math' as math;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/models/project.dart';
import '../../core/state/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/thumb.dart';
import '../../core/utils/formatters.dart';
import 'editor_controller.dart';

/// Hauteur de la piste « Son vidéo » (forme d'onde du son d'origine,
/// séparée de la bande d'images comme dans CapCut/VN).
const double _nativeAudioTrack = 28;

class EditorTimeline extends StatelessWidget {
  const EditorTimeline({
    super.key,
    required this.controller,
    required this.onAddMedia,
    this.onSplitClip,
  });

  final EditorController controller;
  final VoidCallback onAddMedia;

  /// Double-tap sur un clip : scinder à la tête de lecture (l'écran
  /// affiche le message « Clip scindé · Annuler »).
  final VoidCallback? onSplitClip;

  double get _pxPerSec => GraceDims.timelinePxPerSec * controller.zoom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final project = controller.project;
    final durations = _durations(project);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        // Projet plus court qu'un écran : on centre le contenu et la tête de
        // lecture suit. Sinon, la tête reste au centre et le contenu défile
        // dessous (EDT-01). Sans ce cas, un projet court s'ouvrait avec la
        // moitié gauche vide et la fin du clip hors de l'écran.
        final contentWidth = project.durationMs / 1000 * _pxPerSec;
        final fits = contentWidth <= width;
        final origin = fits
            ? (width - contentWidth) / 2
            : width / 2 - controller.positionMs / 1000 * _pxPerSec;
        final playheadX = fits
            ? origin + controller.positionMs / 1000 * _pxPerSec
            : width / 2;
        final hasTexts = project.texts.isNotEmpty;
        final hasAudio = project.audios.isNotEmpty;
        // Piste « Son vidéo » : présente dès qu'un clip vidéo existe. Ses
        // segments restent alignés sous les clips (mêmes positions), le
        // son suit donc le rognage et le scindage sans état supplémentaire.
        final hasNativeAudio = project.clips.any((clip) {
          final media = project.mediaById(clip.mediaId);
          return media != null && media.kind == MediaKind.video;
        });
        var top = GraceDims.ruler + 4;
        final videoTop = top;
        top += GraceDims.videoTrack + 8;
        final nativeTop = top;
        if (hasNativeAudio) top += _nativeAudioTrack + 8;
        final textTop = top;
        if (hasTexts) top += GraceDims.subTrack + 8;
        final audioTop = top;
        // La tête de lecture s'arrête au bas de la dernière voie : elle ne
        // traverse pas la zone vide de la timeline (maquette EDT-01).
        var contentBottom = videoTop + GraceDims.videoTrack;
        if (hasNativeAudio) contentBottom = nativeTop + _nativeAudioTrack;
        if (hasTexts) contentBottom = textTop + GraceDims.subTrack;
        if (hasAudio) contentBottom = audioTop + GraceDims.subTrack;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.clearSelection,
          onScaleStart: (details) {
            if (details.pointerCount > 1) controller.beginPinch();
          },
          onScaleEnd: (_) => controller.endPinch(),
          onScaleUpdate: (details) {
            if (details.pointerCount > 1) {
              // `details.scale` est cumulatif depuis le début du geste.
              controller.updatePinch(details.scale);
            } else if (details.focalPointDelta.dx.abs() > 0.1) {
              controller.scrubBy(
                (-details.focalPointDelta.dx / _pxPerSec * 1000).round(),
              );
            }
          },
          child: SizedBox(
            height: height,
            width: width,
            child: Stack(
              // La tête de lecture dépasse au-dessus de la règle, sous le
              // bouton de lecture, comme sur la maquette EDT-01.
              clipBehavior: ui.Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RulerPainter(
                      pxPerSec: _pxPerSec,
                      origin: origin,
                      width: width,
                      color: context.grace.secondary,
                    ),
                  ),
                ),
                // Vidéo.
                Positioned(
                  left: 0,
                  right: 0,
                  top: videoTop,
                  height: GraceDims.videoTrack,
                  child: ClipRect(
                    child: Stack(
                      clipBehavior: ui.Clip.hardEdge,
                      children: [
                        for (final clip in project.clips)
                          _positionedClip(
                            context,
                            clip,
                            origin,
                            project,
                            durations[clip.id] ?? 0,
                          ),
                        // Les poignées sont dessinées au-dessus de tous les
                        // clips pour garder une zone tactile de 48 dp même
                        // lorsqu'elle déborde sur le clip voisin.
                        ..._trimHandles(project, origin, l10n),
                        if (project.clips.isEmpty)
                          Positioned.fill(
                            child: _EmptyTrack(onAdd: onAddMedia, l10n: l10n),
                          ),
                      ],
                    ),
                  ),
                ),
                if (hasNativeAudio)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: nativeTop,
                    height: _nativeAudioTrack,
                    child: ClipRect(
                      child: Stack(
                        clipBehavior: ui.Clip.hardEdge,
                        children: [
                          for (final clip in project.clips)
                            _positionedClipWave(
                              context,
                              clip,
                              origin,
                              project,
                              durations[clip.id] ?? 0,
                            ),
                        ],
                      ),
                    ),
                  ),
                if (hasTexts)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: textTop,
                    height: GraceDims.subTrack,
                    child: ClipRect(
                      child: Stack(
                        clipBehavior: ui.Clip.hardEdge,
                        children: [
                          for (final text in project.texts)
                            _positionedText(context, text, origin),
                          // Poignées de durée du texte sélectionné.
                          ..._textTrimHandles(project, origin, l10n),
                        ],
                      ),
                    ),
                  ),
                if (hasAudio)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: audioTop,
                    height: GraceDims.subTrack,
                    child: ClipRect(
                      child: Stack(
                        clipBehavior: ui.Clip.hardEdge,
                        children: [
                          for (final audio in project.audios)
                            _positionedAudio(context, audio, origin, project),
                          ..._audioTrimHandles(project, origin, l10n),
                        ],
                      ),
                    ),
                  ),
                // Tête de lecture fixe, arrêtée au bas de la dernière voie.
                Positioned(
                  left: playheadX - GraceDims.playheadHead / 2,
                  top: -GraceDims.playheadHead,
                  width: GraceDims.playheadHead,
                  height: contentBottom + GraceDims.playheadHead + 2,
                  child: IgnorePointer(
                    child: Column(
                      children: [
                        const _PlayheadHead(),
                        Expanded(
                          child: Container(
                            width: GraceDims.playheadLine,
                            color: GraceColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, int> _durations(Project project) {
    final map = <String, int>{};
    var start = 0;
    for (final c in project.clips) {
      map[c.id] = start;
      start += c.durationMs;
    }
    return map;
  }

  Widget _positionedClip(
    BuildContext context,
    Clip clip,
    double origin,
    Project project,
    int clipStart,
  ) {
    final px = clip.durationMs / 1000 * _pxPerSec;
    final clipWidth = math.max(px, 16.0);
    final left = origin + clipStart / 1000 * _pxPerSec;
    final selected =
        controller.selection == SelectionType.clip &&
        controller.selectedId == clip.id;
    final media = project.mediaById(clip.mediaId);
    final missing = media != null && (media.missing || media.fileMissing);
    final l10n = AppLocalizations.of(context);
    final index = project.clips.indexOf(clip);
    return Positioned(
      left: left,
      top: 0,
      width: clipWidth,
      height: GraceDims.videoTrack,
      child: Semantics(
        button: true,
        selected: selected,
        label: l10n.timelineClipLabel(
          index + 1,
          formatDurationSpoken(clip.durationMs, l10n),
        ),
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () => controller.selectClip(clip.id),
          // Double-tap : scinder à la tête de lecture, sans passer par la
          // barre d'outils (geste standard des éditeurs mobiles).
          onDoubleTap: onSplitClip == null
              ? null
              : () {
                  controller.selectClip(clip.id);
                  onSplitClip!.call();
                },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GraceRadius.thumb),
            ),
            // Le contour de sélection est peint au-dessus du clip : dans
            // `decoration`, il réduisait le contenu de 3 dp et laissait un
            // espace vide entre deux clips issus d'un scindage.
            foregroundDecoration: selected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(GraceRadius.thumb),
                    border: Border.all(color: context.grace.text, width: 3),
                  )
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (missing)
                    ColoredBox(
                      color: context.grace.surface,
                      child: Center(
                        child: Icon(
                          Icons.warning_amber_rounded,
                          size: 22,
                          color: context.grace.error,
                        ),
                      ),
                    )
                  else
                    _ClipFrames(media: media, clip: clip, width: clipWidth),
                  // Séparation nette entre clips : après un scindage, les
                  // deux morceaux doivent se lire comme deux éléments.
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 1.5,
                      color: GraceColors.ivory.withValues(alpha: 0.45),
                    ),
                  ),
                  // Le badge de durée n'apparaît que si le clip est assez large
                  // pour le contenir sans le rogner.
                  if (clipWidth >= 52)
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        height: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: GraceColors.ink.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          formatDuration(clip.durationMs),
                          style: GraceType.timecodeSmall.copyWith(
                            color: GraceColors.ivory,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Segment de la piste « Son vidéo » aligné sous son clip : forme d'onde
  /// du son d'origine découpée sur la plage rognée du clip.
  Widget _positionedClipWave(
    BuildContext context,
    Clip clip,
    double origin,
    Project project,
    int clipStart,
  ) {
    final media = project.mediaById(clip.mediaId);
    if (media == null || media.kind != MediaKind.video) {
      return const SizedBox.shrink();
    }
    final px = clip.durationMs / 1000 * _pxPerSec;
    final clipWidth = math.max(px, 16.0);
    final left = origin + clipStart / 1000 * _pxPerSec;
    final missing = media.missing || media.fileMissing;
    return Positioned(
      left: left,
      top: 0,
      width: clipWidth,
      height: _nativeAudioTrack,
      child: missing
          ? ColoredBox(color: context.grace.surface)
          : _ClipWaveform(
              media: media,
              clip: clip,
              muted: clip.volume <= 0 || project.videoVolumeValue <= 0,
            ),
    );
  }

  /// Poignées de rognage du clip sélectionné : 14 dp visibles, 48 dp de zone
  /// tactile, dessinées au-dessus des clips voisins.
  List<Widget> _trimHandles(
    Project project,
    double origin,
    AppLocalizations l10n,
  ) {
    if (controller.selection != SelectionType.clip) return const [];
    final clip = controller.selectedClip;
    if (clip == null) return const [];
    final start = _durations(project)[clip.id] ?? 0;
    final left = origin + start / 1000 * _pxPerSec;
    final clipWidth = math.max(clip.durationMs / 1000 * _pxPerSec, 16.0);
    const visual = GraceDims.trimHandle;
    const touch = GraceDims.touch;
    final outside = touch - visual;
    return [
      Positioned(
        left: left - outside,
        top: 0,
        width: touch,
        height: GraceDims.videoTrack,
        child: _TrimHandle(
          atRight: true,
          label: l10n.trimHandleStartLabel,
          onStart: controller.beginGesture,
          onEnd: controller.endGesture,
          onDrag: (delta) => controller.trimClip(
            clip.id,
            start: clip.trimStartMs + (delta / _pxPerSec * 1000).round(),
          ),
        ),
      ),
      Positioned(
        left: left + clipWidth - visual,
        top: 0,
        width: touch,
        height: GraceDims.videoTrack,
        child: _TrimHandle(
          atRight: false,
          label: l10n.trimHandleEndLabel,
          onStart: controller.beginGesture,
          onEnd: controller.endGesture,
          onDrag: (delta) => controller.trimClip(
            clip.id,
            end: clip.trimEndMs + (delta / _pxPerSec * 1000).round(),
          ),
        ),
      ),
    ];
  }

  Widget _positionedText(BuildContext context, TextItem text, double origin) {
    final px = text.durationMs / 1000 * _pxPerSec;
    final left = origin + text.startMs / 1000 * _pxPerSec;
    final selected =
        controller.selection == SelectionType.text &&
        controller.selectedId == text.id;
    final l10n = AppLocalizations.of(context);
    return Positioned(
      left: left,
      top: 0,
      width: math.max(px, 24),
      height: GraceDims.subTrack,
      child: Semantics(
        button: true,
        selected: selected,
        label: l10n.timelineTextLabel(text.text),
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () => controller.selectText(text.id),
          // Glisser déplace le texte dans le temps (aimantation comprise),
          // comme un élément audio : c'était le geste manquant le plus
          // visible pour un débutant.
          onHorizontalDragStart: (_) => controller.beginGesture(),
          onHorizontalDragUpdate: (details) => controller.moveText(
            text.id,
            (details.delta.dx / _pxPerSec * 1000).round(),
          ),
          onHorizontalDragEnd: (_) => controller.endGesture(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Container(
                decoration: BoxDecoration(
                  color: context.grace.active,
                  borderRadius: BorderRadius.circular(6),
                ),
                foregroundDecoration: selected
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: context.grace.text, width: 3),
                      )
                    : null,
                padding: EdgeInsets.symmetric(horizontal: width >= 48 ? 8 : 2),
                child: Row(
                  children: [
                    Icon(Icons.title, size: 14, color: context.grace.text),
                    if (width >= 56) ...[
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          text.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GraceType.caption,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Poignées de durée du texte sélectionné (début et fin), mêmes règles
  /// que les poignées audio : 14 dp visibles, 48 dp de zone tactile.
  List<Widget> _textTrimHandles(
    Project project,
    double origin,
    AppLocalizations l10n,
  ) {
    if (controller.selection != SelectionType.text) return const [];
    final text = controller.selectedText;
    if (text == null) return const [];
    final left = origin + text.startMs / 1000 * _pxPerSec;
    final width = math.max(text.durationMs / 1000 * _pxPerSec, 24.0);
    const visual = GraceDims.trimHandle;
    const touch = GraceDims.touch;
    final outside = touch - visual;
    return [
      Positioned(
        left: left - outside,
        top: 0,
        width: touch,
        height: GraceDims.subTrack,
        child: _TrimHandle(
          atRight: true,
          label: l10n.trimHandleStartLabel,
          onStart: controller.beginGesture,
          onEnd: controller.endGesture,
          onDrag: (delta) => controller.resizeText(
            text.id,
            leftDeltaMs: (delta / _pxPerSec * 1000).round(),
          ),
        ),
      ),
      Positioned(
        left: left + width - visual,
        top: 0,
        width: touch,
        height: GraceDims.subTrack,
        child: _TrimHandle(
          atRight: false,
          label: l10n.trimHandleEndLabel,
          onStart: controller.beginGesture,
          onEnd: controller.endGesture,
          onDrag: (delta) => controller.resizeText(
            text.id,
            rightDeltaMs: (delta / _pxPerSec * 1000).round(),
          ),
        ),
      ),
    ];
  }

  Widget _positionedAudio(
    BuildContext context,
    AudioItem audio,
    double origin,
    Project project,
  ) {
    final px = audio.durationMs / 1000 * _pxPerSec;
    final left = origin + audio.startMs / 1000 * _pxPerSec;
    final selected =
        controller.selection == SelectionType.audio &&
        controller.selectedId == audio.id;
    final media = project.mediaById(audio.mediaId);
    final l10n = AppLocalizations.of(context);
    return Positioned(
      left: left,
      top: 0,
      width: math.max(px, 24),
      height: GraceDims.subTrack,
      child: Semantics(
        button: true,
        selected: selected,
        label: l10n.timelineAudioLabel(media?.name ?? ''),
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () => controller.selectAudio(audio.id),
          onHorizontalDragStart: (_) => controller.beginGesture(),
          onHorizontalDragUpdate: (details) => controller.moveAudio(
            audio.id,
            (details.delta.dx / _pxPerSec * 1000).round(),
          ),
          onHorizontalDragEnd: (_) => controller.endGesture(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final showIcon = width >= 48;
              final showName = width >= 140;
              final duration = audio.durationMs;
              return Container(
                decoration: BoxDecoration(
                  color: context.grace.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                foregroundDecoration: selected
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: context.grace.text, width: 3),
                      )
                    : null,
                padding: EdgeInsets.symmetric(horizontal: width >= 48 ? 8 : 2),
                child: Row(
                  children: [
                    if (showIcon) ...[
                      Icon(
                        Icons.music_note,
                        size: 14,
                        color: context.grace.text,
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (showName)
                      Flexible(
                        flex: 2,
                        child: Text(
                          media?.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GraceType.caption,
                        ),
                      ),
                    if (showName) const SizedBox(width: 8),
                    Expanded(
                      flex: showName ? 3 : 1,
                      child: _Waveform(
                        media: media,
                        color: context.grace.secondary,
                        fadeIn: duration > 0 ? audio.fadeInMs / duration : 0,
                        fadeOut: duration > 0 ? audio.fadeOutMs / duration : 0,
                      ),
                    ),
                    if (width >= 180) ...[
                      const SizedBox(width: 8),
                      Text(
                        formatDuration(duration),
                        style: GraceType.caption.copyWith(
                          color: context.grace.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Poignées de rognage de l'élément audio sélectionné : 14 dp visibles,
  /// 48 dp de zone tactile, dessinées au-dessus des éléments voisins.
  List<Widget> _audioTrimHandles(
    Project project,
    double origin,
    AppLocalizations l10n,
  ) {
    if (controller.selection != SelectionType.audio) return const [];
    final audio = controller.selectedAudio;
    if (audio == null) return const [];
    final start = audio.startMs;
    final duration = audio.durationMs;
    final left = origin + start / 1000 * _pxPerSec;
    final width = math.max(duration / 1000 * _pxPerSec, 24.0);
    const visual = GraceDims.trimHandle;
    const touch = GraceDims.touch;
    final outside = touch - visual;
    return [
      Positioned(
        left: left - outside,
        top: 0,
        width: touch,
        height: GraceDims.subTrack,
        child: _TrimHandle(
          atRight: true,
          label: l10n.trimHandleStartLabel,
          onStart: controller.beginGesture,
          onEnd: controller.endGesture,
          onDrag: (delta) => controller.resizeAudio(
            audio.id,
            leftDeltaMs: (delta / _pxPerSec * 1000).round(),
          ),
        ),
      ),
      Positioned(
        left: left + width - visual,
        top: 0,
        width: touch,
        height: GraceDims.subTrack,
        child: _TrimHandle(
          atRight: false,
          label: l10n.trimHandleEndLabel,
          onStart: controller.beginGesture,
          onEnd: controller.endGesture,
          onDrag: (delta) => controller.resizeAudio(
            audio.id,
            rightDeltaMs: (delta / _pxPerSec * 1000).round(),
          ),
        ),
      ),
    ];
  }
}

class _PlayheadHead extends StatelessWidget {
  const _PlayheadHead();

  @override
  Widget build(BuildContext context) => Container(
    width: GraceDims.playheadHead,
    height: GraceDims.playheadHead,
    decoration: const BoxDecoration(
      color: GraceColors.accent,
      shape: BoxShape.circle,
    ),
  );
}

/// Bande d'images d'un clip. Le son d'origine vit dans la piste séparée
/// « Son vidéo » juste en dessous : la décomposition images/son se lit
/// comme deux pistes, comme dans CapCut/VN.
class _ClipFrames extends StatelessWidget {
  const _ClipFrames({
    required this.media,
    required this.clip,
    required this.width,
  });

  final MediaRef? media;
  final Clip clip;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (media == null) {
      return ColoredBox(color: context.grace.surface);
    }
    // Une image environ toutes les 64 dp ; le plafond évite d'extraire des
    // dizaines de vignettes pour un clip très long.
    final count = (width / 64).ceil().clamp(1, 16);
    return Row(
      children: [
        for (var i = 0; i < count; i++)
          Expanded(
            child: GraceThumb(
              media: media,
              timeMs:
                  clip.trimStartMs +
                  (clip.durationMs * (i + 0.5) / count).round(),
              width: width / count,
              height: GraceDims.videoTrack,
              radius: 0,
              showDuration: false,
            ),
          ),
      ],
    );
  }
}

/// Forme d'onde du son d'origine du clip, découpée sur la plage rognée.
/// Aucune donnée inventée : pas de piste audio ou échec de décodage donne
/// une ligne plate, un son coupé donne une onde atténuée et une icône.
class _ClipWaveform extends StatefulWidget {
  const _ClipWaveform({
    required this.media,
    required this.clip,
    required this.muted,
  });

  final MediaRef media;
  final Clip clip;
  final bool muted;

  @override
  State<_ClipWaveform> createState() => _ClipWaveformState();
}

class _ClipWaveformState extends State<_ClipWaveform> {
  Future<List<double>?>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_ClipWaveform old) {
    super.didUpdateWidget(old);
    if (old.media.id != widget.media.id) _load();
  }

  void _load() {
    _future = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(thumbnailServiceProvider).waveform(widget.media);
  }

  List<double> _slice(List<double> values) {
    final total = widget.media.durationMs;
    if (values.isEmpty || total <= 0) return values;
    final start = (widget.clip.trimStartMs / total * values.length)
        .floor()
        .clamp(0, values.length - 1);
    final end = (widget.clip.trimEndMs / total * values.length).ceil().clamp(
      start + 1,
      values.length,
    );
    return values.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GraceColors.ink.withValues(alpha: 0.62),
      child: FutureBuilder<List<double>?>(
        future: _future,
        builder: (context, snapshot) {
          final values = snapshot.data;
          final sliced = values == null ? null : _slice(values);
          return Row(
            children: [
              if (widget.muted)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.volume_off,
                    size: 12,
                    color: GraceColors.ivory,
                  ),
                ),
              Expanded(
                child: sliced == null || sliced.isEmpty
                    // En préparation, sans piste audio ou illisible : ligne
                    // plate, jamais une fausse onde.
                    ? Center(
                        child: Container(
                          height: 1.5,
                          color: GraceColors.ivory.withValues(alpha: 0.5),
                        ),
                      )
                    : SizedBox.expand(
                        child: CustomPaint(
                          painter: _WavePainter(
                            values: sliced,
                            color: GraceColors.ivory.withValues(
                              alpha: widget.muted ? 0.35 : 0.9,
                            ),
                            fadeIn: 0,
                            fadeOut: 0,
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TrimHandle extends StatefulWidget {
  const _TrimHandle({
    required this.atRight,
    required this.label,
    required this.onStart,
    required this.onDrag,
    required this.onEnd,
  });

  /// Vrai pour la poignée de gauche : sa partie visible est collée au bord
  /// droit de la zone tactile (le reste déborde à gauche du clip).
  final bool atRight;

  /// Libellé traduit pour le lecteur d'écran (le rognage précis ±100 ms
  /// reste l'alternative sans glisser).
  final String label;
  final VoidCallback onStart;
  final ValueChanged<double> onDrag;
  final VoidCallback onEnd;

  @override
  State<_TrimHandle> createState() => _TrimHandleState();
}

class _TrimHandleState extends State<_TrimHandle> {
  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Semantics(
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => widget.onStart(),
        onHorizontalDragUpdate: (details) => widget.onDrag(details.delta.dx),
        onHorizontalDragEnd: (_) => widget.onEnd(),
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: Align(
            alignment: widget.atRight
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              width: GraceDims.trimHandle,
              color: p.text,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 1.5, height: 16, color: p.background),
                    const SizedBox(width: 2),
                    Container(width: 1.5, height: 16, color: p.background),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyTrack extends StatelessWidget {
  const _EmptyTrack({required this.onAdd, required this.l10n});
  final VoidCallback onAdd;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: p.outline, width: 1.5),
          borderRadius: BorderRadius.circular(GraceRadius.small),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: p.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, size: 20, color: p.text),
            ),
            const SizedBox(width: 10),
            Text(l10n.editorAddMedia, style: GraceType.secondaryMedium),
          ],
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  _RulerPainter({
    required this.pxPerSec,
    required this.origin,
    required this.width,
    required this.color,
  });

  final double pxPerSec;
  final double origin;
  final double width;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Un libellé doit avoir au moins ~64 dp pour rester lisible. À l'échelle
    // de départ (1,2 dp/s), cela donne un trait majeur par minute et cinq
    // traits intermédiaires toutes les 10 s, comme la maquette EDT-01.
    const labelGap = 64.0;
    const steps = <int>[
      1,
      2,
      5,
      10,
      15,
      30,
      60,
      120,
      300,
      600,
      900,
      1800,
      3600,
    ];
    var major = steps.last;
    for (final step in steps) {
      if (step * pxPerSec >= labelGap) {
        major = step;
        break;
      }
    }
    final minor = major >= 30 ? major ~/ 6 : math.max(1, major ~/ 5);
    final last = ((width - origin) / pxPerSec).ceil();
    final tickPaint = Paint()
      ..color = color
      ..strokeWidth = 1;

    // Petits traits intermédiaires (sans doublon avec les traits majeurs).
    final firstMinor = math.max(
      0,
      ((-origin) / pxPerSec / minor).floor() * minor,
    );
    for (var second = firstMinor; second <= last; second += minor) {
      if (second % major == 0) continue;
      final x = origin + second * pxPerSec;
      canvas.drawLine(Offset(x, 15), Offset(x, 18), tickPaint);
    }

    final firstMajor = math.max(
      0,
      ((-origin) / pxPerSec / major).floor() * major,
    );
    for (var second = firstMajor; second <= last; second += major) {
      final x = origin + second * pxPerSec;
      canvas.drawLine(Offset(x, 12), Offset(x, 18), tickPaint);
      final painter = TextPainter(
        text: TextSpan(
          text: formatDuration(second * 1000),
          style: GraceType.timecodeSmall.copyWith(color: color),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      // Maquette EDT-01 : le libellé est aligné à droite, 6 dp avant son
      // trait majeur (et non centré dessus).
      final dx = x - painter.width - 6;
      if (dx >= 2 && dx + painter.width <= width - 2) {
        painter.paint(canvas, Offset(dx, 0));
      }
    }
  }

  @override
  bool shouldRepaint(_RulerPainter old) =>
      old.pxPerSec != pxPerSec ||
      old.origin != origin ||
      old.color != color ||
      old.width != width;
}

/// Forme d'onde réelle du média audio (aucune donnée inventée).
class _Waveform extends StatefulWidget {
  const _Waveform({
    required this.media,
    required this.color,
    required this.fadeIn,
    required this.fadeOut,
  });

  final MediaRef? media;
  final Color color;
  final double fadeIn;
  final double fadeOut;

  @override
  State<_Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<_Waveform> {
  Future<List<double>?>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_Waveform old) {
    super.didUpdateWidget(old);
    if (old.media?.id != widget.media?.id) _load();
  }

  void _load() {
    final media = widget.media;
    if (media == null) {
      _future = Future.value(const <double>[]);
      return;
    }
    if (media.missing || media.fileMissing) {
      _future = Future.value(null);
      return;
    }
    _future = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(thumbnailServiceProvider).waveform(media);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<List<double>?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // EDT-04 : état « en préparation », sans scintillement.
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.audioPreparing,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GraceType.caption.copyWith(color: widget.color),
            ),
          );
        }
        if (snapshot.data == null) {
          // Échec de décodage : l'élément reste lisible et supprimable.
          return Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 12, color: widget.color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  l10n.audioUnreadable,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GraceType.caption.copyWith(color: widget.color),
                ),
              ),
            ],
          );
        }
        final values = snapshot.data!;
        if (values.isEmpty) {
          // Média sans piste audio : on garde la piste vide, sans dessiner de
          // fausse onde.
          return const SizedBox.shrink();
        }
        // `CustomPaint` sans enfant n'a pas de taille propre : sans
        // `SizedBox.expand`, l'onde était peinte dans un rectangle de
        // hauteur nulle (élément audio vide à l'écran).
        return SizedBox.expand(
          child: CustomPaint(
            painter: _WavePainter(
              values: values,
              color: widget.color,
              fadeIn: widget.fadeIn,
              fadeOut: widget.fadeOut,
            ),
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.values,
    required this.color,
    required this.fadeIn,
    required this.fadeOut,
  });

  final List<double> values;
  final Color color;
  final double fadeIn;
  final double fadeOut;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width <= 0 || size.height <= 0) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final bars = math.max(1, math.min(values.length, size.width ~/ 3));
    for (var i = 0; i < bars; i++) {
      final start = (i * values.length / bars).floor();
      final end = math.max(start + 1, ((i + 1) * values.length / bars).floor());
      var peak = 0.0;
      for (var j = start; j < end && j < values.length; j++) {
        peak = math.max(peak, values[j]);
      }
      final x = (i + 0.5) * size.width / bars;
      final amplitude = (0.08 + peak * 0.92) * size.height / 2;
      canvas.drawLine(
        Offset(x, size.height / 2 - amplitude),
        Offset(x, size.height / 2 + amplitude),
        paint,
      );
    }
    final ramp = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    if (fadeIn > 0) {
      canvas.drawLine(
        Offset(0, size.height),
        Offset(size.width * fadeIn.clamp(0, 1), 0),
        ramp,
      );
    }
    if (fadeOut > 0) {
      canvas.drawLine(
        Offset(size.width * (1 - fadeOut.clamp(0, 1)), 0),
        Offset(size.width, size.height),
        ramp,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.values != values ||
      old.fadeIn != fadeIn ||
      old.fadeOut != fadeOut ||
      old.color != color;
}
