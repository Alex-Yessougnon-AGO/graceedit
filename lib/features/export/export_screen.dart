/// Export screen: validates project, simulates render plan with progress,
/// registers output. Real Media3 Transformer wiring comes in Phase 3 native step.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/platform/capabilities.dart';
import '../../core/state/providers.dart';
import '../../theme/tokens.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});
  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  double _progress = 0;
  bool _running = false;
  bool _done = false;
  String? _error;

  Future<void> _start(ExportProfile profile) async {
    final s = ref.read(editorSessionProvider);
    if (s == null) return;
    if (s.project.clips.isEmpty) {
      setState(() => _error = 'Timeline vide — ajoutez au moins un clip.');
      return;
    }
    setState(() { _running = true; _error = null; _progress = 0; });
    // Simulated render plan (deterministic, cancellable).
    // Replaced by Media3 Transformer in the native export step.
    for (var i = 1; i <= 20; i++) {
      if (!mounted || !_running) return;
      await Future<void>.delayed(const Duration(milliseconds: 120));
      setState(() => _progress = i / 20);
    }
    if (!mounted) return;
    setState(() { _running = false; _done = true; });
  }

  @override
  Widget build(BuildContext context) {
    final g = context.grace;
    final profile = (GoRouterState.of(context).extra as ExportProfile?) ?? ExportProfile.all[1];
    final session = ref.watch(editorSessionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Export')),
      body: Padding(
        padding: const EdgeInsets.all(GraceSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(profile.label,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: g.textPrimary)),
            Text('${profile.width}×${profile.height} · ${profile.fps} fps',
                style: TextStyle(color: g.textSecondary)),
            const SizedBox(height: GraceSpacing.l),
            LinearProgressIndicator(
              value: _done ? 1 : (_running ? _progress : 0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: GraceSpacing.s),
            Text(
              _done
                  ? 'Export terminé ✔ (simulation V1 — câblage Media3 à venir)'
                  : _running
                      ? 'Export en cours… ${(_progress * 100).round()} %'
                      : 'Prêt à exporter ${session?.project.clips.length ?? 0} clips.',
              style: TextStyle(color: g.textSecondary),
            ),
            if (_error != null) ...[
              const SizedBox(height: GraceSpacing.m),
              Text(_error!, style: TextStyle(color: g.destructive)),
            ],
            const Spacer(),
            FilledButton.icon(
              onPressed: _running ? null : () => _start(profile),
              icon: const Icon(Icons.ios_share),
              label: Text(_running ? '…' : 'Exporter'),
            ),
            if (_done) ...[
              const SizedBox(height: GraceSpacing.s),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Retour à l’éditeur'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
