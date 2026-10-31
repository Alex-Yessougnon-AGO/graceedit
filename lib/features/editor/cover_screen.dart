import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/models/project.dart';
import '../../core/state/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/buttons.dart';
import '../../core/ui/messages.dart';
import '../../core/ui/sheets.dart';
import '../../core/ui/thumb.dart';
import '../../core/utils/formatters.dart';

/// Résultat renvoyé à l'éditeur par `EDT-07`.
class CoverSelection {
  const CoverSelection({
    required this.source,
    required this.timeMs,
    this.path,
    this.zoom = 1,
    this.offsetX = 0,
    this.offsetY = 0,
  });

  final CoverSource source;
  final int timeMs;
  final String? path;
  final double zoom;
  final double offsetX;
  final double offsetY;
}

/// Écran 10 — choix de la couverture (`EDT-07`).
///
/// Écran plein, et non feuille : la fiche décrit une barre supérieure, un
/// aperçu de 260 dp et une bande de 8 vignettes. Le choix n'est appliqué qu'au
/// « Terminé », en une seule action annulable côté éditeur.
class CoverScreen extends ConsumerStatefulWidget {
  const CoverScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<CoverScreen> createState() => _CoverScreenState();
}

class _CoverScreenState extends ConsumerState<CoverScreen> {
  Project? _project;
  CoverSource _source = CoverSource.videoFrame;
  int _timeMs = 0;
  String? _galleryPath;
  int _galleryWidth = 0;
  int _galleryHeight = 0;

  double _zoom = 1;
  double _offsetX = 0;
  double _offsetY = 0;
  double _startZoom = 1;

  bool _dragging = false;
  bool _busy = false;
  bool _frameFailed = false;
  bool _galleryMissing = false;
  int _lastDragTime = -1;

  late Future<String?> _frameFuture;

  int get _duration => math.max(0, _project?.durationMs ?? 0);

  int get _stripCount {
    if (_duration <= 0) return 1;
    if (_duration < 8000) return (_duration ~/ 1000).clamp(1, 8);
    return 8;
  }

  List<int> get _stripTimes {
    final count = _stripCount;
    if (_duration <= 1 || count <= 1) return List<int>.filled(count, 0);
    return List<int>.generate(
      count,
      (i) => ((_duration - 1) * i / (count - 1)).round(),
    );
  }

  @override
  void initState() {
    super.initState();
    final project = ref.read(storeProvider).projectById(widget.projectId);
    _project = project;
    if (project == null) {
      _frameFuture = Future<String?>.value(null);
      return;
    }
    _source = project.coverSource == CoverSource.automatic
        ? CoverSource.videoFrame
        : project.coverSource;
    _timeMs = project.coverTimeMs.clamp(0, math.max(0, project.durationMs - 1));
    _galleryPath = project.coverPath;
    _zoom = project.coverZoom.clamp(1, 4);
    _offsetX = project.coverOffsetX;
    _offsetY = project.coverOffsetY;
    _frameFuture = _extract();
  }

  Future<String?> _extract() {
    final project = _project;
    final media = project?.firstVideo;
    if (project == null || media == null || media.missing) {
      return Future<String?>.value(null);
    }
    final dragging = _dragging;
    final time = dragging ? _nearestStripTime(_timeMs) : _timeMs;
    final future = ref
        .read(thumbnailServiceProvider)
        .frame(media, time, width: dragging ? 640 : 1280);
    future.then((path) {
      if (!mounted || dragging) return;
      setState(() => _frameFailed = path == null);
    });
    return future;
  }

  int _nearestStripTime(int timeMs) {
    final times = _stripTimes;
    var best = times.first;
    for (final time in times) {
      if ((time - timeMs).abs() < (best - timeMs).abs()) best = time;
    }
    return best;
  }

  void _seek(int timeMs, {bool duringDrag = false}) {
    final next = timeMs.clamp(0, math.max(0, _duration - 1)).toInt();
    if (next == _timeMs) return;
    setState(() {
      _timeMs = next;
      _frameFailed = false;
      if (duringDrag) {
        final nearest = _nearestStripTime(next);
        if (nearest != _lastDragTime) {
          _lastDragTime = nearest;
          _frameFuture = _extract();
        }
      } else {
        _frameFuture = _extract();
      }
    });
  }

  void _startDrag() {
    setState(() {
      _dragging = true;
      _lastDragTime = _nearestStripTime(_timeMs);
      _frameFailed = false;
      _frameFuture = _extract();
    });
  }

  void _endDrag() {
    setState(() {
      _dragging = false;
      _frameFailed = false;
      _frameFuture = _extract();
    });
  }

  void _step(int deltaMs) => _seek(_timeMs + deltaMs);

  void _stepImage(int direction) {
    final times = _stripTimes;
    if (times.length <= 1) return;
    var index = 0;
    for (var i = 0; i < times.length; i++) {
      if ((times[i] - _timeMs).abs() < (times[index] - _timeMs).abs()) {
        index = i;
      }
    }
    final next = (index + direction).clamp(0, times.length - 1);
    _seek(times[next]);
  }

  void _retryFrame() {
    setState(() {
      _frameFailed = false;
      _frameFuture = _extract();
    });
  }

  Future<void> _pickGallery() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _galleryMissing = false;
    });
    final l10n = AppLocalizations.of(context);
    final service = ref.read(mediaServiceProvider);
    final result = await service.pickImage();
    if (!mounted) return;
    if (result.media.isEmpty) {
      setState(() => _busy = false);
      if (result.failure != null) {
        GraceToast.show(context, l10n.coverPickFailed, isError: true);
      }
      return;
    }
    final picked = result.media.first;
    if (!picked.supported || !picked.isImage) {
      setState(() => _busy = false);
      await showGraceDialog<void>(
        context: context,
        builder: (dialogContext) => GraceDialog(
          icon: Icons.warning_amber_rounded,
          title: l10n.unsupportedTitle,
          body: l10n.unsupportedBody,
          actions: [
            GraceDialogAction(
              label: l10n.unsupportedChoose,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
      );
      return;
    }
    final path = await service.copyCoverImage(picked);
    if (!mounted) return;
    if (path == null) {
      setState(() => _busy = false);
      GraceToast.show(context, l10n.coverCopyFailed, isError: true);
      return;
    }
    setState(() {
      _busy = false;
      _source = CoverSource.gallery;
      _galleryPath = path;
      _galleryWidth = picked.width;
      _galleryHeight = picked.height;
      _galleryMissing = false;
      _zoom = 1;
      _offsetX = 0;
      _offsetY = 0;
    });
  }

  void _useVideo() {
    setState(() {
      _source = CoverSource.videoFrame;
      _frameFailed = false;
      _frameFuture = _extract();
    });
  }

  void _resetAutomatic() {
    context.pop(const CoverSelection(source: CoverSource.automatic, timeMs: 0));
  }

  void _done() {
    final project = _project;
    if (project == null) return;
    if (_source == CoverSource.videoFrame && _frameFailed) return;
    if (_source == CoverSource.gallery) {
      final path = _galleryPath;
      if (path == null || !File(path).existsSync()) {
        setState(() => _galleryMissing = true);
        return;
      }
    }
    final gallery = _source == CoverSource.gallery;
    context.pop(
      CoverSelection(
        source: _source,
        timeMs: _source == CoverSource.videoFrame
            ? _timeMs
            : project.coverTimeMs,
        path: gallery ? _galleryPath : null,
        zoom: gallery ? _zoom : 1,
        offsetX: gallery ? _offsetX : 0,
        offsetY: gallery ? _offsetY : 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    final project = _project;
    if (project == null) {
      return Scaffold(
        backgroundColor: p.background,
        body: SafeArea(
          child: Column(
            children: [
              _topBar(l10n),
              Expanded(
                child: Center(
                  child: Text(
                    l10n.coverExtractFailed,
                    style: GraceType.body.copyWith(color: p.secondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final gallery = _source == CoverSource.gallery;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(l10n),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _preview(l10n),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _segments(l10n),
                        const SizedBox(height: 20),
                        if (gallery) ...[
                          _gallerySummary(l10n),
                          const SizedBox(height: 16),
                          GraceOutlineButton(
                            label: l10n.coverChooseAnother,
                            icon: Icons.image_outlined,
                            onPressed: _busy ? null : _pickGallery,
                          ),
                          Center(
                            child: GraceTextAction(
                              label: l10n.coverUseVideoImage,
                              onPressed: _useVideo,
                            ),
                          ),
                          const SizedBox(height: 34),
                        ] else ...[
                          _strip(l10n),
                          const SizedBox(height: 14),
                          _timePill(),
                          const SizedBox(height: 22),
                          Text(
                            l10n.coverSlideHint,
                            style: GraceType.body.copyWith(color: p.secondary),
                          ),
                          const SizedBox(height: 16),
                        ],
                        _sectionTitle(l10n),
                        const SizedBox(height: 12),
                        _projectRow(l10n),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(AppLocalizations l10n) {
    final p = context.grace;
    return SizedBox(
      height: GraceDims.topBar,
      child: Row(
        children: [
          const SizedBox(width: 4),
          GraceIconAction(
            icon: Icons.close,
            semanticLabel: l10n.semanticsClose,
            onPressed: () => context.pop(),
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.coverTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GraceType.barTitle,
            ),
          ),
          SizedBox(
            width: GraceDims.touch,
            height: GraceDims.touch,
            child: PopupMenuButton<String>(
              tooltip: l10n.semanticsMore,
              padding: EdgeInsets.zero,
              iconSize: 22,
              icon: Icon(Icons.more_horiz, color: p.text),
              onSelected: (_) => _resetAutomatic(),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'automatic',
                  child: Text(
                    l10n.coverResetAutomatic,
                    style: GraceType.bodyCompact,
                  ),
                ),
              ],
            ),
          ),
          GracePillAction(
            label: l10n.actionDone,
            height: 40,
            onPressed: _source == CoverSource.videoFrame && _frameFailed
                ? null
                : _done,
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _preview(AppLocalizations l10n) {
    final project = _project!;
    final gallery = _source == CoverSource.gallery;
    return SizedBox(
      height: GraceDims.preview,
      width: double.infinity,
      child: ColoredBox(
        color: GraceColors.preview,
        child: Center(
          child: AspectRatio(
            aspectRatio: project.format.ratio,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                return Semantics(
                  image: true,
                  label: l10n.coverPreviewSemantics(formatDuration(_timeMs)),
                  excludeSemantics: true,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (gallery)
                        _galleryImage(l10n, width, height)
                      else
                        _videoImage(l10n, width, height),
                      for (final text in _visibleTexts())
                        _textOverlay(text, width, height),
                      if (gallery) _cropHint(l10n),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _videoImage(AppLocalizations l10n, double width, double height) {
    return FutureBuilder<String?>(
      future: _frameFuture,
      builder: (context, snapshot) {
        final path = snapshot.data;
        if (path == null) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ColoredBox(color: context.grace.surface);
          }
          return _previewError(l10n, onRetry: _retryFrame);
        }
        return Image.file(
          File(path),
          width: width,
          height: height,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, _, _) =>
              _previewError(l10n, onRetry: _retryFrame),
        );
      },
    );
  }

  Widget _galleryImage(AppLocalizations l10n, double width, double height) {
    final path = _galleryPath;
    if (path == null || _galleryMissing) {
      return _previewError(l10n, onRetry: _pickGallery);
    }
    return GestureDetector(
      onScaleStart: (_) {
        _startZoom = _zoom;
      },
      onScaleUpdate: (details) {
        final zoom = (_startZoom * details.scale).clamp(1.0, 4.0);
        final maxOffset = (zoom - 1) / 2;
        setState(() {
          _zoom = zoom;
          if (zoom == 1) {
            _offsetX = 0;
            _offsetY = 0;
          } else {
            _offsetX = (_offsetX + details.focalPointDelta.dx / width).clamp(
              -maxOffset,
              maxOffset,
            );
            _offsetY = (_offsetY + details.focalPointDelta.dy / height).clamp(
              -maxOffset,
              maxOffset,
            );
          }
        });
      },
      child: ClipRect(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translateByDouble(_offsetX * width, _offsetY * height, 0, 1)
            ..scaleByDouble(_zoom, _zoom, 1, 1),
          child: Image.file(
            File(path),
            width: width,
            height: height,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (context, _, _) =>
                _previewError(l10n, onRetry: _pickGallery),
          ),
        ),
      ),
    );
  }

  Widget _previewError(AppLocalizations l10n, {required VoidCallback onRetry}) {
    return ColoredBox(
      color: GraceColors.preview,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.coverExtractFailed,
                textAlign: TextAlign.center,
                style: GraceType.bodyCompact.copyWith(color: GraceColors.ivory),
              ),
              const SizedBox(height: 4),
              GraceTextAction(
                label: l10n.actionRetry,
                color: GraceColors.ivory,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cropHint(AppLocalizations l10n) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 12,
      child: IgnorePointer(
        child: Center(
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              l10n.coverCropHintShort,
              style: GraceType.caption.copyWith(color: GraceColors.ivory),
            ),
          ),
        ),
      ),
    );
  }

  List<TextItem> _visibleTexts() {
    final project = _project;
    if (project == null) return const [];
    return [
      for (final text in project.texts)
        if (text.text.trim().isNotEmpty &&
            _timeMs >= text.startMs &&
            _timeMs < text.endMs)
          text,
    ];
  }

  Widget _textOverlay(TextItem text, double width, double height) {
    final style = GraceType.body.copyWith(
      fontSize: text.size,
      height: 1.2,
      fontWeight: FontWeight.w600,
      color: Color(text.color).withValues(alpha: text.opacity / 100),
    );
    return Positioned(
      left: text.x * width,
      top: text.y * height,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.rotate(
          angle: text.rotation * math.pi / 180,
          child: Container(
            constraints: BoxConstraints(maxWidth: width * 0.9),
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
          ),
        ),
      ),
    );
  }

  Widget _segments(AppLocalizations l10n) {
    final gallery = _source == CoverSource.gallery;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: GraceDims.touch),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 4,
            bottom: 4,
            child: ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.grace.surface,
                  borderRadius: BorderRadius.circular(GraceRadius.chip),
                ),
              ),
            ),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _segment(
                    label: l10n.coverFromVideo,
                    selected: !gallery,
                    padding: const EdgeInsets.fromLTRB(3, 4, 1.5, 4),
                    onTap: _useVideo,
                  ),
                ),
                Expanded(
                  child: _segment(
                    label: l10n.coverFromGallery,
                    selected: gallery,
                    padding: const EdgeInsets.fromLTRB(1.5, 4, 3, 4),
                    onTap: _busy ? null : _pickGallery,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _segment({
    required String label,
    required bool selected,
    required EdgeInsets padding,
    required VoidCallback? onTap,
  }) {
    final p = context.grace;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GraceRadius.chip),
        ),
        child: Padding(
          padding: padding,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected ? p.button : Colors.transparent,
              borderRadius: BorderRadius.circular(GraceRadius.chip),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selected) ...[
                      Icon(Icons.check, size: 16, color: p.onButton),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: GraceType.secondaryMedium.copyWith(
                          color: selected ? p.onButton : p.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _strip(AppLocalizations l10n) {
    final project = _project!;
    final media = project.firstVideo;
    final times = _stripTimes;
    final itemWidth = 312 / times.length;
    final fraction = _duration <= 0
        ? 0.0
        : (_timeMs / _duration).clamp(0.0, 1.0);
    final frameLeft = (fraction * 312 - 24).clamp(0.0, 264.0);
    return Center(
      child: SizedBox(
        width: 312,
        height: 68,
        child: Stack(
          clipBehavior: ui.Clip.none,
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(GraceRadius.thumb),
                child: Row(
                  children: [
                    for (final time in times)
                      Expanded(
                        child: GraceThumb(
                          media: media,
                          width: itemWidth,
                          height: 68,
                          radius: 0,
                          timeMs: time,
                          showDuration: false,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: frameLeft,
              top: -6,
              child: _frame(l10n, frameLeft),
            ),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                onTapUp: (details) =>
                    _seek((details.localPosition.dx / 312 * _duration).round()),
                onHorizontalDragStart: (_) => _startDrag(),
                onHorizontalDragUpdate: (details) => _seek(
                  (details.localPosition.dx / 312 * _duration).round(),
                  duringDrag: true,
                ),
                onHorizontalDragEnd: (_) => _endDrag(),
                onHorizontalDragCancel: _endDrag,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _frame(AppLocalizations l10n, double frameLeft) {
    final p = context.grace;
    final time = formatDuration(_timeMs);
    return Semantics(
      container: true,
      slider: true,
      label: l10n.coverFrameSemantics(time),
      value: time,
      increasedValue: formatDuration(
        (_timeMs + 1000).clamp(0, math.max(0, _duration - 1)),
      ),
      decreasedValue: formatDuration((_timeMs - 1000).clamp(0, _duration)),
      onIncrease: () => _step(1000),
      onDecrease: () => _step(-1000),
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.coverNextImage): () => _stepImage(1),
        CustomSemanticsAction(label: l10n.coverPrevImage): () => _stepImage(-1),
      },
      child: IgnorePointer(
        child: Container(
          width: 48,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: p.accent, width: 3.5),
            borderRadius: BorderRadius.circular(GraceRadius.thumb),
          ),
        ),
      ),
    );
  }

  Widget _timePill() {
    final p = context.grace;
    final label = formatDuration(_timeMs);
    final style = GraceType.timecodeSmall.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: p.background,
    );
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final width = painter.width + 16;
    painter.dispose();
    final fraction = _duration <= 0
        ? 0.0
        : (_timeMs / _duration).clamp(0.0, 1.0);
    final frameCenter = (fraction * 312 - 24).clamp(0.0, 264.0) + 24;
    final left = (frameCenter - width / 2).clamp(0.0, 312 - width);
    return Center(
      child: SizedBox(
        width: 312,
        height: 22,
        child: Stack(
          children: [
            Positioned(
              left: left,
              child: ExcludeSemantics(
                child: Container(
                  height: 22,
                  width: width,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.text,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(label, style: style),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gallerySummary(AppLocalizations l10n) {
    final p = context.grace;
    final draft = _draftProject();
    final dimensions = _galleryWidth > 0 && _galleryHeight > 0
        ? formatPixels(_galleryWidth, _galleryHeight)
        : null;
    return Row(
      children: [
        ProjectCover(
          project: draft,
          width: GraceDims.thumbListW,
          height: GraceDims.thumbListH,
          showDuration: false,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.coverGalleryImage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GraceType.barTitle,
              ),
              if (dimensions != null) ...[
                const SizedBox(height: 2),
                Text(
                  dimensions,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GraceType.body.copyWith(color: p.secondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(AppLocalizations l10n) {
    return Semantics(
      header: true,
      child: Text(l10n.coverImageInProjects, style: GraceType.barTitle),
    );
  }

  Widget _projectRow(AppLocalizations l10n) {
    final p = context.grace;
    final project = _project!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ProjectCover(
          project: _draftProject(),
          width: GraceDims.thumbListW,
          height: GraceDims.thumbListH,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title.isEmpty ? l10n.editorUntitled : project.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GraceType.barTitle,
              ),
              const SizedBox(height: 2),
              Text(
                l10n.coverModifiedNow,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GraceType.body.copyWith(color: p.secondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Project _draftProject() {
    final gallery = _source == CoverSource.gallery;
    return _project!.copyWith(
      coverSource: _source,
      coverTimeMs: _timeMs,
      coverPath: _galleryPath,
      coverZoom: gallery ? _zoom : 1,
      coverOffsetX: gallery ? _offsetX : 0,
      coverOffsetY: gallery ? _offsetY : 0,
    );
  }
}
