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
              child: _buildPreview(p, selectedAsset, g, strings),
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

  Widget _buildPreview(GraceProject p, MediaAsset? asset, GraceColors g,
      dynamic strings) {
    if (asset != null &&
        asset.kind == MediaKind.video &&
        File(asset.path).existsSync()) {
      return _PreviewPlayer(key: ValueKey(asset.id), path: asset.path);
    }
    if (asset != null &&
        asset.kind == MediaKind.image &&
        File(asset.path).existsSync()) {
      return Stack(
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
      );
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
