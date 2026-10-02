/// Simple (beginner) video editor: real import, video preview,
/// timeline with thumbnails, trim/split/delete, text, undo/redo,
/// autosave, export profile picker.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/commands/commands.dart';
import '../../core/models/grace_project.dart';
import '../../core/platform/capabilities.dart';
import '../../core/services/import_service.dart';
import '../../core/services/thumbnails.dart';
import '../../core/state/providers.dart';
import '../../theme/tokens.dart';
import '../library/thumb_widget.dart';
import 'subtitles_screen.dart';

/// Builds a 4x5 color matrix for brightness/contrast/saturation adjustments.
/// brightness: -1..1, contrast/saturation: multipliers around 1.
List<double> graceColorMatrix(double brightness, double contrast, double saturation) {
  final b = brightness * 255.0;
  // Saturation matrix (luminance weights) scaled by [saturation].
  final s = saturation;
  final sr = (1 - s) * 0.2126, sg = (1 - s) * 0.7152, sb = (1 - s) * 0.0722;
  // Combined: first saturation, then contrast + brightness offset.
  final List<double> m = [
    (sr + s) * contrast, sg * contrast, sb * contrast, 0.0, b,
    sr * contrast, (sg + s) * contrast, sb * contrast, 0.0, b,
    sr * contrast, sg * contrast, (sb + s) * contrast, 0.0, b,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ];
  return m;
}

final importServiceProvider =
    Provider<ImportService>((ref) => ImportService());

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, required this.projectId});
  final String projectId;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  bool _saving = false;
  bool _importing = false;
  String? _notice;
  ExportProfile _profile = ExportProfile.all[1];
  int? _selectedClipIndex;

  EditorSession? get _session => ref.watch(editorSessionProvider);

  Future<void> _persist() async {
    final s = ref.read(editorSessionProvider);
    if (s == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(projectRepositoryProvider).save(s.project);
      await ref.read(projectsProvider.notifier).refresh();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _exec(ProjectCommand cmd) {
    final s = ref.read(editorSessionProvider);
    if (s == null) return;
    setState(() => s.commands.execute(s.project, cmd));
    ref.read(projectRepositoryProvider).markDirty(s.project.id);
    _persist();
  }

  Future<void> _importMenu() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: const Text('Vidéo de la galerie'),
              onTap: () => Navigator.pop(c, 'video_gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Filmer une vidéo'),
              onTap: () => Navigator.pop(c, 'video_camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Photo de la galerie'),
              onTap: () => Navigator.pop(c, 'image_gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(c, 'image_camera'),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    final svc = ref.read(importServiceProvider);
    setState(() { _importing = true; _notice = null; });
    try {
      ImportResult? result;
      switch (choice) {
        case 'video_gallery':
          result = await svc.pickVideo(source: ImportSource.gallery);
        case 'video_camera':
          result = await svc.pickVideo(source: ImportSource.camera);
        case 'image_gallery':
          result = await svc.pickImage(source: ImportSource.gallery);
        case 'image_camera':
          result = await svc.pickImage(source: ImportSource.camera);
      }
      if (result == null) return; // cancelled
      if (!await ImportService.isReadable(result.asset.path)) {
        if (mounted) {
          setState(() => _notice = 'Fichier illisible ou vide — import annulé.');
        }
        return;
      }
      final s = ref.read(editorSessionProvider);
      if (s == null) return;
      var asset = result.asset;
      // Probe real video duration when possible.
      if (asset.kind == MediaKind.video) {
        final ms = await _probeVideoMs(asset.path);
        if (ms != null && ms > 0) {
          asset = MediaAsset(
            id: asset.id, kind: asset.kind, path: asset.path,
            durationMs: ms, source: asset.source,
          );
        }
      }
      setState(() => s.project.assets.add(asset));
      if (asset.kind == MediaKind.video) {
        final end = asset.durationMs ?? 5000;
        _exec(AddClipCommand(VideoClip(
          id: GraceProject.newId(), assetId: asset.id,
          startMs: 0, endMs: end,
        )));
      } else {
        // Photo => 3s still clip backed by the image.
        _exec(AddClipCommand(VideoClip(
          id: GraceProject.newId(), assetId: asset.id,
          startMs: 0, endMs: 3000,
        )));
      }
    } on Exception catch (e) {
      if (mounted) setState(() => _notice = 'Import impossible : $e');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<int?> _probeVideoMs(String path) async {
    try {
      final c = VideoPlayerController.file(File(path));
      await c.initialize();
      final ms = c.value.duration.inMilliseconds;
      await c.dispose();
      return ms > 0 ? ms : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _session;
    final strings = ref.watch(stringsProvider);
    final g = context.grace;
    if (s == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(strings.errorGeneric)),
      );
    }
    final p = s.project;
    final profiles = ExportProfile.supportedBy(DeviceCapabilities.fallback);
    VideoClip? selected;
    if (_selectedClipIndex != null && _selectedClipIndex! < p.clips.length) {
      selected = p.clips[_selectedClipIndex!];
    }
    MediaAsset? selectedAsset;
    if (selected != null) {
      for (final a in p.assets) {
        if (a.id == selected.assetId) selectedAsset = a;
      }
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () async {
            await ref.read(projectRepositoryProvider).save(p);
            await ref.read(projectsProvider.notifier).refresh();
            if (context.mounted) context.pop();
          },
        ),
        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          IconButton(
            tooltip: 'Sous-titres',
            icon: Badge(
              isLabelVisible: p.subtitles.isNotEmpty,
              label: Text('${p.subtitles.length}'),
              child: const Icon(Icons.closed_caption_outlined),
            ),
            onPressed: () => context.push('/subtitles'),
          ),
          IconButton(
            tooltip: 'Bibliothèque',
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: () => context.push('/assets'),
          ),
          IconButton(
            tooltip: strings.undo,
            icon: const Icon(Icons.undo),
            onPressed: s.commands.canUndo
                ? () { setState(() => s.commands.undo(p)); _persist(); }
                : null,
          ),
          IconButton(
            tooltip: strings.redo,
            icon: const Icon(Icons.redo),
            onPressed: s.commands.canRedo
                ? () { setState(() => s.commands.redo(p)); _persist(); }
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_notice != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: g.elevated,
              child: Text(_notice!,
                  style: TextStyle(color: g.textSecondary, fontSize: 13)),
            ),
          // Preview area: real video playback when a video clip is selected.
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(GraceSpacing.m),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: g.border),
                borderRadius: BorderRadius.circular(GraceRadius.l),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildPreview(p, selected, selectedAsset, g),
            ),
          ),
          // Timeline with real thumbnails.
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: GraceSpacing.m),
            child: p.clips.isEmpty
                ? Center(
                    child: Text(strings.timeline,
                        style: TextStyle(color: g.textSecondary)))
                : ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: p.clips.length,
                    onReorder: (oldI, newI) {
                      if (newI > oldI) newI -= 1;
                      _exec(MoveClipCommand(p.clips[oldI].id, newI));
                    },
                    itemBuilder: (c, i) {
                      final clip = p.clips[i];
                      MediaAsset? asset;
                      for (final a in p.assets) {
                        if (a.id == clip.assetId) asset = a;
                      }
                      final sel = _selectedClipIndex == i;
                      return GestureDetector(
                        key: ValueKey(clip.id),
                        onTap: () => setState(() => _selectedClipIndex = i),
                        child: Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: g.surface,
                            border: Border.all(
                                color: sel ? g.primary : g.border,
                                width: sel ? 2 : 1),
                            borderRadius:
                                BorderRadius.circular(GraceRadius.m),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              Expanded(
                                child: asset == null
                                    ? const Icon(Icons.broken_image_outlined)
                                    : GraceThumb(
                                        assetId: asset.id,
                                        sourcePath: asset.path,
                                        kind: asset.kind.name,
                                        frameMs: ThumbnailService
                                            .representativeFrameMs(
                                                clip.durationMs),
                                        width: double.infinity,
                                        height: double.infinity,
                                        borderRadius: 0,
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  '${(clip.durationMs / 1000).toStringAsFixed(1)}s · ×${clip.speed}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Contextual actions.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(GraceSpacing.m),
            child: Row(
              children: [
                _Action(
                  icon: Icons.add_photo_alternate_outlined,
                  label: _importing ? '…' : 'Importer',
                  onTap: _importing ? null : _importMenu,
                ),
                _Action(
                    icon: Icons.content_cut, label: strings.split,
                    enabled: selected != null,
                    onTap: () {
                      final clip = selected!;
                      final mid =
                          (clip.startMs + clip.endMs) ~/ 2;
                      _exec(SplitClipCommand(clip.id, mid));
                    }),
                _Action(
                    icon: Icons.crop_outlined, label: strings.trim,
                    enabled: selected != null,
                    onTap: _trimSheet),
                _Action(
                    icon: Icons.speed_outlined, label: 'Vitesse',
                    enabled: selected != null,
                    onTap: _speedVolumeSheet),
                _Action(
                    icon: Icons.tune_outlined, label: 'Filtres',
                    enabled: selected != null,
                    onTap: _filterSheet),
                _Action(
                    icon: Icons.rotate_right_outlined, label: 'Rotation',
                    enabled: selected != null,
                    onTap: () {
                      final clip = selected!;
                      _exec(UpdateClipPropsCommand(
                          clip.id, rotation: (clip.rotation + 90) % 360));
                    }),
                _Action(
                    icon: Icons.delete_outline, label: strings.delete,
                    enabled: selected != null,
                    onTap: () {
                      _exec(RemoveClipCommand(selected!.id));
                      setState(() => _selectedClipIndex = null);
                    }),
                _Action(
                    icon: Icons.text_fields, label: strings.addText,
                    onTap: () async {
                      final controller = TextEditingController();
                      final text = await showDialog<String>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(strings.addText),
                          content: TextField(
                              controller: controller, autofocus: true),
                          actions: [
                            FilledButton(
                              onPressed: () => Navigator.pop(
                                  c, controller.text.trim()),
                              child: Text(strings.save),
                            ),
                          ],
                        ),
                      );
                      if (text != null && text.isNotEmpty) {
                        setState(() => p.texts.add(TextLayer(
                            id: GraceProject.newId(), text: text)));
                        _persist();
                      }
                    }),
              ],
            ),
          ),
          // Export bar.
          Container(
            padding: const EdgeInsets.fromLTRB(
                GraceSpacing.m, GraceSpacing.s, GraceSpacing.m, GraceSpacing.m),
            decoration: BoxDecoration(
              color: g.surface,
              border: Border(top: BorderSide(color: g.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ExportProfile>(
                    initialValue: profiles.contains(_profile)
                        ? _profile
                        : profiles.first,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8)),
                    items: [
                      for (final pr in profiles)
                        DropdownMenuItem(value: pr, child: Text(pr.label)),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _profile = v);
                    },
                  ),
                ),
                const SizedBox(width: GraceSpacing.m),
                FilledButton.icon(
                  onPressed: p.clips.isEmpty
                      ? null
                      : () => context.push('/export/${p.id}', extra: _profile),
                  icon: const Icon(Icons.ios_share),
                  label: Text(strings.export),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _trimSheet() async {
    final s = ref.read(editorSessionProvider);
    final idx = _selectedClipIndex;
    if (s == null || idx == null || idx >= s.project.clips.length) return;
    final clip = s.project.clips[idx];
    MediaAsset? asset;
    for (final a in s.project.assets) {
      if (a.id == clip.assetId) asset = a;
    }
    final maxMs = (asset?.durationMs ?? clip.endMs).toDouble();
    var start = clip.startMs.toDouble();
    var end = clip.endMs.toDouble();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setB) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rogner : ${(start / 1000).toStringAsFixed(1)}s → ${(end / 1000).toStringAsFixed(1)}s',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                RangeSlider(
                  values: RangeValues(start, end),
                  max: maxMs,
                  divisions: maxMs.round().clamp(1, 600),
                  labels: RangeLabels(
                    '${(start / 1000).toStringAsFixed(1)}s',
                    '${(end / 1000).toStringAsFixed(1)}s',
                  ),
                  onChanged: (v) => setB(() {
                    start = v.start;
                    end = v.end;
                  }),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: end - start >= 500
                        ? () => Navigator.pop(c, true)
                        : null,
                    child: const Text('Appliquer (min 0,5s)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (ok == true) {
      _exec(TrimClipCommand(clip.id,
          newStartMs: start.round(), newEndMs: end.round()));
    }
  }

  Future<void> _speedVolumeSheet() async {
    final s = ref.read(editorSessionProvider);
    final idx = _selectedClipIndex;
    if (s == null || idx == null || idx >= s.project.clips.length) return;
    final clip = s.project.clips[idx];
    var speed = clip.speed;
    var volume = clip.volume;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setB) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Vitesse : ×${speed.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                    value: speed, min: 0.5, max: 2.0, divisions: 6,
                    label: '×${speed.toStringAsFixed(2)}',
                    onChanged: (v) => setB(() => speed = v)),
                Text('Volume : ${(volume * 100).round()} %',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                    value: volume, min: 0.0, max: 1.0, divisions: 10,
                    label: '${(volume * 100).round()} %',
                    onChanged: (v) => setB(() => volume = v)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(c, true),
                    child: const Text('Appliquer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (ok == true) {
      _exec(UpdateClipPropsCommand(clip.id, speed: speed, volume: volume));
    }
  }

  Future<void> _filterSheet() async {
    final s = ref.read(editorSessionProvider);
    final idx = _selectedClipIndex;
    if (s == null || idx == null || idx >= s.project.clips.length) return;
    final clip = s.project.clips[idx];
    var brightness = clip.brightness;
    var contrast = clip.contrast;
    var saturation = clip.saturation;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setB) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Luminosité : ${brightness.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                    value: brightness, min: -0.5, max: 0.5, divisions: 20,
                    onChanged: (v) => setB(() => brightness = v)),
                Text('Contraste : ${contrast.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                    value: contrast, min: 0.5, max: 1.5, divisions: 20,
                    onChanged: (v) => setB(() => contrast = v)),
                Text('Saturation : ${saturation.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                    value: saturation, min: 0.0, max: 2.0, divisions: 20,
                    onChanged: (v) => setB(() => saturation = v)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setB(() {
                          brightness = 0.0;
                          contrast = 1.0;
                          saturation = 1.0;
                        }),
                        child: const Text('Réinitialiser'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('Appliquer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (ok == true) {
      _exec(UpdateClipPropsCommand(clip.id,
          brightness: brightness, contrast: contrast, saturation: saturation));
    }
  }

  Widget _buildPreview(
      GraceProject p, VideoClip? clip, MediaAsset? asset, GraceColors g) {
    Widget applyEffects(Widget child) {
      var out = child;
      if (clip != null &&
          (clip.brightness != 0.0 ||
              clip.contrast != 1.0 ||
              clip.saturation != 1.0)) {
        out = ColorFiltered(
          colorFilter: ColorFilter.matrix(graceColorMatrix(
              clip.brightness, clip.contrast, clip.saturation)),
          child: out,
        );
      }
      if (clip != null && clip.rotation != 0) {
        out = RotatedBox(quarterTurns: (clip.rotation ~/ 90) % 4, child: out);
      }
      return out;
    }

    if (asset != null &&
        asset.kind == MediaKind.video &&
        File(asset.path).existsSync()) {
      return applyEffects(
          _PreviewPlayer(key: ValueKey(asset.id), path: asset.path));
    }
    if (asset != null &&
        asset.kind == MediaKind.image &&
        File(asset.path).existsSync()) {
      return applyEffects(Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(asset.path), fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image_outlined))),
          if (p.texts.isNotEmpty)
            Center(
              child: Text(p.texts.last.text,
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 8)])),
            ),
        ],
      ));
    }
    // Empty state.
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_outlined, size: 56, color: g.textSecondary),
          const SizedBox(height: 8),
          Text('Importez une vidéo ou une photo pour commencer',
              style: TextStyle(color: g.textSecondary, fontSize: 15)),
          const SizedBox(height: 4),
          Text('${p.canvas.width}×${p.canvas.height} · ${p.canvas.fps} fps',
              style: TextStyle(color: g.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

/// Self-contained video preview with play/pause.
class _PreviewPlayer extends StatefulWidget {
  const _PreviewPlayer({super.key, required this.path});
  final String path;

  @override
  State<_PreviewPlayer> createState() => _PreviewPlayerState();
}

class _PreviewPlayerState extends State<_PreviewPlayer> {
  VideoPlayerController? _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = VideoPlayerController.file(File(widget.path));
      await c.initialize();
      await c.setLooping(true);
      if (mounted) setState(() => _controller = c);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return const Center(
        child: Icon(Icons.broken_image_outlined,
            color: Colors.white70, size: 48),
      );
    }
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const Center(
        child: SizedBox(
            width: 28, height: 28,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white70)),
      );
    }
    return GestureDetector(
      onTap: () => setState(
          () => c.value.isPlaying ? c.pause() : c.play()),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
                width: c.value.size.width,
                height: c.value.size.height,
                child: VideoPlayer(c)),
          ),
          if (!c.value.isPlaying)
            const Center(
              child: Icon(Icons.play_circle_outline,
                  color: Colors.white, size: 64),
            ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.enabled = true});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onPressed: enabled ? onTap : null,
      ),
    );
  }
}
