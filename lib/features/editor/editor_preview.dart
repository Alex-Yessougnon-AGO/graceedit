import 'dart:io';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/models/project.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/buttons.dart';
import '../../core/ui/thumb.dart';
import 'editor_controller.dart';

class EditorPreview extends StatelessWidget {
  const EditorPreview({
    super.key,
    required this.controller,
    required this.onEditText,
    required this.onMoveTextStart,
    required this.onMoveText,
    required this.onMoveTextEnd,
    required this.onReconnect,
  });

  final EditorController controller;
  final ValueChanged<TextItem> onEditText;
  final VoidCallback onMoveTextStart;
  final void Function(TextItem item, double dx, double dy) onMoveText;
  final VoidCallback onMoveTextEnd;
  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final project = controller.project;
    final clip = controller.clipAt(controller.positionMs);
    final media = controller.mediaFor(clip);
    final missing = media != null && (media.missing || media.fileMissing);
    final visibleTexts = project.texts
        .where(
          (t) =>
              controller.positionMs >= t.startMs &&
              controller.positionMs < t.endMs,
        )
        .toList();

    return Container(
      height: GraceDims.preview,
      color: GraceColors.preview,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (media == null)
            _EmptyPreview(
              title: l10n.editorEmptyTitle,
              body: l10n.editorEmptyBody,
            )
          else if (missing)
            _MissingPreview(onReconnect: onReconnect)
          else ...[
            Center(
              child: AspectRatio(
                aspectRatio: project.format.ratio,
                child: _MediaPreview(
                  key: ValueKey('${clip!.id}-${media.uri}'),
                  media: media,
                  clip: clip,
                  project: project,
                  positionInClip: controller.localPositionInClip(clip),
                  playing: controller.isPlaying,
                  compareOriginal: controller.compareOriginal,
                ),
              ),
            ),
            if (visibleTexts.isNotEmpty)
              Center(
                child: AspectRatio(
                  aspectRatio: project.format.ratio,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      return Stack(
                        clipBehavior: ui.Clip.none,
                        children: [
                          for (final text in visibleTexts)
                            _TextOverlay(
                              text: text,
                              preview: size,
                              selected:
                                  controller.selection == SelectionType.text &&
                                  controller.selectedId == text.id,
                              onDoubleTap: () => onEditText(text),
                              onDragStart: onMoveTextStart,
                              onDrag: (dx, dy) => onMoveText(text, dx, dy),
                              onDragEnd: onMoveTextEnd,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            if (controller.panel == EditorPanel.adjust &&
                controller.compareOriginal)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.2),
                  child: Center(
                    child: Text(
                      l10n.commonOriginal,
                      style: GraceType.small.copyWith(color: GraceColors.ivory),
                    ),
                  ),
                ),
              ),
          ],
          if (controller.panel == EditorPanel.adjust)
            Positioned(
              right: 8,
              top: 8,
              child: _CompareButton(
                controller: controller,
                label: l10n.commonCompare,
              ),
            ),
        ],
      ),
    );
  }
}

class _CompareButton extends StatelessWidget {
  const _CompareButton({required this.controller, required this.label});
  final EditorController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: () => controller.setCompareOriginal(!controller.compareOriginal),
        onLongPressStart: (_) => controller.setCompareOriginal(true),
        onLongPressEnd: (_) => controller.setCompareOriginal(false),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.compare, size: 16, color: GraceColors.ivory),
              const SizedBox(width: 6),
              Text(
                label,
                style: GraceType.small.copyWith(color: GraceColors.ivory),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaPreview extends StatefulWidget {
  const _MediaPreview({
    super.key,
    required this.media,
    required this.clip,
    required this.project,
    required this.positionInClip,
    required this.playing,
    required this.compareOriginal,
  });

  final MediaRef media;
  final Clip clip;
  final Project project;
  final double positionInClip;
  final bool playing;
  final bool compareOriginal;

  @override
  State<_MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<_MediaPreview> {
  VideoPlayerController? _video;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant _MediaPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.uri != widget.media.uri) {
      _video?.dispose();
      _video = null;
      _failed = false;
      _init();
      return;
    }
    _sync();
  }

  Future<void> _init() async {
    if (!widget.media.isVideo) return;
    try {
      final controller = widget.media.uri.startsWith('content://')
          ? VideoPlayerController.contentUri(Uri.parse(widget.media.uri))
          : VideoPlayerController.file(File(widget.media.uri));
      await controller.initialize();
      await controller.seekTo(
        Duration(milliseconds: widget.positionInClip.round()),
      );
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _video = controller;
      setState(() {});
      _sync();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _sync() {
    final video = _video;
    if (video == null || !video.value.isInitialized) return;
    if (widget.playing) {
      if (!video.value.isPlaying) video.play();
    } else {
      if (video.value.isPlaying) video.pause();
      final target = Duration(milliseconds: widget.positionInClip.round());
      final current = video.value.position;
      if ((target - current).abs() > const Duration(milliseconds: 350)) {
        video.seekTo(target);
      }
    }
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = _video;
    Widget content;
    if (video != null && video.value.isInitialized) {
      content = FittedBox(
        fit: BoxFit.cover,
        clipBehavior: ui.Clip.hardEdge,
        child: SizedBox(
          width: video.value.size.width,
          height: video.value.size.height,
          child: VideoPlayer(video),
        ),
      );
    } else if (widget.media.kind == MediaKind.image &&
        !widget.media.uri.startsWith('content://') &&
        File(widget.media.uri).existsSync()) {
      content = Image.file(File(widget.media.uri), fit: BoxFit.cover);
    } else if (_failed) {
      content = GraceThumb(
        media: widget.media,
        width: 1000,
        height: 1000,
        timeMs: widget.positionInClip.round(),
        showDuration: false,
        fit: BoxFit.cover,
      );
    } else {
      content = GraceThumb(
        media: widget.media,
        width: 1000,
        height: 1000,
        timeMs: widget.positionInClip.round(),
        showDuration: false,
        fit: BoxFit.cover,
      );
    }

    final adjustments = widget.compareOriginal
        ? const Adjustments()
        : widget.clip.adjustments;
    Widget child = ColorFiltered(
      colorFilter: _adjustmentFilter(adjustments),
      child: content,
    );
    if (widget.clip.rotation != 0) {
      child = RotatedBox(
        quarterTurns: (widget.clip.rotation / 90).round(),
        child: child,
      );
    }
    if (widget.clip.mirrored) {
      child = Transform.flip(flipX: true, child: child);
    }
    if (widget.clip.straighten != 0) {
      child = Transform.rotate(
        angle: widget.clip.straighten * 3.1415926535 / 180,
        child: child,
      );
    }
    return ColoredBox(
      color: GraceColors.preview,
      child: SizedBox.expand(
        child: ClipRect(
          child: FittedBox(fit: BoxFit.cover, child: child),
        ),
      ),
    );
  }

  ColorFilter _adjustmentFilter(Adjustments a) {
    final brightness = a.brightness / 100 * 40;
    final contrast = 1 + a.contrast / 100;
    final saturation = 1 + a.saturation / 100;
    final c = contrast;
    final t = 128 * (1 - c) + brightness;
    return ColorFilter.matrix([
      c * (0.213 * saturation + 0.787),
      c * (0.715 * saturation - 0.715),
      c * (0.072 * saturation - 0.072),
      0,
      t,
      c * (0.213 * saturation - 0.213),
      c * (0.715 * saturation + 0.285),
      c * (0.072 * saturation - 0.072),
      0,
      t,
      c * (0.213 * saturation - 0.213),
      c * (0.715 * saturation - 0.715),
      c * (0.072 * saturation + 0.928),
      0,
      t,
      0,
      0,
      0,
      1,
      0,
    ]);
  }
}

class _TextOverlay extends StatelessWidget {
  const _TextOverlay({
    required this.text,
    required this.preview,
    required this.selected,
    required this.onDoubleTap,
    required this.onDragStart,
    required this.onDrag,
    required this.onDragEnd,
  });

  final TextItem text;
  final Size preview;
  final bool selected;
  final VoidCallback onDoubleTap;
  final VoidCallback onDragStart;
  final void Function(double dx, double dy) onDrag;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    final style = GraceType.body.copyWith(
      fontSize: text.size,
      height: 1.2,
      fontWeight: text.preset == TextPreset.caption
          ? FontWeight.w600
          : FontWeight.w600,
      color: Color(text.color).withValues(alpha: text.opacity / 100),
    );
    Widget content = Container(
      constraints: BoxConstraints(maxWidth: preview.width * 0.9),
      padding: text.background
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
          : EdgeInsets.zero,
      decoration: text.background
          ? BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(10),
            )
          : null,
      child: Text(text.text, textAlign: text.align, style: style),
    );

    if (selected) {
      content = Stack(
        clipBehavior: ui.Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: GraceColors.ivory, width: 1.5),
            ),
            padding: const EdgeInsets.all(4),
            child: content,
          ),
          for (final alignment in const [
            Alignment.topLeft,
            Alignment.topRight,
            Alignment.bottomLeft,
            Alignment.bottomRight,
          ])
            Align(
              alignment: alignment,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: GraceColors.ivory,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
              ),
            ),
          Positioned(
            top: -26,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: GraceColors.ivory,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: const Icon(
                  Icons.rotate_right,
                  size: 14,
                  color: GraceColors.ink,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Positioned(
      left: text.x * preview.width,
      top: text.y * preview.height,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.rotate(
          angle: text.rotation * 3.1415926535 / 180,
          child: GestureDetector(
            onDoubleTap: onDoubleTap,
            onPanStart: (_) => onDragStart(),
            onPanUpdate: (details) =>
                onDrag(details.delta.dx, details.delta.dy),
            onPanEnd: (_) => onDragEnd(),
            child: content,
          ),
        ),
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.image_outlined, size: 36, color: Color(0xFFB9B5AD)),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GraceType.bodyMedium.copyWith(color: GraceColors.ivory),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GraceType.secondary.copyWith(color: const Color(0xFFB9B5AD)),
          ),
        ],
      ),
    );
  }
}

class _MissingPreview extends StatelessWidget {
  const _MissingPreview({required this.onReconnect});
  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 36,
            color: Color(0xFFF2B8B5),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.editorMissingMedia,
            style: GraceType.bodyMedium.copyWith(color: GraceColors.ivory),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.missingBody,
            textAlign: TextAlign.center,
            style: GraceType.caption.copyWith(color: const Color(0xFFB9B5AD)),
          ),
          const SizedBox(height: 12),
          GraceOutlineButton(
            label: l10n.editorReconnect,
            expanded: false,
            onPressed: onReconnect,
          ),
        ],
      ),
    );
  }
}
