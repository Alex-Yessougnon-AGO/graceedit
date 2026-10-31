import 'dart:async';
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

  /// Déplacement normalisé : fractions de la largeur et de la hauteur de
  /// l'aperçu (le texte suit exactement le doigt).
  final void Function(TextItem item, double fractionX, double fractionY)
  onMoveText;
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
                  // La clé ne dépend que du fichier : scinder ou rogner un clip
                  // ne doit pas recréer le lecteur (aperçu noir le temps de
                  // l'initialisation).
                  key: ValueKey(media.uri),
                  media: media,
                  clip: clip!,
                  project: project,
                  positionInClip: controller.localPositionInClip(clip),
                  clipStartMs: controller.clipStartMs(clip),
                  playing: controller.isPlaying,
                  onPosition: controller.syncToPreview,
                  compareOriginal: controller.compareOriginal,
                  volume:
                      (clip.volume / 100).clamp(0.0, 1.0) *
                      (project.videoVolume / 100).clamp(0.0, 1.0),
                  onFailed: media.isVideo
                      ? () => controller.markMediaMissing(media.id)
                      : null,
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
                              onDrag: (dx, dy) => onMoveText(
                                text,
                                size.width <= 0 ? 0 : dx / size.width,
                                size.height <= 0 ? 0 : dy / size.height,
                              ),
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
    required this.clipStartMs,
    required this.playing,
    required this.compareOriginal,
    required this.volume,
    required this.onPosition,
    this.onFailed,
  });

  final MediaRef media;
  final Clip clip;
  final Project project;
  final double positionInClip;

  /// Position du clip dans le projet : permet de traduire la position du
  /// lecteur (dans le média) en position globale de la timeline.
  final int clipStartMs;
  final bool playing;
  final bool compareOriginal;

  /// Volume effectif du clip (son du clip × son de la vidéo), de 0 à 1.
  final double volume;

  /// Position réelle annoncée par la vidéo pendant la lecture (en ms depuis
  /// le début du projet). L'horloge de l'éditeur s'aligne dessus.
  final ValueChanged<int> onPosition;

  /// Appelé quand la lecture native échoue (fichier illisible, accès perdu,
  /// codec non pris en charge) pour basculer vers l'état « média manquant ».
  final VoidCallback? onFailed;

  @override
  State<_MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<_MediaPreview> {
  VideoPlayerController? _video;
  bool _failed = false;
  bool _buffering = false;
  bool _showBuffering = false;
  Timer? _bufferTimer;
  double? _appliedVolume;
  double? _appliedSpeed;
  DateTime? _lastSeek;
  bool _seeking = false;
  bool _awaitingPlay = false;
  bool _syncQueued = false;

  /// Jeton de génération : une initialisation lente ne doit jamais écraser
  /// un lecteur plus récent quand l'utilisateur change vite de clip.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _init(_generation);
  }

  @override
  void didUpdateWidget(covariant _MediaPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.uri != widget.media.uri) {
      _generation++;
      _video?.removeListener(_onVideoEvent);
      _video?.dispose();
      _video = null;
      _failed = false;
      _buffering = false;
      _showBuffering = false;
      _bufferTimer?.cancel();
      _appliedVolume = null;
      _seeking = false;
      _init(_generation);
      return;
    }
    _sync();
  }

  Future<void> _init(int generation) async {
    if (!widget.media.isVideo) return;
    VideoPlayerController? controller;
    try {
      controller = widget.media.uri.startsWith('content://')
          ? VideoPlayerController.contentUri(Uri.parse(widget.media.uri))
          : VideoPlayerController.file(File(widget.media.uri));
      await controller.initialize();
      if (!mounted || generation != _generation) {
        await controller.dispose();
        return;
      }
      await controller.setVolume(widget.volume);
      _appliedVolume = widget.volume;
      await controller.seekTo(
        Duration(milliseconds: widget.positionInClip.round()),
      );
      if (!mounted || generation != _generation) {
        await controller.dispose();
        return;
      }
      controller.addListener(_onVideoEvent);
      _video = controller;
      setState(() {});
      _sync();
    } catch (_) {
      await controller?.dispose();
      if (!mounted || generation != _generation) return;
      setState(() => _failed = true);
      widget.onFailed?.call();
    }
  }

  /// Surveille la lecture native : une erreur ExoPlayer bascule vers l'état
  /// « média manquant » au lieu de geler sur une image statique.
  void _onVideoEvent() {
    final video = _video;
    if (video == null || !mounted) return;
    final value = video.value;
    if (value.hasError && !_failed) {
      setState(() => _failed = true);
      widget.onFailed?.call();
      return;
    }
    // Le loader n'apparaît qu'après 350 ms de chargement continu : les
    // micro-tampons d'un décodeur modeste ne doivent pas faire clignoter
    // l'aperçu pendant la lecture.
    if (value.isBuffering != _buffering) {
      _buffering = value.isBuffering;
      _bufferTimer?.cancel();
      if (_buffering) {
        _bufferTimer = Timer(const Duration(milliseconds: 350), () {
          if (mounted && _buffering) {
            setState(() => _showBuffering = true);
          }
        });
      } else if (_showBuffering) {
        setState(() => _showBuffering = false);
      }
    }
    // La vidéo est la référence de temps pendant la lecture : on annonce sa
    // position réelle pour que la timeline et le son ajouté la suivent, au
    // lieu de recaler la vidéo en boucle (cause des saccades). On annonce
    // aussi pendant un chargement : l'horloge reste alors sur l'image figée
    // au lieu d'avancer sans elle.
    if (widget.playing && value.isCompleted) {
      widget.onPosition(widget.clipStartMs + widget.clip.durationMs);
      return;
    }
    if (value.isPlaying) _awaitingPlay = false;
    if (widget.playing &&
        (value.isPlaying || value.isBuffering) &&
        value.duration > Duration.zero &&
        value.position < value.duration - const Duration(milliseconds: 200)) {
      // Le temps timeline avance à la vitesse du clip : on convertit la
      // position média annoncée par le lecteur.
      final speed = widget.clip.speed <= 0 ? 1.0 : widget.clip.speed;
      final globalMs =
          widget.clipStartMs +
          ((value.position.inMilliseconds - widget.clip.trimStartMs) / speed)
              .round();
      widget.onPosition(globalMs);
    }
  }

  void _seekTo(VideoPlayerController video, Duration target) {
    // Un seul recalage à la fois : sans ce garde, les battements à 20 Hz
    // empilaient des `seekTo` qui se marchaient dessus et saccadaient.
    if (_seeking) return;
    _seeking = true;
    _lastSeek = DateTime.now();
    video.seekTo(target).whenComplete(() {
      _seeking = false;
      // Le recalage demandé pendant le précédent est appliqué au prochain
      // battement via _sync().
    });
  }

  /// Les appels au lecteur (`play`, `seekTo`, `setVolume`) notifient leurs
  /// écouteurs en synchrone : les faire pendant la construction déclenchait
  /// « setState() called during build » via [EditorController.syncToPreview]
  /// et cassait l'image en cours. On les diffère donc après l'image.
  void _sync() {
    if (_syncQueued) return;
    _syncQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncQueued = false;
      if (mounted) _syncNow();
    });
  }

  void _syncNow() {
    final video = _video;
    if (video == null || !video.value.isInitialized || _failed) return;
    // Le volume doit suivre les curseurs en direct, sans attendre la fermeture
    // de la feuille (EDT-04).
    if (_appliedVolume != widget.volume) {
      _appliedVolume = widget.volume;
      video.setVolume(widget.volume);
    }
    // Vitesse du clip : appliquée dès qu'elle change, comme le volume.
    final speed = widget.clip.speed <= 0 ? 1.0 : widget.clip.speed;
    if (_appliedSpeed != speed) {
      _appliedSpeed = speed;
      video.setPlaybackSpeed(speed);
    }
    if (widget.playing) {
      // Pendant la lecture, on ne recale jamais la vidéo : c'est elle qui
      // donne le temps (voir _onVideoEvent et
      // [EditorController.syncToPreview]). Un seek ici relançait un
      // chargement à chaque seconde et noircissait l'aperçu.
      //
      // On ne relance pas non plus `play()` pendant un chargement : le
      // lecteur a déjà reçu l'ordre, le répéter ne fait que générer des
      // événements de tampon en boucle.
      final duration = video.value.duration;
      final atEnd =
          duration > Duration.zero &&
          video.value.position >= duration - const Duration(milliseconds: 120);
      if (!video.value.isPlaying &&
          !video.value.isBuffering &&
          !video.value.isCompleted &&
          !atEnd &&
          !_awaitingPlay) {
        _awaitingPlay = true;
        video.play();
      }
      return;
    }
    _awaitingPlay = false;
    if (video.value.isPlaying) video.pause();
    // En pause, l'image doit suivre la tête de lecture immédiatement :
    // c'est ce qui donne l'impression que « la timeline ne marche pas »
    // quand on fait glisser le doigt.
    final target = Duration(milliseconds: widget.positionInClip.round());
    final drift = (target - video.value.position).abs();
    final now = DateTime.now();
    if (drift > const Duration(milliseconds: 60)) {
      if (_lastSeek == null ||
          now.difference(_lastSeek!) > const Duration(milliseconds: 90)) {
        _seekTo(video, target);
      }
    }
  }

  @override
  void dispose() {
    _generation++;
    _bufferTimer?.cancel();
    _video?.removeListener(_onVideoEvent);
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
    // Sans ajustement, on saute le filtre matriciel : il coûte un passage
    // GPU à chaque image pour un résultat identique.
    Widget child = adjustments.isNeutral
        ? content
        : ColorFiltered(
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
    // « Remplir » recadre pour couvrir le cadre ; « Ajuster » montre l'image
    // entière avec des bandes (EDT-05). L'aperçu ignorait ce réglage.
    final fit = widget.project.fitMode == FitMode.fill
        ? BoxFit.cover
        : BoxFit.contain;
    return ColoredBox(
      color: GraceColors.preview,
      child: SizedBox.expand(
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(fit: fit, child: child),
              // En pause (scrub, rognage), l'image affichée reste la
              // référence : un loader par-dessus ferait clignoter l'aperçu
              // à chaque seek. Il ne sert que pendant la lecture.
              if (_showBuffering && widget.playing && !_failed)
                const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
            ],
          ),
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
