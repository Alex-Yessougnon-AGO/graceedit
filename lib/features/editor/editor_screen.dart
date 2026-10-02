/// Simple (beginner) video editor: preview placeholder, timeline, trim/split/delete,
/// text layer, undo/redo, autosave, export profile picker (real capability filter).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/commands/commands.dart';
import '../../core/models/grace_project.dart';
import '../../core/platform/capabilities.dart';
import '../../core/state/providers.dart';
import '../../theme/tokens.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, required this.projectId});
  final String projectId;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  bool _saving = false;
  ExportProfile _profile = ExportProfile.all[1];
  int? _selectedClipIndex;

  EditorSession? get _session => ref.watch(editorSessionProvider);

  Future<void> _persist() async {
    final s = _session;
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
    final s = _session;
    if (s == null) return;
    setState(() => s.commands.execute(s.project, cmd));
    ref.read(projectRepositoryProvider).markDirty(s.project.id);
    _persist();
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
          // Preview area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(GraceSpacing.m),
              decoration: BoxDecoration(
                color: g.surface,
                border: Border.all(color: g.border),
                borderRadius: BorderRadius.circular(GraceRadius.l),
              ),
              child: Center(
                child: p.clips.isEmpty
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.movie_outlined, size: 56, color: g.textSecondary),
                          const SizedBox(height: 8),
                          Text(strings.preview,
                              style: TextStyle(color: g.textSecondary, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            '${p.canvas.width}×${p.canvas.height} · ${p.canvas.fps} fps',
                            style: TextStyle(color: g.textSecondary, fontSize: 13),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_outline, size: 56, color: g.primary),
                          const SizedBox(height: 8),
                          Text('${p.clips.length} clips · ${p.formatDuration()}',
                              style: TextStyle(color: g.textPrimary, fontSize: 16)),
                          if (p.texts.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                p.texts.last.text,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w700),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
          // Timeline
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
                      final selected = _selectedClipIndex == i;
                      return GestureDetector(
                        key: ValueKey(clip.id),
                        onTap: () => setState(() => _selectedClipIndex = i),
                        child: Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: selected ? g.elevated : g.surface,
                            border: Border.all(
                                color: selected ? g.primary : g.border, width: selected ? 2 : 1),
                            borderRadius: BorderRadius.circular(GraceRadius.m),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.movie_creation_outlined, size: 28),
                              const SizedBox(height: 4),
                              Text('${(clip.durationMs / 1000).toStringAsFixed(1)}s',
                                  style: const TextStyle(fontSize: 13)),
                              Text('×${clip.speed}',
                                  style: TextStyle(
                                      fontSize: 12, color: g.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Contextual actions
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(GraceSpacing.m),
            child: Row(
              children: [
                _Action(
                    icon: Icons.add, label: 'Clip',
                    onTap: () {
                      final asset = MediaAsset(
                        id: GraceProject.newId(), kind: MediaKind.video,
                        path: 'local/demo_${DateTime.now().millisecondsSinceEpoch}.mp4',
                        durationMs: 5000, width: 1920, height: 1080,
                      );
                      p.assets.add(asset);
                      _exec(AddClipCommand(VideoClip(
                        id: GraceProject.newId(), assetId: asset.id,
                        startMs: 0, endMs: 5000,
                      )));
                    }),
                _Action(
                    icon: Icons.content_cut, label: strings.split,
                    enabled: _selectedClipIndex != null && p.clips.isNotEmpty,
                    onTap: () {
                      final i = _selectedClipIndex!;
                      if (i >= p.clips.length) return;
                      final clip = p.clips[i];
                      final mid = (clip.startMs + clip.endMs) ~/ 2;
                      _exec(SplitClipCommand(clip.id, mid));
                    }),
                _Action(
                    icon: Icons.delete_outline, label: strings.delete,
                    enabled: _selectedClipIndex != null && p.clips.isNotEmpty,
                    onTap: () {
                      final i = _selectedClipIndex!;
                      if (i >= p.clips.length) return;
                      _exec(RemoveClipCommand(p.clips[i].id));
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
          // Export bar
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
                    initialValue: profiles.contains(_profile) ? _profile : profiles.first,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
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
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap, this.enabled = true});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
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
