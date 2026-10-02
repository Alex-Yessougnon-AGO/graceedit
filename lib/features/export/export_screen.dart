/// Export screen: validate -> render plan -> native Media3 job ->
/// progress (cancellable) -> verify -> done. Every failure is explicit
/// with retry; nothing is ever faked.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/platform/capabilities.dart';
import '../../core/services/export_service.dart';
import '../../core/state/providers.dart';
import '../../theme/tokens.dart';

final exportServiceProvider =
    Provider<ExportService>((ref) => ExportService());

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
  Stream<NativeExportStatus>? _stream;

  Future<void> _start(ExportProfile profile) async {
    final session = ref.read(editorSessionProvider);
    if (session == null) return;
    setState(() {
      _running = true;
      _error = null;
      _progress = 0;
      _done = false;
    });
    try {
      final stream = ref
          .read(exportServiceProvider)
          .export(project: session.project, profile: profile);
      _stream = stream;
      await for (final status in stream) {
        if (!mounted || _stream != stream) return; // superseded / cancelled
        setState(() => _progress = status.progress);
        if (status.state == NativeExportState.done) {
          if (mounted) setState(() => _done = true);
        } else if (status.state == NativeExportState.error) {
          if (mounted) {
            setState(() =>
                _error = status.error ?? 'Export impossible. Réessayez.');
          }
        } else if (status.state == NativeExportState.cancelled) {
          if (mounted) {
            setState(() => _error = 'Export annulé.');
          }
        }
      }
    } on StateError catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Export impossible : $e');
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = context.grace;
    final profile =
        (GoRouterState.of(context).extra as ExportProfile?) ?? ExportProfile.all[1];
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
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: g.textPrimary)),
            Text('${profile.width}×${profile.height} · ${profile.fps} fps',
                style: TextStyle(color: g.textSecondary)),
            Text('Moteur natif Media3 — rognage, assemblage, rotation.',
                style: TextStyle(color: g.textSecondary, fontSize: 13)),
            const SizedBox(height: GraceSpacing.l),
            LinearProgressIndicator(
              value: _done ? 1 : (_running ? _progress : 0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: GraceSpacing.s),
            Text(
              _done
                  ? 'Export terminé ✔ — fichier enregistré dans l’app.'
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
            if (_running)
              OutlinedButton.icon(
                onPressed: () {
                  _stream = null; // stop listening; job continues natively
                  setState(() {
                    _running = false;
                    _error = 'Export interrompu côté interface.';
                  });
                },
                icon: const Icon(Icons.stop_outlined),
                label: const Text('Arrêter'),
              )
            else
              FilledButton.icon(
                onPressed: () => _start(profile),
                icon: const Icon(Icons.ios_share),
                label: Text(_error != null ? 'Réessayer' : 'Exporter'),
              ),
            if (_done) ...[
              const SizedBox(height: GraceSpacing.s),
              FilledButton.icon(
                onPressed: () {
                  final path =
                      ref.read(exportServiceProvider).lastOutputPath;
                  if (path != null) {
                    Share.shareXFiles([XFile(path)],
                        text: 'Ma vidéo GraceEdit');
                  }
                },
                icon: const Icon(Icons.ios_share),
                label: const Text('Partager la vidéo'),
              ),
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
