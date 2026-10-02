/// Subtitle track editor: structured cues (not just visual text).
/// Add / edit / delete / retime + style choice. All persisted.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/grace_project.dart';
import '../../core/state/providers.dart';
import '../../theme/tokens.dart';

const subtitleStyles = ['classic', 'bold', 'outline'];

class SubtitlesScreen extends ConsumerStatefulWidget {
  const SubtitlesScreen({super.key});
  @override
  ConsumerState<SubtitlesScreen> createState() => _SubtitlesScreenState();
}

class _SubtitlesScreenState extends ConsumerState<SubtitlesScreen> {
  Future<void> _persist() async {
    final s = ref.read(editorSessionProvider);
    if (s == null) return;
    await ref.read(projectRepositoryProvider).save(s.project);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(editorSessionProvider);
    final g = context.grace;
    if (session == null) {
      return Scaffold(
          appBar: AppBar(), body: const Center(child: Text('Aucun projet.')));
    }
    final p = session.project;
    final cues = [...p.subtitles]..sort((a, b) => a.startMs.compareTo(b.startMs));
    return Scaffold(
      appBar: AppBar(title: const Text('Sous-titres')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                const Text('Style',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: [
                      for (final s in subtitleStyles)
                        ButtonSegment(value: s, label: Text(s)),
                    ],
                    selected: {p.subtitleStyle},
                    onSelectionChanged: (sel) {
                      setState(() => p.subtitleStyle = sel.first);
                      _persist();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: cues.isEmpty
                ? Center(
                    child: Text(
                      'Aucun sous-titre.\nAjoutez la première réplique ci-dessous.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: g.textSecondary, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    itemCount: cues.length,
                    itemBuilder: (c, i) {
                      final cue = cues[i];
                      return Dismissible(
                        key: ValueKey(cue.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: g.destructive,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white),
                        ),
                        onDismissed: (_) {
                          setState(() => p.subtitles
                              .removeWhere((x) => x.id == cue.id));
                          _persist();
                        },
                        child: ListTile(
                          title: Text(cue.text),
                          subtitle: Text(
                              '${_fmt(cue.startMs)} → ${_fmt(cue.endMs)}'),
                          trailing:
                              const Icon(Icons.edit_outlined, size: 20),
                          onTap: () => _editCue(p, cue),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une réplique'),
                onPressed: () => _editCue(p, null),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int ms) {
    final s = ms ~/ 1000;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _editCue(GraceProject p, SubtitleCue? existing) async {
    final textCtrl = TextEditingController(text: existing?.text ?? '');
    double start = ((existing?.startMs ?? 0) / 1000).toDouble();
    double end = ((existing?.endMs ?? 3000) / 1000).toDouble();
    final maxBound = (p.totalDurationMs > 0 ? p.totalDurationMs : 60000) / 1000.0;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: Text(existing == null ? 'Nouvelle réplique' : 'Modifier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: textCtrl,
                  autofocus: true,
                  decoration:
                      const InputDecoration(hintText: 'Texte affiché')),
              const SizedBox(height: 12),
              Text('Début : ${start.toStringAsFixed(1)}s'),
              Slider(
                  value: start.clamp(0, maxBound),
                  max: maxBound,
                  divisions: (maxBound * 2).round(),
                  label: '${start.toStringAsFixed(1)}s',
                  onChanged: (v) => setD(() {
                        start = v;
                        if (end < start) end = start + 1;
                      })),
              Text('Fin : ${end.toStringAsFixed(1)}s'),
              Slider(
                  value: end.clamp(0, maxBound),
                  max: maxBound,
                  divisions: (maxBound * 2).round(),
                  label: '${end.toStringAsFixed(1)}s',
                  onChanged: (v) => setD(() => end = v)),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || textCtrl.text.trim().isEmpty) return;
    setState(() {
      if (existing == null) {
        p.subtitles.add(SubtitleCue(
          id: GraceProject.newId(),
          text: textCtrl.text.trim(),
          startMs: (start * 1000).round(),
          endMs: (end * 1000).round().clamp(
              (start * 1000).round() + 500, 1 << 31),
        ));
      } else {
        p.subtitles.removeWhere((x) => x.id == existing.id);
        p.subtitles.add(SubtitleCue(
          id: existing.id,
          text: textCtrl.text.trim(),
          startMs: (start * 1000).round(),
          endMs: (end * 1000).round().clamp(
              (start * 1000).round() + 500, 1 << 31),
        ));
      }
      p.touch();
    });
    _persist();
  }
}
