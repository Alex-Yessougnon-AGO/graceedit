import 'dart:math' as math;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/models/project.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/thumb.dart';
import '../../core/utils/formatters.dart';
import 'editor_controller.dart';

class EditorTimeline extends StatelessWidget {
  const EditorTimeline({
    super.key,
    required this.controller,
    required this.onAddMedia,
  });

  final EditorController controller;
  final VoidCallback onAddMedia;

  double get _pxPerSec => 1.2 * controller.zoom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final project = controller.project;
    final durations = _durations(project);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final origin = width / 2 - controller.positionMs / 1000 * _pxPerSec;
        final hasTexts = project.texts.isNotEmpty;
        final hasAudio = project.audios.isNotEmpty;
        var top = GraceDims.ruler + 4;
        final videoTop = top;
        top += GraceDims.videoTrack + 8;
        final textTop = top;
        if (hasTexts) top += GraceDims.subTrack + 8;
        final audioTop = top;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.clearSelection,
          onScaleStart: (_) => controller.beginGesture(),
          onScaleUpdate: (details) {
            if (details.pointerCount > 1 && details.scale != 1) {
              controller.setZoom(controller.zoom * details.scale);
            } else if (details.focalPointDelta.dx.abs() > 0.1) {
              controller.scrubBy(
                (-details.focalPointDelta.dx / _pxPerSec * 1000).round(),
              );
            }
          },
          onScaleEnd: (_) => controller.endGesture(),
          child: SizedBox(
            height: height,
            width: width,
            child: Stack(
              clipBehavior: ui.Clip.hardEdge,
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
                        if (project.clips.isEmpty)
                          Positioned.fill(
                            child: _EmptyTrack(onAdd: onAddMedia, l10n: l10n),
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
                        ],
                      ),
                    ),
                  ),
                // Tête de lecture fixe.
                Positioned(
                  left: width / 2 - GraceDims.playheadLine / 2,
                  top: 0,
                  bottom: 0,
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
    final left = origin + clipStart / 1000 * _pxPerSec;
    final selected =
        controller.selection == SelectionType.clip &&
        controller.selectedId == clip.id;
    final media = project.mediaById(clip.mediaId);
    final missing = media != null && (media.missing || media.fileMissing);
    return Positioned(
      left: left,
      top: 0,
      width: math.max(px, 16),
      height: GraceDims.videoTrack,
      child: GestureDetector(
        onTap: () => controller.selectClip(clip.id),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GraceRadius.thumb),
            border: Border.all(
              color: selected ? context.grace.text : Colors.transparent,
              width: 3,
            ),
          ),
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
                  _ClipFrames(
                    media: media,
                    clip: clip,
                    width: math.max(px, 16),
                  ),
                Positioned(
                  left: 4,
                  top: 4,
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
                if (selected) ...[
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 14,
                    child: _TrimHandle(
                      onStart: controller.beginGesture,
                      onEnd: controller.endGesture,
                      onDrag: (delta) => controller.trimClip(
                        clip.id,
                        start:
                            clip.trimStartMs +
                            (delta / _pxPerSec * 1000).round(),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 14,
                    child: _TrimHandle(
                      onStart: controller.beginGesture,
                      onEnd: controller.endGesture,
                      onDrag: (delta) => controller.trimClip(
                        clip.id,
                        end:
                            clip.trimEndMs + (delta / _pxPerSec * 1000).round(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _positionedText(BuildContext context, TextItem text, double origin) {
    final px = text.durationMs / 1000 * _pxPerSec;
    final left = origin + text.startMs / 1000 * _pxPerSec;
    final selected =
        controller.selection == SelectionType.text &&
        controller.selectedId == text.id;
    return Positioned(
      left: left,
      top: 0,
      width: math.max(px, 24),
      height: GraceDims.subTrack,
      child: GestureDetector(
        onTap: () => controller.selectText(text.id),
        child: Container(
          decoration: BoxDecoration(
            color: context.grace.active,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected ? context.grace.text : Colors.transparent,
              width: 3,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(Icons.title, size: 14, color: context.grace.text),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  text.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GraceType.caption,
                ),
              ),
              Text(
                formatDuration(text.durationMs),
                style: GraceType.caption.copyWith(
                  color: context.grace.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    return Positioned(
      left: left,
      top: 0,
      width: math.max(px, 24),
      height: GraceDims.subTrack,
      child: GestureDetector(
        onTap: () => controller.selectAudio(audio.id),
        child: Container(
          decoration: BoxDecoration(
            color: context.grace.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected ? context.grace.text : Colors.transparent,
              width: 3,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Icon(Icons.music_note, size: 14, color: context.grace.text),
              const SizedBox(width: 6),
              Expanded(
                child: CustomPaint(
                  painter: _WavePainter(
                    color: context.grace.secondary,
                    fadeIn: audio.fadeInMs / audio.durationMs,
                    fadeOut: audio.fadeOutMs / audio.durationMs,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(media?.name ?? '', maxLines: 1, style: GraceType.caption),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
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
    final count = math.max(1, math.min(5, (width / 56).ceil()));
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

class _TrimHandle extends StatefulWidget {
  const _TrimHandle({
    required this.onStart,
    required this.onDrag,
    required this.onEnd,
  });

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
    return GestureDetector(
      onHorizontalDragStart: (_) => widget.onStart(),
      onHorizontalDragUpdate: (details) => widget.onDrag(details.delta.dx),
      onHorizontalDragEnd: (_) => widget.onEnd(),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        child: Container(
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
    final step = pxPerSec >= 6
        ? 1
        : pxPerSec >= 3
        ? 2
        : pxPerSec >= 1
        ? 5
        : 10;
    final first = math.max(0, ((-origin) / pxPerSec / step).floor() * step);
    final last = ((width - origin) / pxPerSec).ceil();
    final tickPaint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var second = first; second <= last; second += 1) {
      final x = origin + second * pxPerSec;
      final isMajor = second % step == 0;
      canvas.drawLine(
        Offset(x, isMajor ? 8 : 14),
        Offset(x, isMajor ? 20 : 18),
        tickPaint,
      );
      if (isMajor) {
        final label = formatDuration(second * 1000);
        final painter = TextPainter(
          text: TextSpan(
            text: label,
            style: GraceType.timecodeSmall.copyWith(color: color),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(canvas, Offset(x - painter.width / 2, 0));
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

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.color,
    required this.fadeIn,
    required this.fadeOut,
  });

  final Color color;
  final double fadeIn;
  final double fadeOut;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    const bars = 60;
    final random = math.Random(7);
    for (var i = 0; i < bars; i++) {
      final x = i * size.width / bars;
      final amplitude = (0.25 + random.nextDouble() * 0.6) * size.height / 2;
      canvas.drawLine(
        Offset(x, size.height / 2 - amplitude),
        Offset(x, size.height / 2 + amplitude),
        paint,
      );
    }
    final ramp = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width * fadeIn.clamp(0, 1), 0),
      ramp,
    );
    canvas.drawLine(
      Offset(size.width * (1 - fadeOut.clamp(0, 1)), 0),
      Offset(size.width, size.height),
      ramp,
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.fadeIn != fadeIn || old.fadeOut != fadeOut || old.color != color;
}
