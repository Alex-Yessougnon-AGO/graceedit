import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/models/project.dart';
import '../../core/state/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/buttons.dart';
import '../../core/ui/back_scope.dart';
import '../../core/ui/controls.dart';
import '../../core/ui/messages.dart';
import '../../core/ui/sheets.dart';
import '../../core/ui/thumb.dart';
import '../../core/utils/formatters.dart';
import '../import/import_flow.dart';
import 'cover_screen.dart';
import 'editor_controller.dart';
import 'editor_preview.dart';
import 'preview_audio.dart';
import 'timeline.dart';

const _uuid = Uuid();

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, required this.projectId});
  final String projectId;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen>
    with WidgetsBindingObserver {
  EditorController? _controller;
  final PreviewAudioEngine _audio = PreviewAudioEngine();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final store = ref.read(storeProvider);
    final project = store.projectById(widget.projectId);
    if (project != null) {
      _controller = EditorController(store: store, project: project);
      _controller!.addListener(_syncAudio);
      _syncAudio();
    }
  }

  /// Mise en arrière-plan : la lecture s'arrête (vidéo, horloge et son
  /// ajouté via _syncAudio), sinon elle continuerait en fantôme.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _controller?.pause();
    }
  }

  /// Tient le son ajouté aligné sur l'horloge de l'éditeur.
  void _syncAudio() {
    final controller = _controller;
    if (controller == null) return;
    unawaited(
      _audio.sync(
        controller.project,
        controller.positionMs,
        controller.isPlaying,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_syncAudio);
      // Sortie volontaire : sauvegarde puis session marquée propre, sinon
      // l'accueil proposerait une « récupération » à chaque retour.
      unawaited(controller.close());
      controller.dispose();
    }
    unawaited(_audio.dispose());
    super.dispose();
  }

  EditorController get controller => _controller!;

  /// Retour : dépile quand c'est possible, sinon revient à l'accueil.
  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context);
    return GraceBackScope(
      fallback: '/home',
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          // Sauvegarde réparée après un échec (SYS-02) : on l'annonce une
          // seule fois puis on revient à l'état nominal.
          if (controller.saveState == SaveState.recovered) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              GraceToast.show(context, l10n.projectSaved);
              controller.consumeRecovered();
            });
          }
          final project = controller.project;
          final landscape =
              MediaQuery.sizeOf(context).width >
              MediaQuery.sizeOf(context).height;
          final wide = MediaQuery.sizeOf(context).width >= 600;
          return Scaffold(
            backgroundColor: context.grace.background,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _EditorTopBar(
                    controller: controller,
                    l10n: l10n,
                    onBack: _leave,
                  ),
                  if (controller.saveState == SaveState.failed)
                    _SaveFailedBanner(
                      onRetry: controller.retrySave,
                      onFreeSpace: () => context.push('/settings/storage'),
                    ),
                  Expanded(
                    child: landscape || wide
                        ? _LandscapeBody(
                            controller: controller,
                            onEditText: _editText,
                            onAddMedia: _addMedia,
                            onReconnect: () =>
                                context.push('/projects/${project.id}/relink'),
                          )
                        : _PortraitBody(
                            controller: controller,
                            onEditText: _editText,
                            onAddMedia: _addMedia,
                            onReconnect: () =>
                                context.push('/projects/${project.id}/relink'),
                          ),
                  ),
                  _EditorToolbar(
                    controller: controller,
                    onAdd: _addMedia,
                    onAudio: _showAudioMix,
                    onAudioVolume: () => _showAudioDetail(),
                    onAudioFade: () => _showAudioDetail(focusFades: true),
                    onAudioSplit: _splitAudio,
                    onText: _addText,
                    onAdjust: _showAdjust,
                    onFormat: _showFormat,
                    onCover: _showCover,
                    onSplit: _split,
                    onVolume: _showVolume,
                    onCrop: _showCrop,
                    onDelete: _deleteSelected,
                    onMore: _showMore,
                    onBack: controller.clearSelection,
                    onEditText: () {
                      final item = controller.selectedText;
                      if (item != null) _editText(item);
                    },
                    onStyle: () => _showStyle(tab: 0),
                    onColor: () => _showStyle(tab: 2),
                    onTextMore: _showTextMore,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------- actions

  Future<void> _addMedia() async {
    final result = await ref.read(mediaServiceProvider).pickVideos();
    if (!mounted) return;
    if (result.failure != null) {
      GraceToast.show(
        context,
        AppLocalizations.of(context).pickerUnavailable,
        isError: true,
      );
      return;
    }
    if (result.media.isEmpty) return;
    final refs = result.media.map(mediaRefFromPicked).toList();
    final usable = refs
        .where((m) => !m.unsupported && m.kind == MediaKind.video)
        .toList();
    if (usable.isEmpty) return;
    final project = controller.project;
    // Les nouveaux clips sont ajoutés à la fin : leur début est la durée
    // actuelle du projet. On y place la tête de lecture pour que la timeline
    // défile jusqu'au clip ajouté au lieu de le laisser hors écran.
    final insertAt = project.durationMs;
    controller.replaceProject(
      project.copyWith(
        media: [...project.media, ...refs],
        clips: [
          ...project.clips,
          for (final media in usable)
            Clip(
              id: _uuid.v4(),
              mediaId: media.id,
              trimStartMs: 0,
              trimEndMs: media.durationMs > 0 ? media.durationMs : 3000,
            ),
        ],
      ),
    );
    // La timeline s'agrandit à l'ajout pour que le nouveau clip reste
    // manipulable (au moins 64 dp), même si la vidéo est courte.
    var shortest = 0;
    for (final media in usable) {
      final duration = media.durationMs > 0 ? media.durationMs : 3000;
      if (shortest == 0 || duration < shortest) shortest = duration;
    }
    controller.ensureElementWidth(shortest);
    controller.seek(insertAt);
  }

  void _addText() {
    final item = controller.addText();
    _editText(item, isNew: true);
  }

  Future<void> _editText(TextItem item, {bool isNew = false}) async {
    final l10n = AppLocalizations.of(context);
    final textController = TextEditingController(text: item.text);
    FocusNode? focus;
    var preset = item.preset;
    var value = item;
    final saved = await showGraceSheet<bool>(
      context: context,
      editorPanel: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          focus ??= FocusNode();
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isNew ? l10n.textAddTitle : l10n.textEditTitle,
                  style: GraceType.sheetTitle,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  focusNode: focus,
                  autofocus: true,
                  maxLines: 3,
                  maxLength: 120,
                  style: GraceType.body,
                  decoration: InputDecoration(
                    labelText: l10n.textInputLabel,
                    hintText: l10n.textPlaceholder,
                    counterText: '',
                  ),
                  onChanged: (v) =>
                      setSheetState(() => value = value.copyWith(text: v)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final p in TextPreset.values)
                      ChoiceChip(
                        label: Text(switch (p) {
                          TextPreset.title => l10n.textPresetTitle,
                          TextPreset.subtitle => l10n.textPresetSubtitle,
                          TextPreset.caption => l10n.textPresetCaption,
                        }),
                        selected: preset == p,
                        onSelected: (_) => setSheetState(() {
                          preset = p;
                          value = value.copyWith(preset: p);
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    GraceIconAction(
                      icon: Icons.close,
                      semanticLabel: l10n.actionClose,
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                    ),
                    const Spacer(),
                    if (!isNew)
                      GraceIconAction(
                        icon: Icons.delete_outline,
                        semanticLabel: l10n.actionDelete,
                        onPressed: () {
                          controller.removeText(item.id);
                          Navigator.of(sheetContext).pop(false);
                        },
                      ),
                    GracePrimaryButton(
                      label: l10n.commonDone,
                      expanded: false,
                      height: 48,
                      onPressed: textController.text.trim().isEmpty
                          ? null
                          : () => Navigator.of(sheetContext).pop(true),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    if (saved != true) {
      if (isNew) controller.removeText(item.id);
      return;
    }
    value = value.copyWith(text: textController.text.trim(), preset: preset);
    controller.updateText(value);
    textController.dispose();
    focus?.dispose();
  }

  Future<void> _showStyle({int tab = 0}) async {
    final l10n = AppLocalizations.of(context);
    final item = controller.selectedText;
    if (item == null) return;
    var value = item;
    await showGraceSheet<void>(
      context: context,
      editorPanel: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final p = context.grace;
          Widget content;
          if (tab == 0) {
            content = Column(
              children: [
                GraceSliderRow(
                  label: l10n.textSize,
                  value: value.size,
                  min: 12,
                  max: 72,
                  divisions: 60,
                  display: '${value.size.round()}',
                  onChanged: (v) {
                    value = value.copyWith(size: v);
                    controller.updateText(value);
                    setSheetState(() {});
                  },
                ),
                GraceSliderRow(
                  label: l10n.textOpacity,
                  value: value.opacity,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  display: formatPercent(value.opacity),
                  onChanged: (v) {
                    value = value.copyWith(opacity: v);
                    controller.updateText(value);
                    setSheetState(() {});
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.textBackgroundOn, style: GraceType.body),
                  value: value.background,
                  onChanged: (v) {
                    value = value.copyWith(background: v);
                    controller.updateText(value);
                    setSheetState(() {});
                  },
                ),
              ],
            );
          } else if (tab == 1) {
            content = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in TextPreset.values)
                  ChoiceChip(
                    label: Text(switch (preset) {
                      TextPreset.title => l10n.textPresetTitle,
                      TextPreset.subtitle => l10n.textPresetSubtitle,
                      TextPreset.caption => l10n.textPresetCaption,
                    }),
                    selected: value.preset == preset,
                    onSelected: (_) {
                      value = value.copyWith(preset: preset);
                      controller.updateText(value);
                      setSheetState(() {});
                    },
                  ),
                for (final align in TextAlign.values)
                  ChoiceChip(
                    label: Text(switch (align) {
                      TextAlign.left => l10n.textPresetAlignLeft,
                      TextAlign.right => l10n.textPresetAlignRight,
                      _ => l10n.textPresetAlignCenter,
                    }),
                    selected: value.align == align,
                    onSelected: (_) {
                      value = value.copyWith(align: align);
                      controller.updateText(value);
                      setSheetState(() {});
                    },
                  ),
              ],
            );
          } else if (tab == 2) {
            const colors = [
              (0xFFF6F2EA, 'textColorCream'),
              (0xFF14151A, 'textColorInk'),
              (0xFFE2542B, 'textColorOrange'),
              (0xFFE5B84B, 'textColorHoney'),
              (0xFF2F6B4F, 'textColorForest'),
              (0xFF2C5D8A, 'textColorOcean'),
            ];
            content = Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final entry in colors)
                  ColorDot(
                    color: Color(entry.$1),
                    selected: value.color == entry.$1,
                    semanticLabel: switch (entry.$2) {
                      'textColorCream' => l10n.textColorCream,
                      'textColorInk' => l10n.textColorInk,
                      'textColorOrange' => l10n.textColorOrange,
                      'textColorHoney' => l10n.textColorHoney,
                      'textColorForest' => l10n.textColorForest,
                      _ => l10n.textColorOcean,
                    },
                    onTap: () {
                      value = value.copyWith(color: entry.$1);
                      controller.updateText(value);
                      setSheetState(() {});
                    },
                  ),
              ],
            );
          } else {
            content = Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.textBackgroundOn, style: GraceType.body),
                  value: value.background,
                  onChanged: (v) {
                    value = value.copyWith(background: v);
                    controller.updateText(value);
                    setSheetState(() {});
                  },
                ),
              ],
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.textStyleTitle, style: GraceType.sheetTitle),
                const SizedBox(height: 16),
                GraceSegmented(
                  segments: [
                    GraceSegment(label: l10n.textTabStyle),
                    GraceSegment(label: l10n.textTabFont),
                    GraceSegment(label: l10n.textTabColor),
                    GraceSegment(label: l10n.textTabBackground),
                  ],
                  selected: tab,
                  onSelected: (i) => setSheetState(() => tab = i),
                ),
                const SizedBox(height: 20),
                content,
                const SizedBox(height: 8),
                Text(
                  l10n.textMoveHint,
                  style: GraceType.caption.copyWith(color: p.secondary),
                ),
              ],
            ),
          );
        },
      ),
    );
    controller.textStyleTab = tab;
  }

  Future<void> _showAudioMix() async {
    final l10n = AppLocalizations.of(context);
    await showGraceSheet<void>(
      context: context,
      editorPanel: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final project = controller.project;
          final p = context.grace;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.audioMix, style: GraceType.sheetTitle),
                const SizedBox(height: 16),
                GraceSliderRow(
                  label: l10n.audioVideoSound,
                  value: project.videoVolume,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  display: project.videoVolume == 0
                      ? l10n.audioMuted
                      : project.hasCustomClipVolume
                      ? l10n.audioCustom
                      : formatPercent(project.videoVolume),
                  trailing: GraceIconAction(
                    icon: project.videoVolume == 0
                        ? Icons.volume_off
                        : Icons.volume_up,
                    semanticLabel: project.videoVolume == 0
                        ? l10n.audioUnmute
                        : l10n.audioMute,
                    onPressed: () {
                      controller.setVideoVolume(
                        project.videoVolume == 0 ? 100 : 0,
                      );
                      setSheetState(() {});
                    },
                  ),
                  onChangeStart: (_) => controller.beginGesture(),
                  onChangeEnd: (_) => controller.endGesture(),
                  onChanged: (v) {
                    controller.setVideoVolume(v);
                    setSheetState(() {});
                  },
                ),
                const SizedBox(height: 12),
                Text(l10n.audioMusic, style: GraceType.body),
                for (final audio in project.audios) ...[
                  Row(
                    children: [
                      Icon(Icons.music_note, size: 18, color: p.text),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            controller.selectAudio(audio.id);
                            _showAudioDetail();
                          },
                          child: Text(
                            project.mediaById(audio.mediaId)?.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GraceType.bodyCompact,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // EDT-04 : chaque élément audio a sa ligne « titre, haut-parleur,
                  // curseur, valeur », comme « Son de la vidéo ». Le retrait se
                  // fait depuis la barre de l'audio sélectionné (Supprimer).
                  GraceSliderRow(
                    label: l10n.audioVolumeLabel,
                    value: audio.volume,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    display: audio.volume == 0
                        ? l10n.audioMuted
                        : formatPercent(audio.volume),
                    trailing: GraceIconAction(
                      icon: audio.volume == 0
                          ? Icons.volume_off
                          : Icons.volume_up,
                      semanticLabel: audio.volume == 0
                          ? l10n.audioUnmute
                          : l10n.audioMute,
                      onPressed: () {
                        controller.updateAudio(
                          audio.copyWith(volume: audio.volume == 0 ? 100 : 0),
                        );
                        setSheetState(() {});
                      },
                    ),
                    onChangeStart: (_) => controller.beginGesture(),
                    onChangeEnd: (_) => controller.endGesture(),
                    onChanged: (v) {
                      controller.updateAudio(audio.copyWith(volume: v));
                      setSheetState(() {});
                    },
                  ),
                ],
                const SizedBox(height: 8),
                GraceOutlineButton(
                  label: l10n.audioAddMusic,
                  icon: Icons.library_music_outlined,
                  onPressed: () async {
                    final picked = await ref
                        .read(mediaServiceProvider)
                        .pickAudio();
                    if (!mounted || !context.mounted) return;
                    if (picked.failure != null) {
                      GraceToast.show(
                        context,
                        l10n.pickerUnavailable,
                        isError: true,
                      );
                      return;
                    }
                    if (picked.media.isEmpty) return;
                    final media = mediaRefFromPicked(picked.media.first);
                    controller.addAudio(media);
                    if (!mounted || !sheetContext.mounted) return;
                    Navigator.of(sheetContext).pop();
                    _showAudioDetail();
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.audioMusicHint,
                  style: GraceType.caption.copyWith(color: p.secondary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// EDT-04, situation 3 : volume et fondus d'un élément audio.
  ///
  /// « Volume » et « Fondu » ouvrent la même feuille ; [focusFades] place la
  /// vue sur la partie des fondus, comme le demande la fiche.
  Future<void> _showAudioDetail({bool focusFades = false}) async {
    final l10n = AppLocalizations.of(context);
    final audio = controller.selectedAudio;
    if (audio == null) return;
    final scroll = ScrollController();
    await showGraceSheet<void>(
      context: context,
      editorPanel: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final p = context.grace;
          final current = controller.selectedAudio ?? audio;
          if (focusFades) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!scroll.hasClients) return;
              scroll.animateTo(
                scroll.position.maxScrollExtent,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
            });
          }
          final fadesTooLong =
              current.fadeInMs + current.fadeOutMs > current.durationMs;
          return SingleChildScrollView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.audioVolumeTitle, style: GraceType.sheetTitle),
                const SizedBox(height: 12),
                _FadePreview(
                  media: controller.project.mediaById(current.mediaId),
                  fadeIn: current.durationMs > 0
                      ? current.fadeInMs / current.durationMs
                      : 0,
                  fadeOut: current.durationMs > 0
                      ? current.fadeOutMs / current.durationMs
                      : 0,
                ),
                const SizedBox(height: 16),
                GraceSliderRow(
                  label: l10n.audioVolumeLabel,
                  value: current.volume,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  display: formatPercent(current.volume),
                  onChangeStart: (_) => controller.beginGesture(),
                  onChangeEnd: (_) => controller.endGesture(),
                  onChanged: (v) {
                    controller.updateAudio(current.copyWith(volume: v));
                    setSheetState(() {});
                  },
                ),
                GraceSliderRow(
                  label: l10n.audioFadeIn,
                  value: current.fadeInMs / 1000,
                  min: 0,
                  max: 10,
                  divisions: 100,
                  display: formatSeconds(current.fadeInMs),
                  onChangeStart: (_) => controller.beginGesture(),
                  onChangeEnd: (_) => controller.endGesture(),
                  onChanged: (v) {
                    final fade = (v * 1000).round();
                    if (fade + current.fadeOutMs > current.durationMs) return;
                    controller.updateAudio(current.copyWith(fadeInMs: fade));
                    setSheetState(() {});
                  },
                ),
                GraceSliderRow(
                  label: l10n.audioFadeOut,
                  value: current.fadeOutMs / 1000,
                  min: 0,
                  max: 10,
                  divisions: 100,
                  display: formatSeconds(current.fadeOutMs),
                  onChangeStart: (_) => controller.beginGesture(),
                  onChangeEnd: (_) => controller.endGesture(),
                  onChanged: (v) {
                    final fade = (v * 1000).round();
                    if (fade + current.fadeInMs > current.durationMs) return;
                    controller.updateAudio(current.copyWith(fadeOutMs: fade));
                    setSheetState(() {});
                  },
                ),
                if (fadesTooLong)
                  Text(
                    l10n.audioFadeTooLong,
                    style: GraceType.caption.copyWith(color: p.error),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GraceOutlineButton(
                      label: l10n.actionDelete,
                      icon: Icons.delete_outline,
                      destructive: true,
                      expanded: false,
                      onPressed: () {
                        controller.removeAudio(current.id);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                    const Spacer(),
                    Text(
                      formatDuration(current.durationMs),
                      style: GraceType.secondary.copyWith(color: p.secondary),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    scroll.dispose();
  }

  void _splitAudio() {
    final l10n = AppLocalizations.of(context);
    if (!controller.splitSelectedAudio()) {
      GraceToast.show(context, l10n.editorSplitHint);
      return;
    }
    GraceToast.show(
      context,
      l10n.toastClipSplit,
      actionLabel: l10n.actionUndo,
      onAction: controller.undo,
    );
  }

  Future<void> _showVolume() async {
    final l10n = AppLocalizations.of(context);
    final clip = controller.selectedClip;
    if (clip == null) return;
    await showGraceSheet<void>(
      context: context,
      editorPanel: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final current = controller.selectedClip ?? clip;
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.editorVolume, style: GraceType.sheetTitle),
                const SizedBox(height: 16),
                GraceSliderRow(
                  label: l10n.audioVolumeLabel,
                  value: current.volume,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  display: formatPercent(current.volume),
                  onChanged: (v) {
                    controller.setClipVolume(current.id, v);
                    setSheetState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAdjust() async {
    final l10n = AppLocalizations.of(context);
    var scopeAll = false;
    // Sans sélection, l'outil s'appliquait à rien et semblait cassé : on prend
    // le clip sous la tête de lecture, comme un appui sur la timeline.
    final clip = controller.selectedClip ?? controller.selectClipAtPlayhead();
    if (clip == null) {
      GraceToast.show(context, l10n.editorSelectClipFirst);
      return;
    }
    controller.togglePanel(EditorPanel.adjust);
    await showGraceSheet<void>(
      context: context,
      editorPanel: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final current = controller.selectedClip ?? clip;
          final value = current.adjustments;
          void apply(Adjustments a) {
            if (scopeAll) {
              controller.setAllAdjustments(a);
            } else {
              controller.setClipAdjustments(current.id, a);
            }
            setSheetState(() {});
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.adjustTitle, style: GraceType.sheetTitle),
                const SizedBox(height: 16),
                GraceSliderRow(
                  label: l10n.adjustBrightness,
                  value: value.brightness,
                  min: -100,
                  max: 100,
                  divisions: 40,
                  bipolar: true,
                  display: '${value.brightness.round()}',
                  onChanged: (v) => apply(value.copyWith(brightness: v)),
                ),
                GraceSliderRow(
                  label: l10n.adjustContrast,
                  value: value.contrast,
                  min: -100,
                  max: 100,
                  divisions: 40,
                  bipolar: true,
                  display: '${value.contrast.round()}',
                  onChanged: (v) => apply(value.copyWith(contrast: v)),
                ),
                GraceSliderRow(
                  label: l10n.adjustSaturation,
                  value: value.saturation,
                  min: -100,
                  max: 100,
                  divisions: 40,
                  bipolar: true,
                  display: '${value.saturation.round()}',
                  onChanged: (v) => apply(value.copyWith(saturation: v)),
                ),
                const SizedBox(height: 8),
                GraceSegmented(
                  segments: [
                    GraceSegment(label: l10n.adjustScopeClip),
                    GraceSegment(label: l10n.adjustScopeAll),
                  ],
                  selected: scopeAll ? 1 : 0,
                  onSelected: (i) => setSheetState(() => scopeAll = i == 1),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GraceOutlineButton(
                        label: l10n.adjustCompare,
                        height: 44,
                        onPressed: () => controller.setCompareOriginal(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GraceOutlineButton(
                        label: l10n.adjustReset,
                        height: 44,
                        onPressed: () => apply(const Adjustments()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.adjustCompareHint,
                  style: GraceType.caption.copyWith(
                    color: context.grace.secondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    controller.setCompareOriginal(false);
    controller.togglePanel(EditorPanel.adjust);
  }

  Future<void> _showFormat() async {
    final l10n = AppLocalizations.of(context);
    await showGraceSheet<void>(
      context: context,
      editorPanel: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final project = controller.project;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.formatTitle, style: GraceType.sheetTitle),
                const SizedBox(height: 16),
                RadioGroup<ProjectFormat>(
                  groupValue: project.format,
                  onChanged: (v) {
                    if (v == null) return;
                    controller.setFormat(v);
                    setSheetState(() {});
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final format in ProjectFormat.values)
                        RadioListTile<ProjectFormat>(
                          contentPadding: EdgeInsets.zero,
                          value: format,
                          title: Text(switch (format) {
                            ProjectFormat.vertical => l10n.formatVertical,
                            ProjectFormat.square => l10n.formatSquare,
                            ProjectFormat.horizontal => l10n.formatHorizontal,
                            ProjectFormat.portrait => l10n.formatPortrait,
                          }, style: GraceType.body),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.formatFitMode, style: GraceType.subtitle),
                const SizedBox(height: 8),
                GraceSegmented(
                  segments: [
                    GraceSegment(label: l10n.formatFill),
                    GraceSegment(label: l10n.formatFit),
                  ],
                  selected: project.fitMode == FitMode.fill ? 0 : 1,
                  onSelected: (i) {
                    controller.setFitMode(i == 0 ? FitMode.fill : FitMode.fit);
                    setSheetState(() {});
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.formatFitHint,
                  style: GraceType.caption.copyWith(
                    color: context.grace.secondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCrop() async {
    final l10n = AppLocalizations.of(context);
    final clip = controller.selectedClip;
    if (clip == null) return;
    var value = clip;
    controller.beginGesture();
    final done = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black,
      pageBuilder: (dialogContext, _, _) => StatefulBuilder(
        builder: (context, setDialogState) => Scaffold(
          backgroundColor: GraceColors.preview,
          body: SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    GraceIconAction(
                      icon: Icons.close,
                      semanticLabel: l10n.actionClose,
                      color: GraceColors.ivory,
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                    const Spacer(),
                    Text(
                      l10n.cropTitle,
                      style: GraceType.barTitle.copyWith(
                        color: GraceColors.ivory,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: Text(
                        l10n.commonDone,
                        style: GraceType.bodyMedium.copyWith(
                          color: GraceColors.ivory,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: controller.project.format.ratio,
                      child: _CropSurface(controller: controller, value: value),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _CropAction(
                            icon: Icons.rotate_right,
                            label: l10n.cropRotate,
                            onTap: () {
                              value = value.copyWith(
                                rotation: (value.rotation + 90) % 360,
                              );
                              controller.setClipTransform(
                                value.id,
                                rotation: value.rotation,
                              );
                              setDialogState(() {});
                            },
                          ),
                          _CropAction(
                            icon: Icons.flip,
                            label: l10n.cropMirror,
                            onTap: () {
                              value = value.copyWith(mirrored: !value.mirrored);
                              controller.setClipTransform(
                                value.id,
                                mirrored: value.mirrored,
                              );
                              setDialogState(() {});
                            },
                          ),
                          _CropAction(
                            icon: Icons.restart_alt,
                            label: l10n.cropReset,
                            onTap: () {
                              value = value.copyWith(
                                rotation: 0,
                                mirrored: false,
                                straighten: 0,
                              );
                              controller.setClipTransform(
                                value.id,
                                rotation: 0,
                                mirrored: false,
                                straighten: 0,
                              );
                              setDialogState(() {});
                            },
                          ),
                        ],
                      ),
                      GraceSliderRow(
                        label: l10n.cropStraighten,
                        value: value.straighten,
                        min: -45,
                        max: 45,
                        divisions: 90,
                        bipolar: true,
                        display: '${value.straighten.round()}°',
                        onChanged: (v) {
                          value = value.copyWith(straighten: v);
                          controller.setClipTransform(value.id, straighten: v);
                          setDialogState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (done == true) {
      controller.endGesture();
    } else {
      // La croix annule : l'aperçu a été modifié en direct, on revient à
      // l'état d'ouverture sans ajouter d'entrée d'annulation.
      controller.cancelGesture();
    }
  }

  Future<void> _showCover() async {
    final selection = await context.push<CoverSelection>(
      '/editor/${controller.project.id}/cover',
    );
    if (!mounted || selection == null) return;
    controller.setCover(
      source: selection.source,
      timeMs: selection.timeMs,
      path: selection.path,
      zoom: selection.zoom,
      offsetX: selection.offsetX,
      offsetY: selection.offsetY,
    );
  }

  Future<void> _showTrim() async {
    final l10n = AppLocalizations.of(context);
    final clip = controller.selectedClip;
    if (clip == null) return;
    controller.beginGesture();
    await showGraceSheet<void>(
      context: context,
      editorPanel: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final current = controller.selectedClip ?? clip;
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.trimSheetTitle, style: GraceType.sheetTitle),
                const SizedBox(height: 16),
                _PreciseRow(
                  label: l10n.trimStartLabel,
                  value: formatTrimTime(current.trimStartMs),
                  onMinus: () {
                    controller.trimClip(
                      current.id,
                      start: current.trimStartMs - 100,
                    );
                    setSheetState(() {});
                  },
                  onPlus: () {
                    controller.trimClip(
                      current.id,
                      start: current.trimStartMs + 100,
                    );
                    setSheetState(() {});
                  },
                ),
                _PreciseRow(
                  label: l10n.trimEndLabel,
                  value: formatTrimTime(current.trimEndMs),
                  onMinus: () {
                    controller.trimClip(
                      current.id,
                      end: current.trimEndMs - 100,
                    );
                    setSheetState(() {});
                  },
                  onPlus: () {
                    controller.trimClip(
                      current.id,
                      end: current.trimEndMs + 100,
                    );
                    setSheetState(() {});
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      l10n.trimDurationLabel(
                        formatDuration(current.durationMs),
                      ),
                      style: GraceType.secondary.copyWith(
                        color: context.grace.secondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.trimMinimum,
                      style: GraceType.caption.copyWith(
                        color: context.grace.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    controller.endGesture();
  }

  Future<void> _showMore() async {
    final l10n = AppLocalizations.of(context);
    // EDT-04 : le « Plus » de l'audio ne proposait rien et semblait cassé.
    final audio = controller.selectedAudio;
    if (audio != null) {
      await showGraceSheet<void>(
        context: context,
        builder: (sheetContext) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.content_copy),
                title: Text(l10n.actionDuplicate),
                onTap: () {
                  controller.duplicateAudio(audio.id);
                  Navigator.of(sheetContext).pop();
                },
              ),
            ],
          ),
        ),
      );
      return;
    }
    final clip = controller.selectedClip;
    if (clip == null) return;
    await showGraceSheet<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: Text(l10n.editorDuplicateClip),
              onTap: () {
                controller.duplicateClip(clip.id);
                Navigator.of(sheetContext).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_cut),
              title: Text(l10n.editorPreciseTrim),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showTrim();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: context.grace.error),
              title: Text(
                l10n.editorRemoveClip,
                style: TextStyle(color: context.grace.error),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _deleteSelected();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// EDT-03 : « Plus » du texte — Dupliquer et Aligner.
  Future<void> _showTextMore() async {
    final l10n = AppLocalizations.of(context);
    final item = controller.selectedText;
    if (item == null) return;
    await showGraceSheet<TextAlign>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.content_copy),
              title: Text(l10n.actionDuplicate),
              onTap: () {
                controller.duplicateText(item.id);
                Navigator.of(sheetContext).pop();
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.format_align_left),
              title: Text(l10n.textPresetAlignLeft),
              onTap: () => Navigator.of(sheetContext).pop(TextAlign.left),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.format_align_center),
              title: Text(l10n.textPresetAlignCenter),
              onTap: () => Navigator.of(sheetContext).pop(TextAlign.center),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.format_align_right),
              title: Text(l10n.textPresetAlignRight),
              onTap: () => Navigator.of(sheetContext).pop(TextAlign.right),
            ),
          ],
        ),
      ),
    ).then((value) {
      if (value is! TextAlign || !mounted) return;
      controller.updateText(item.copyWith(align: value));
    });
  }

  void _split() {
    if (!controller.splitSelectedClip()) {
      GraceToast.show(context, AppLocalizations.of(context).editorSplitHint);
      return;
    }
    GraceToast.show(
      context,
      AppLocalizations.of(context).toastClipSplit,
      actionLabel: AppLocalizations.of(context).actionUndo,
      onAction: controller.undo,
    );
  }

  void _deleteSelected() {
    final l10n = AppLocalizations.of(context);
    if (controller.selectedClip != null) {
      final id = controller.selectedClip!.id;
      controller.removeClip(id);
      GraceToast.show(
        context,
        l10n.toastClipDeleted,
        actionLabel: l10n.actionUndo,
        onAction: controller.undo,
      );
    } else if (controller.selectedText != null) {
      controller.removeText(controller.selectedText!.id);
      GraceToast.show(
        context,
        l10n.toastTextDeleted,
        actionLabel: l10n.actionUndo,
        onAction: controller.undo,
      );
    } else if (controller.selectedAudio != null) {
      controller.removeAudio(controller.selectedAudio!.id);
      GraceToast.show(
        context,
        l10n.toastAudioDeleted,
        actionLabel: l10n.actionUndo,
        onAction: controller.undo,
      );
    }
  }
}

class _PortraitBody extends StatelessWidget {
  const _PortraitBody({
    required this.controller,
    required this.onEditText,
    required this.onAddMedia,
    required this.onReconnect,
  });

  final EditorController controller;
  final ValueChanged<TextItem> onEditText;
  final VoidCallback onAddMedia;
  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EditorPreview(
          controller: controller,
          onEditText: onEditText,
          onMoveTextStart: controller.beginGesture,
          onMoveText: (text, fractionX, fractionY) {
            controller.updateText(
              text.copyWith(
                x: (text.x + fractionX).clamp(0.05, 0.95),
                y: (text.y + fractionY).clamp(0.05, 0.95),
              ),
            );
          },
          onMoveTextEnd: controller.endGesture,
          onReconnect: onReconnect,
        ),
        _PlayLine(controller: controller),
        Expanded(
          child: EditorTimeline(controller: controller, onAddMedia: onAddMedia),
        ),
      ],
    );
  }
}

class _LandscapeBody extends StatelessWidget {
  const _LandscapeBody({
    required this.controller,
    required this.onEditText,
    required this.onAddMedia,
    required this.onReconnect,
  });

  final EditorController controller;
  final ValueChanged<TextItem> onEditText;
  final VoidCallback onAddMedia;
  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Row(
          children: [
            SizedBox(
              width: 280,
              child: Column(
                children: [
                  EditorPreview(
                    controller: controller,
                    onEditText: onEditText,
                    onMoveTextStart: controller.beginGesture,
                    onMoveText: (text, fractionX, fractionY) =>
                        controller.updateText(
                          text.copyWith(
                            x: (text.x + fractionX).clamp(0.05, 0.95),
                            y: (text.y + fractionY).clamp(0.05, 0.95),
                          ),
                        ),
                    onMoveTextEnd: controller.endGesture,
                    onReconnect: onReconnect,
                  ),
                  _PlayLine(controller: controller),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: EditorTimeline(
                controller: controller,
                onAddMedia: onAddMedia,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayLine extends StatelessWidget {
  const _PlayLine({required this.controller});
  final EditorController controller;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: GraceDims.playLine,
      child: Row(
        children: [
          const SizedBox(width: 24),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: formatDuration(controller.positionMs),
                  style: GraceType.bodyMedium.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                TextSpan(
                  text: ' / ${formatDuration(controller.durationMs)}',
                  style: GraceType.bodyMedium.copyWith(
                    color: p.secondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Semantics(
            button: true,
            label: controller.isPlaying ? l10n.actionPause : l10n.actionPlay,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: controller.togglePlay,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.isEmpty ? p.surface : p.button,
                ),
                child: Icon(
                  controller.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 26,
                  color: controller.isEmpty ? p.secondary : p.onButton,
                ),
              ),
            ),
          ),
          const Spacer(),
          _UndoAction(
            icon: Icons.undo,
            label: l10n.actionUndo,
            onTap: controller.canUndo ? controller.undo : null,
          ),
          _UndoAction(
            icon: Icons.redo,
            label: l10n.actionRedo,
            onTap: controller.canRedo ? controller.redo : null,
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _UndoAction extends StatelessWidget {
  const _UndoAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 48,
          child: Icon(
            icon,
            size: 22,
            color: onTap == null ? p.outline : p.text,
          ),
        ),
      ),
    );
  }
}

class _EditorTopBar extends StatelessWidget {
  const _EditorTopBar({
    required this.controller,
    required this.l10n,
    required this.onBack,
  });
  final EditorController controller;
  final AppLocalizations l10n;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return SizedBox(
      height: GraceDims.topBar,
      child: Row(
        children: [
          const SizedBox(width: 4),
          GraceIconAction(
            icon: Icons.arrow_back,
            semanticLabel: l10n.semanticsBack,
            onPressed: onBack,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.project.title.isEmpty
                      ? l10n.editorUntitled
                      : controller.project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GraceType.barTitle,
                ),
                Row(
                  children: [
                    Icon(
                      switch (controller.saveState) {
                        SaveState.saved => Icons.check,
                        SaveState.saving => Icons.sync,
                        SaveState.failed => Icons.warning_amber_rounded,
                        SaveState.recovered => Icons.check,
                      },
                      size: 13,
                      color: controller.saveState == SaveState.failed
                          ? p.error
                          : p.secondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        switch (controller.saveState) {
                          SaveState.saved => l10n.saveStateSaved,
                          SaveState.saving => l10n.saveStateSaving,
                          SaveState.failed => l10n.saveStateFailed,
                          SaveState.recovered => l10n.saveStateSaved,
                        },
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GraceType.small.copyWith(
                          color: controller.saveState == SaveState.failed
                              ? p.error
                              : p.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GracePillAction(
            label: l10n.actionExport,
            onPressed: controller.isEmpty
                ? null
                : () => context.push('/export/${controller.project.id}'),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _SaveFailedBanner extends StatelessWidget {
  const _SaveFailedBanner({required this.onRetry, required this.onFreeSpace});
  final VoidCallback onRetry;
  final VoidCallback onFreeSpace;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.grace;
    return Container(
      color: p.surface,
      padding: const EdgeInsets.fromLTRB(24, 10, 12, 10),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 20, color: p.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.editorSaveFailed,
              style: GraceType.secondaryMedium.copyWith(color: p.error),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(l10n.actionRetry)),
          TextButton(onPressed: onFreeSpace, child: Text(l10n.saveFreeSpace)),
        ],
      ),
    );
  }
}

class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({
    required this.controller,
    required this.onAdd,
    required this.onAudio,
    required this.onAudioVolume,
    required this.onAudioFade,
    required this.onAudioSplit,
    required this.onText,
    required this.onAdjust,
    required this.onFormat,
    required this.onCover,
    required this.onSplit,
    required this.onVolume,
    required this.onCrop,
    required this.onDelete,
    required this.onMore,
    required this.onBack,
    required this.onEditText,
    required this.onStyle,
    required this.onColor,
    required this.onTextMore,
  });

  final EditorController controller;
  final VoidCallback onAdd;
  final VoidCallback onAudio;
  final VoidCallback onAudioVolume;
  final VoidCallback onAudioFade;
  final VoidCallback onAudioSplit;
  final VoidCallback onText;
  final VoidCallback onAdjust;
  final VoidCallback onFormat;
  final VoidCallback onCover;
  final VoidCallback onSplit;
  final VoidCallback onVolume;
  final VoidCallback onCrop;
  final VoidCallback onDelete;
  final VoidCallback onMore;
  final VoidCallback onBack;

  /// EDT-03 : barre d'outils propre au texte sélectionné.
  final VoidCallback onEditText;
  final VoidCallback onStyle;
  final VoidCallback onColor;
  final VoidCallback onTextMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = controller.selection != SelectionType.none;
    final text = controller.selectedText;
    final clipSelected = controller.selectedClip != null && text == null;
    return Container(
      height: GraceDims.toolbar + MediaQuery.paddingOf(context).bottom,
      color: context.grace.background,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: !selected
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _Tool(icon: Icons.add, label: l10n.editorAdd, onTap: onAdd),
                  _Tool(
                    icon: Icons.music_note,
                    label: l10n.editorAudio,
                    onTap: onAudio,
                  ),
                  _Tool(
                    icon: Icons.title,
                    label: l10n.editorText,
                    onTap: onText,
                  ),
                  _Tool(
                    icon: Icons.tune,
                    label: l10n.editorAdjust,
                    onTap: onAdjust,
                  ),
                  _Tool(
                    icon: Icons.aspect_ratio,
                    label: l10n.editorFormat,
                    onTap: onFormat,
                  ),
                  _Tool(
                    icon: Icons.image_outlined,
                    label: l10n.editorCover,
                    onTap: onCover,
                  ),
                ],
              ),
            )
          : Row(
              children: [
                const SizedBox(width: 4),
                GraceIconAction(
                  icon: Icons.chevron_left,
                  semanticLabel: l10n.actionBack,
                  onPressed: onBack,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: text != null
                          ? [
                              // EDT-03 : Modifier · Style · Couleur · Supprimer · Plus
                              _Tool(
                                icon: Icons.edit_outlined,
                                label: l10n.textEdit,
                                onTap: onEditText,
                              ),
                              _Tool(
                                icon: Icons.format_paint,
                                label: l10n.textStyle,
                                onTap: onStyle,
                              ),
                              _Tool(
                                icon: Icons.palette_outlined,
                                label: l10n.textColor,
                                onTap: onColor,
                              ),
                              _Tool(
                                icon: Icons.delete_outline,
                                label: l10n.editorDelete,
                                onTap: onDelete,
                              ),
                              _Tool(
                                icon: Icons.more_horiz,
                                label: l10n.actionMore,
                                onTap: onTextMore,
                              ),
                            ]
                          : [
                              if (clipSelected) ...[
                                _Tool(
                                  icon: Icons.content_cut,
                                  label: l10n.editorSplit,
                                  onTap: onSplit,
                                ),
                                _Tool(
                                  icon: Icons.volume_up,
                                  label: l10n.editorVolume,
                                  onTap: onVolume,
                                ),
                                _Tool(
                                  icon: Icons.crop_free,
                                  label: l10n.editorCrop,
                                  onTap: onCrop,
                                ),
                              ],
                              // EDT-04, situation 2 : Volume · Fondu ·
                              // Scinder · Supprimer · Plus.
                              if (controller.selectedAudio != null) ...[
                                _Tool(
                                  icon: Icons.volume_up,
                                  label: l10n.audioVolumeLabel,
                                  onTap: onAudioVolume,
                                ),
                                _Tool(
                                  icon: Icons.gradient,
                                  label: l10n.audioFade,
                                  onTap: onAudioFade,
                                ),
                                _Tool(
                                  icon: Icons.content_cut,
                                  label: l10n.editorSplit,
                                  onTap: onAudioSplit,
                                ),
                              ],
                              _Tool(
                                icon: Icons.delete_outline,
                                label: l10n.editorDelete,
                                onTap: onDelete,
                              ),
                              _Tool(
                                icon: Icons.more_horiz,
                                label: l10n.actionMore,
                                onTap: onMore,
                              ),
                            ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 72,
          height: GraceDims.toolbar,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GraceType.small,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreciseRow extends StatelessWidget {
  const _PreciseRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });
  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: GraceType.body)),
        const Spacer(),
        _RoundButton(
          icon: Icons.remove,
          semanticLabel: l10n.actionLess,
          onTap: onMinus,
        ),
        SizedBox(
          width: 100,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: GraceType.bodyMedium.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _RoundButton(
          icon: Icons.add,
          semanticLabel: l10n.actionMore,
          onTap: onPlus,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: onTap,
        tooltip: semanticLabel,
        icon: Icon(icon, size: 20),
        style: IconButton.styleFrom(backgroundColor: context.grace.surface),
      ),
    );
  }
}

class _CropAction extends StatelessWidget {
  const _CropAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 88,
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: GraceColors.ivory, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GraceType.small.copyWith(color: GraceColors.ivory),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CropSurface extends StatelessWidget {
  const _CropSurface({required this.controller, required this.value});
  final EditorController controller;
  final Clip value;

  @override
  Widget build(BuildContext context) {
    final media = controller.mediaFor(value);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (media != null)
          GraceThumb(
            media: media,
            width: 1000,
            height: 1000,
            timeMs: value.trimStartMs,
            showDuration: false,
          ),
        IgnorePointer(child: CustomPaint(painter: _ThirdGridPainter())),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: GraceColors.accent, width: 2),
          ),
        ),
      ],
    );
  }
}

/// Aperçu réduit de la forme d'onde avec les rampes de fondu (EDT-04).
///
/// La forme montre le fondu autant qu'elle le règle ; les durées restent
/// écrites dans les curseurs, la couleur n'est pas le seul signal.
class _FadePreview extends StatefulWidget {
  const _FadePreview({
    required this.media,
    required this.fadeIn,
    required this.fadeOut,
  });

  final MediaRef? media;
  final double fadeIn;
  final double fadeOut;

  @override
  State<_FadePreview> createState() => _FadePreviewState();
}

class _FadePreviewState extends State<_FadePreview> {
  Future<List<double>?>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_FadePreview old) {
    super.didUpdateWidget(old);
    if (old.media?.id != widget.media?.id) _load();
  }

  void _load() {
    final media = widget.media;
    if (media == null) {
      _future = Future.value(const <double>[]);
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
    final p = context.grace;
    return Semantics(
      label: l10n.audioFadePreview,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: ui.Clip.antiAlias,
        child: FutureBuilder<List<double>?>(
          future: _future,
          builder: (context, snapshot) {
            final values = snapshot.data;
            return CustomPaint(
              painter: _FadeWavePainter(
                values: values ?? const [],
                color: p.secondary,
                rampColor: p.text,
                fadeIn: widget.fadeIn,
                fadeOut: widget.fadeOut,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _FadeWavePainter extends CustomPainter {
  const _FadeWavePainter({
    required this.values,
    required this.color,
    required this.rampColor,
    required this.fadeIn,
    required this.fadeOut,
  });

  final List<double> values;
  final Color color;
  final Color rampColor;
  final double fadeIn;
  final double fadeOut;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    if (values.isNotEmpty) {
      final bars = (size.width ~/ 3).clamp(1, values.length);
      for (var i = 0; i < bars; i++) {
        final start = (i * values.length / bars).floor();
        final end = ((i + 1) * values.length / bars).ceil().clamp(
          start + 1,
          values.length,
        );
        var peak = 0.0;
        for (var j = start; j < end; j++) {
          if (values[j] > peak) peak = values[j];
        }
        final x = (i + 0.5) * size.width / bars;
        final amplitude = (0.08 + peak * 0.92) * size.height / 2;
        canvas.drawLine(
          Offset(x, size.height / 2 - amplitude),
          Offset(x, size.height / 2 + amplitude),
          paint,
        );
      }
    }
    final ramp = Paint()
      ..color = rampColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final top = size.height * 0.12;
    final bottom = size.height * 0.88;
    if (fadeIn > 0) {
      canvas.drawLine(
        Offset(0, bottom),
        Offset(size.width * fadeIn.clamp(0, 1), top),
        ramp,
      );
    }
    if (fadeOut > 0) {
      canvas.drawLine(
        Offset(size.width * (1 - fadeOut.clamp(0, 1)), top),
        Offset(size.width, bottom),
        ramp,
      );
    }
  }

  @override
  bool shouldRepaint(_FadeWavePainter old) =>
      old.values != values ||
      old.fadeIn != fadeIn ||
      old.fadeOut != fadeOut ||
      old.color != color ||
      old.rampColor != rampColor;
}

class _ThirdGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GraceColors.ivory.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * i / 3, 0),
        Offset(size.width * i / 3, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 3),
        Offset(size.width, size.height * i / 3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ThirdGridPainter oldDelegate) => false;
}
