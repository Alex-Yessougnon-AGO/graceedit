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
  ExportProfile? _profile;
  int? _selectedClipIndex;
  bool _booting = true;
  String? _bootError;

  /// The clip the tools act on. Falls back to the first clip so actions and the
  /// preview keep working right after an import without an extra tap.
  int? get _activeClipIndex {
    final session = ref.read(editorSessionProvider);
    if (session == null || session.project.clips.isEmpty) return null;
    final i = _selectedClipIndex;
    if (i == null || i < 0 || i >= session.project.clips.length) return 0;
    return i;
  }

  @override
  void initState() {
    super.initState();
    _ensureSession();
  }

  /// Reload the project from disk when the in-memory session is missing
  /// or targets another project (relaunch, deep link). Undo history
  /// restarts fresh — persisted content is authoritative.
  Future<void> _ensureSession() async {
    final current = ref.read(editorSessionProvider);
    if (current != null && current.project.id == widget.projectId) {
      if (mounted) setState(() => _booting = false);
      return;
    }
    try {
      final loaded =
          await ref.read(projectRepositoryProvider).load(widget.projectId);
      if (!mounted) return;
      if (loaded == null) {
        setState(() {
          _booting = false;
          _bootError = 'Projet introuvable — il a peut-être été supprimé.';
        });
        return;
      }
      ref.read(editorSessionProvider.notifier).state = EditorSession(loaded);
      setState(() => _booting = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _booting = false;
          _bootError = 'Ouverture impossible — stockage illisible.';
        });
      }
    }
  }

  EditorSession? get _session => ref.watch(editorSessionProvider);

  Future<void> _persist() async {
    final s = ref.read(editorSessionProvider);
    if (s == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(projectRepositoryProvider).save(s.project);
      await ref
          .read(thumbnailServiceProvider)
          .invalidateAsset('project-${s.project.id}');
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
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.perm_media_outlined),
              title: const Text('Mes vidéos importées'),
              subtitle: const Text('Voir et ranger les fichiers du téléphone'),
              onTap: () => Navigator.pop(c, 'library'),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    if (choice == 'library') {
      if (mounted) context.push('/assets');
      return;
    }
    // Ask for the camera only when the user actually films — asking up front
    // for a library permission the system picker does not need is scary and
    // pointless.
    if (choice == 'video_camera' || choice == 'image_camera') {
      final allowed =
          await ref.read(permissionServiceProvider).requestCamera();
      if (!allowed) {
        if (mounted) {
          setState(() => _notice =
              'Autorisez la caméra dans les réglages pour filmer depuis '
              'GraceEdit.');
        }
        return;
      }
    }
    final svc = ref.read(importServiceProvider);
    setState(() { _importing = true; _notice = null; });
    try {
      ImportResult? result;
      switch (choice) {
        case 'video_gallery':
          result = await svc.pickVideo(source: ImportSource.gallery);
        case 'video_camera':
          result = await svc.pickVideo(source: ImportSource.camera);
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
      // Probe the real video duration + dimensions.
      if (asset.kind == MediaKind.video) {
        final info = await _probeVideo(asset.path);
        if (info != null) {
          asset = MediaAsset(
            id: asset.id, kind: asset.kind, path: asset.path,
            durationMs: info.durationMs,
            width: info.width, height: info.height,
            source: asset.source,
          );
        }
        // First clip: match the project canvas to the video instead of forcing
        // a portrait frame with huge black bars around a landscape clip.
        if (s.project.clips.isEmpty &&
            info != null &&
            info.width > 0 &&
            info.height > 0) {
          // Keep projects light: cap the long side at 1920.
          var w = info.width;
          var h = info.height;
          final longSide = w > h ? w : h;
          if (longSide > 1920) {
            final ratio = 1920 / longSide;
            w = (w * ratio).round();
            h = (h * ratio).round();
          }
          w = (w ~/ 2) * 2;
          h = (h ~/ 2) * 2;
          s.project.canvas = CanvasSettings(width: w, height: h, fps: 30);
          _notice = 'Format du projet adapté à votre vidéo : $w×$h.';
        }
      }
      setState(() => s.project.assets.add(asset));
      final end = asset.durationMs ?? 5000;
      _exec(AddClipCommand(VideoClip(
        id: GraceProject.newId(), assetId: asset.id,
        startMs: 0, endMs: end,
      )));
      // Select the clip we just added so the preview and the tools act on it
      // immediately — no extra tap for a beginner.
      setState(() => _selectedClipIndex = s.project.clips.length - 1);
    } on Exception catch (e) {
      if (mounted) setState(() => _notice = 'Import impossible : $e');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<({int durationMs, int width, int height})?> _probeVideo(
      String path) async {
    try {
      final c = VideoPlayerController.file(File(path));
      await c.initialize();
      final ms = c.value.duration.inMilliseconds;
      final size = c.value.size;
      await c.dispose();
      if (ms <= 0) return null;
      return (
        durationMs: ms,
        width: size.width.round(),
        height: size.height.round(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _session;
    final strings = ref.watch(stringsProvider);
    final g = context.grace;
    if (_booting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (s == null && _bootError == null) {
      // The session can disappear while the editor stays mounted (e.g. the
      // library's "Voir tout"). Reload it instead of showing a dead screen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _booting) return;
        setState(() => _booting = true);
        _ensureSession();
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_bootError != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_bootError ?? strings.errorGeneric,
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _booting = true;
                      _bootError = null;
                    });
                    _ensureSession();
                  },
                  icon: const Icon(Icons.refresh_outlined),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (s == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final p = s.project;
    final profiles = ExportProfile.supportedBy(DeviceCapabilities.fallback);
    final canvasProfile = ExportProfile.forCanvas(p.canvas.width, p.canvas.height);
    final activeProfile = (_profile != null && profiles.contains(_profile))
        ? _profile!
        : (profiles.contains(canvasProfile) ? canvasProfile : profiles.first);
    // A clip is always "active": if the user never tapped one, the first clip
    // is selected so the preview shows the video they just imported.
    final int? activeIndex = _activeClipIndex;
    VideoClip? selected;
    if (activeIndex != null) {
      selected = p.clips[activeIndex];
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
        title: Text(
          p.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
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
          const SizedBox(width: 4),
        ],
      ),
      body: _importing
          ? const _ImportOverlay()
          : Column(
        children: [
          if (_notice != null)
            Container(
              width: double.infinity,
              color: g.elevated,
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_notice!,
                        style: TextStyle(
                            color: g.textSecondary, fontSize: 13)),
                  ),
                  IconButton(
                    tooltip: 'Fermer',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.close, size: 18, color: g.textSecondary),
                    onPressed: () => setState(() => _notice = null),
                  ),
                ],
              ),
            ),
          // Preview area: fitted to the real canvas ratio so what you see is
          // exactly what gets exported (no misleading black bars).
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(GraceSpacing.m),
              child: Center(
                child: AspectRatio(
                  aspectRatio: p.canvas.width / p.canvas.height,
                  child: Container(
                    decoration: BoxDecoration(
                      color: p.clips.isEmpty ? g.elevated : Colors.black,
                      border: Border.all(color: g.border),
                      borderRadius: BorderRadius.circular(GraceRadius.l),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildPreview(p, selected, selectedAsset, g),
                        if (p.clips.length > 1 && activeIndex != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Partie ${activeIndex + 1} sur ${p.clips.length}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11),
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
          // Timeline with real thumbnails.
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: GraceSpacing.m),
            child: p.clips.isEmpty
                ? Center(
                    child: OutlinedButton.icon(
                      onPressed: _importing ? null : _importMenu,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Importer une vidéo'),
                    ),
                  )
                : ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: p.clips.length + 1,
                    onReorderItem: (oldI, newI) {
                      if (oldI >= p.clips.length) return;
                      final target = newI.clamp(0, p.clips.length - 1);
                      _exec(MoveClipCommand(p.clips[oldI].id, target));
                    },
                    itemBuilder: (c, i) {
                      if (i == p.clips.length) {
                        // Always-visible "add" tile: a beginner must never
                        // wonder how to put a second clip on the timeline.
                        return GestureDetector(
                          key: const ValueKey('timeline_add'),
                          onTap: _importing ? null : _importMenu,
                          child: Container(
                            width: 76,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: g.elevated,
                              border: Border.all(color: g.border),
                              borderRadius:
                                  BorderRadius.circular(GraceRadius.m),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: g.textSecondary),
                                const SizedBox(height: 4),
                                Text('Ajouter',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: g.textSecondary)),
                              ],
                            ),
                          ),
                        );
                      }
                      final clip = p.clips[i];
                      MediaAsset? asset;
                      for (final a in p.assets) {
                        if (a.id == clip.assetId) asset = a;
                      }
                      final sel = activeIndex == i;
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
                                  '${(clip.durationMs / 1000).toStringAsFixed(1).replaceAll('.', ',')}s · ×${clip.speed.toStringAsFixed(1).replaceAll('.', ',')}',
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
          // Tool grid: every action visible at once, no hidden swipe.
          Padding(
            padding: const EdgeInsets.fromLTRB(
                GraceSpacing.m, 0, GraceSpacing.m, GraceSpacing.s),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
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
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(const SnackBar(
                          content: Text('Vidéo coupée en deux.'),
                          duration: Duration(seconds: 2),
                        ));
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
                    onTap: _textSheet),
              ],
            ),
          ),
          // Export bar. The SafeArea keeps the controls above the system
          // navigation bar (gesture or 3-button) while the surface still
          // runs to the bottom edge.
          Container(
            decoration: BoxDecoration(
              color: g.surface,
              border: Border(top: BorderSide(color: g.border)),
            ),
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: GraceSpacing.m),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    GraceSpacing.m, GraceSpacing.s, GraceSpacing.m, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ExportProfile>(
                        initialValue: activeProfile,
                        decoration: const InputDecoration(
                            labelText: 'Qualité',
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
                          : () => context.push('/export/${p.id}',
                              extra: activeProfile),
                      icon: const Icon(Icons.save_alt),
                      label: Text(strings.export),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _trimSheet() async {
    final s = ref.read(editorSessionProvider);
    final idx = _activeClipIndex;
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
        builder: (c, setB) {
          final tooShort = end - start < 500;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Couper le clip',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Gardez seulement la partie que vous voulez.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.grace.textSecondary)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ValueBox(
                            label: 'Début',
                            value: '${(start / 1000).toStringAsFixed(1).replaceAll('.', ',')} s'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ValueBox(
                            label: 'Fin',
                            value: '${(end / 1000).toStringAsFixed(1).replaceAll('.', ',')} s'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ValueBox(
                            label: 'Durée',
                            value:
                                '${((end - start) / 1000).toStringAsFixed(1).replaceAll('.', ',')} s',
                            strong: true),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: RangeValues(start, end),
                    max: maxMs,
                    min: 0,
                    divisions: (maxMs / 100).round().clamp(1, 600),
                    labels: RangeLabels(
                      '${(start / 1000).toStringAsFixed(1).replaceAll('.', ',')}s',
                      '${(end / 1000).toStringAsFixed(1).replaceAll('.', ',')}s',
                    ),
                    onChanged: (v) => setB(() {
                      start = v.start;
                      end = v.end;
                    }),
                  ),
                  if (tooShort)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('Il faut au moins 0,5 seconde.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              color: context.grace.destructive)),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed:
                              tooShort ? null : () => Navigator.pop(c, true),
                          child: Text(tooShort ? 'Trop court' : 'Couper'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (ok == true) {
      _exec(TrimClipCommand(clip.id,
          newStartMs: start.round(), newEndMs: end.round()));
    }
  }

  /// Text layers are shown on every clip and baked into the exported file —
  /// no "fake" text tool that only decorates the project JSON.
  Future<void> _textSheet() async {
    final s = ref.read(editorSessionProvider);
    if (s == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (c) => _TextSheet(
        project: s.project,
        onChanged: () {
          if (!mounted) return;
          setState(() {});
          _persist();
        },
      ),
    );
  }

  Future<void> _speedVolumeSheet() async {
    final s = ref.read(editorSessionProvider);
    final idx = _activeClipIndex;
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
                Text('Vitesse : ×${speed.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Text('Visible dans l’aperçu, pas encore enregistré dans le fichier.',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Slider(
                    value: speed, min: 0.5, max: 2.0, divisions: 6,
                    label: '×${speed.toStringAsFixed(2).replaceAll('.', ',')}',
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
    final idx = _activeClipIndex;
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
                Text('Luminosité : ${brightness.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Text('Visible dans l’aperçu, pas encore enregistré dans le fichier.',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Slider(
                    value: brightness, min: -0.5, max: 0.5, divisions: 20,
                    onChanged: (v) => setB(() => brightness = v)),
                Text('Contraste : ${contrast.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                    value: contrast, min: 0.5, max: 1.5, divisions: 20,
                    onChanged: (v) => setB(() => contrast = v)),
                Text('Saturation : ${saturation.toStringAsFixed(2).replaceAll('.', ',')}',
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

    // Text layers are composited over the frame exactly where the export puts
    // them (bottom centre), so the preview never lies about the result.
    Widget withText(Widget child) {
      final hasSubtitles = p.subtitles.isNotEmpty;
      if (p.texts.isEmpty) return child;
      return Stack(
        fit: StackFit.expand,
        children: [
          child,
          LayoutBuilder(
            builder: (context, constraints) {
              // Match the export geometry: the text block is anchored to the
              // bottom, above the subtitle band when there is one.
              final frameW = constraints.maxWidth;
              final fontSize = (frameW * 0.055).clamp(12.0, 64.0);
              return Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    frameW * 0.06,
                    0,
                    frameW * 0.06,
                    // The export anchors the whole text bitmap (padding
                    // included) at 8% / 15%; add the same padding here so the
                    // visible glyphs land at the same height.
                    constraints.maxHeight * (hasSubtitles ? 0.15 : 0.08) +
                        fontSize * 0.4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final t in p.texts.skip(
                          p.texts.length > 4 ? p.texts.length - 4 : 0))
                        Padding(
                          padding: EdgeInsets.only(top: fontSize * 0.2),
                          child: Text(
                            t.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: fontSize,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                    color: Colors.black87,
                                    blurRadius: 8,
                                    offset: Offset(0, 1)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    if (asset != null &&
        asset.kind == MediaKind.video &&
        File(asset.path).existsSync()) {
      var offsetMs = 0;
      final clipIndex = clip == null ? -1 : p.clips.indexOf(clip);
      for (var i = 0; i < clipIndex; i++) {
        offsetMs += p.clips[i].endMs - p.clips[i].startMs;
      }
      return withText(applyEffects(_PreviewPlayer(
        key: ValueKey(asset.id),
        path: asset.path,
        cues: p.subtitles,
        clipOffsetMs: offsetMs,
        subtitleStyle: p.subtitleStyle,
      )));
    }
    if (asset != null &&
        asset.kind == MediaKind.image &&
        File(asset.path).existsSync()) {
      return withText(applyEffects(Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(asset.path), fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Center(child: Icon(Icons.broken_image_outlined))),
        ],
      )));
    }
    // Empty state.
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_outlined, size: 56, color: g.textSecondary),
          const SizedBox(height: 8),
          Text('Importez une vidéo pour commencer',
              textAlign: TextAlign.center,
              style: TextStyle(color: g.textSecondary, fontSize: 15)),
          const SizedBox(height: 4),
          Text('Format ${p.canvas.width}×${p.canvas.height}',
              style: TextStyle(color: g.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

/// Self-contained video preview with play/pause.
class _PreviewPlayer extends StatefulWidget {
  const _PreviewPlayer({
    super.key,
    required this.path,
    this.cues = const [],
    this.clipOffsetMs = 0,
    this.subtitleStyle = 'classic',
  });
  final String path;
  final List<SubtitleCue> cues;
  final int clipOffsetMs;
  final String subtitleStyle;

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
      onTap: () {
        if (!mounted) return;
        if (c.value.isPlaying) {
          c.pause();
        } else {
          c.play();
        }
        setState(() {});
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final frameW = constraints.maxWidth;
          final frameH = constraints.maxHeight;
          final subFontSize = (frameW * 0.045).clamp(9.0, 48.0);
          return Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                    width: c.value.size.width,
                    height: c.value.size.height,
                    child: VideoPlayer(c)),
              ),
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: c,
                builder: (context, value, _) {
                  final ms =
                      widget.clipOffsetMs + value.position.inMilliseconds;
                  String? active;
                  for (final cue in widget.cues) {
                    if (ms >= cue.startMs && ms < cue.endMs) {
                      active = cue.text;
                      break;
                    }
                  }
                  if (active == null) return const SizedBox.shrink();
                  return Positioned(
                    left: frameW * 0.03,
                    right: frameW * 0.03,
                    bottom: frameH * 0.035,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: subFontSize * 0.55,
                            vertical: subFontSize * 0.22),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(subFontSize * 0.3),
                        ),
                        child: Text(
                          active,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: subFontSize,
                            height: 1.2,
                            fontWeight: widget.subtitleStyle == 'classic'
                                ? FontWeight.w500
                                : FontWeight.w800,
                            shadows: widget.subtitleStyle == 'outline'
                                ? const [
                                    Shadow(color: Colors.black, blurRadius: 3),
                                    Shadow(
                                        color: Colors.black,
                                        blurRadius: 3,
                                        offset: Offset(1, 1)),
                                    Shadow(
                                        color: Colors.black,
                                        blurRadius: 3,
                                        offset: Offset(-1, -1)),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (!c.value.isPlaying)
                const Center(
                  child: Icon(Icons.play_circle_outline,
                      color: Colors.white, size: 64),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Explicit feedback while a picked file is copied out of the picker cache:
/// a long 4K clip can take a few seconds and silence feels broken.
class _ImportOverlay extends StatelessWidget {
  const _ImportOverlay();

  @override
  Widget build(BuildContext context) {
    final g = context.grace;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 3)),
          const SizedBox(height: 16),
          Text('Importation…',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: g.textPrimary)),
          const SizedBox(height: 4),
          Text('Votre fichier est copié sur votre téléphone.',
              style: TextStyle(fontSize: 13, color: g.textSecondary)),
        ],
      ),
    );
  }
}

/// Bottom sheet that owns its [TextEditingController]. The controller must
/// outlive the sheet's exit animation: disposing it as soon as the route
/// future completed made Flutter assert ("used after being disposed") and
/// flashed a red error screen while the sheet closed.
class _TextSheet extends StatefulWidget {
  const _TextSheet({required this.project, required this.onChanged});

  final GraceProject project;
  final VoidCallback onChanged;

  @override
  State<_TextSheet> createState() => _TextSheetState();
}

class _TextSheetState extends State<_TextSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {
      widget.project.texts
          .add(TextLayer(id: GraceProject.newId(), text: text));
    });
    widget.onChanged();
    FocusScope.of(context).unfocus();
  }

  void _remove(TextLayer layer) {
    setState(() => widget.project.texts.remove(layer));
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final g = context.grace;
    final p = widget.project;
    final canAdd = _controller.text.trim().isNotEmpty;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Texte sur la vidéo',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Il s’affiche en bas de l’image, sur toute la vidéo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: g.textSecondary)),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration:
                      const InputDecoration(hintText: 'Ex. : Bonjour à tous'),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _add(),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: canAdd ? _add : null,
                  child: const Text('Ajouter'),
                ),
                if (p.texts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Textes ajoutés',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: g.textPrimary)),
                  ),
                  for (final t in List<TextLayer>.from(p.texts))
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.text,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        tooltip: 'Supprimer ce texte',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _remove(t),
                      ),
                    ),
                ],
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ),
        ),
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
    final g = context.grace;
    final active = enabled && onTap != null;
    return SizedBox(
      width: 86,
      child: Material(
        color: active ? g.surface : g.elevated,
        borderRadius: BorderRadius.circular(GraceRadius.m),
        child: InkWell(
          onTap: active ? onTap : null,
          borderRadius: BorderRadius.circular(GraceRadius.m),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 20,
                    color: active ? g.primary : g.textSecondary),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: active ? g.textPrimary : g.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small labelled value used by the edit sheets ("Début 0,0 s").
class _ValueBox extends StatelessWidget {
  const _ValueBox({
    required this.label,
    required this.value,
    this.strong = false,
  });
  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final g = context.grace;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: g.elevated,
        borderRadius: BorderRadius.circular(GraceRadius.m),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: g.textSecondary)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
                color: g.textPrimary,
              )),
        ],
      ),
    );
  }
}
