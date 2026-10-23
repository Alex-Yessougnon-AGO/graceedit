/// Export screen: validate -> render plan -> native Media3 job ->
/// progress (cancellable) -> verify -> done. Every failure is explicit
/// with retry; nothing is ever faked.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/platform/capabilities.dart';
import '../../core/services/export_service.dart';
import '../../core/state/providers.dart';
import '../../core/models/grace_project.dart';
import '../../theme/tokens.dart';

final exportServiceProvider =
    Provider<ExportService>((ref) => ExportService());

/// The native engine reports raw technical strings ("Muxer error",
/// "Release timed out"). They mean nothing to a beginner, so the UI always
/// speaks human French; the raw text is kept in the debug log.
String _friendlyExportError(String? raw) {
  final msg = (raw ?? '').trim();
  final lower = msg.toLowerCase();
  if (lower.contains('cancel') || lower.contains('annul')) {
    return 'Création annulée.';
  }
  if (lower.contains('space') ||
      lower.contains('storage') ||
      lower.contains('espace') ||
      lower.contains('no space')) {
    return 'Mémoire insuffisante. Libérez de l’espace, puis réessayez.';
  }
  if (lower.contains('permission') ||
      lower.contains('accès') ||
      lower.contains('refus')) {
    return 'Accès refusé. Vérifiez les autorisations, puis réessayez.';
  }
  return 'La création a échoué. Réessayez ; si cela se reproduit, '
      'choisissez une qualité plus basse.';
}

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});
  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  double _progress = 0;
  bool _running = false;
  bool _done = false;
  bool _saving = false;
  bool _saved = false;
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
      _saved = false;
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
            debugPrint('Export natif en échec : ${status.error}');
            setState(() => _error = _friendlyExportError(status.error));
          }
        } else if (status.state == NativeExportState.cancelled) {
          if (mounted) {
            setState(() => _error = 'Création annulée.');
          }
        }
      }
    } on StateError catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      debugPrint('Export en échec : $e');
      if (mounted) setState(() => _error = _friendlyExportError(e.toString()));
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  Future<void> _saveToGallery() async {
    final path = ref.read(exportServiceProvider).lastOutputPath;
    if (path == null) return;
    setState(() => _saving = true);
    final uri = await ref.read(exportServiceProvider).saveToGallery(path);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saved = uri != null;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        uri != null
            ? 'Vidéo enregistrée dans votre galerie.'
            : 'Galerie indisponible sur cet appareil — utilisez « Partager ».',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final g = context.grace;
    final session = ref.watch(editorSessionProvider);
    final profile = (GoRouterState.of(context).extra as ExportProfile?) ??
        (session != null
            ? ExportProfile.forCanvas(
                session.project.canvas.width, session.project.canvas.height)
            : ExportProfile.all[1]);
    final clipCount = session?.project.clips.length ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Exporter')),
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
            Text('Vitesse, volume et filtres restent dans l’aperçu : '
                'ils ne sont pas encore enregistrés dans le fichier.',
                style: TextStyle(color: g.textSecondary, fontSize: 13)),
            const SizedBox(height: GraceSpacing.l),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _done ? 1 : (_running ? _progress : 0),
                minHeight: 8,
                backgroundColor: g.elevated,
                color: g.primary,
              ),
            ),
            const SizedBox(height: GraceSpacing.s),
            Text(
              _done
                  ? 'Votre vidéo est prête ✔'
                  : _running
                      ? 'Création en cours… ${(_progress * 100).round()} %'
                      : clipCount > 0
                          ? 'Prêt : $clipCount '
                              '${clipCount > 1 ? 'vidéos à assembler' : 'vidéo à assembler'}.'
                          : 'Ajoutez au moins une vidéo dans l’éditeur.',
              style: TextStyle(color: g.textSecondary),
            ),
            if (_done) ...[
              const SizedBox(height: GraceSpacing.m),
              _OutputSummary(
                path: ref.read(exportServiceProvider).lastOutputPath,
                g: g,
              ),
            ],
            if (!_done && session != null) ...[
              const SizedBox(height: GraceSpacing.m),
              _ProjectSummary(project: session.project, g: g),
            ],
            if (_error != null) ...[
              const SizedBox(height: GraceSpacing.m),
              Text(_error!, style: TextStyle(color: g.destructive)),
            ],
            const Spacer(),
            if (_running)
              OutlinedButton.icon(
                onPressed: () async {
                  _stream = null; // stop listening to progress UI
                  final svc = ref.read(exportServiceProvider);
                  final id = svc.currentJobId;
                  if (id != null) await svc.cancel(id); // stop native job
                  if (mounted) {
                    setState(() {
                      _running = false;
                      _error = 'Création annulée.';
                    });
                  }
                },
                icon: const Icon(Icons.stop_outlined),
                label: const Text('Arrêter'),
              )
            else if (!_done)
              FilledButton.icon(
                onPressed: () => _start(profile),
                icon: const Icon(Icons.movie_creation_outlined),
                label: Text(_error != null ? 'Réessayer' : 'Créer ma vidéo'),
              ),
            if (_done) ...[
              const SizedBox(height: GraceSpacing.s),
              FilledButton.icon(
                onPressed: (_saving || _saved) ? null : _saveToGallery,
                icon: Icon(_saved
                    ? Icons.check_circle_outline
                    : Icons.download_outlined),
                label: Text(_saved
                    ? 'Enregistrée dans la galerie'
                    : 'Enregistrer dans la galerie'),
              ),
              const SizedBox(height: GraceSpacing.s),
              OutlinedButton.icon(
                onPressed: () {
                  final path =
                      ref.read(exportServiceProvider).lastOutputPath;
                  if (path != null) {
                    SharePlus.instance.share(ShareParams(
                      files: [XFile(path)],
                      text: 'Ma vidéo GraceEdit',
                    ));
                  }
                },
                icon: const Icon(Icons.ios_share),
                label: const Text('Partager la vidéo'),
              ),
              const SizedBox(height: GraceSpacing.s),
              TextButton(
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

/// What is about to be assembled, in plain language. Fills the screen with
/// useful reassurance instead of empty space: how many parts, how long, and
/// which overlays will be baked in.
class _ProjectSummary extends StatelessWidget {
  const _ProjectSummary({required this.project, required this.g});
  final GraceProject project;
  final GraceColors g;

  String _duration(int ms) {
    final s = (ms / 1000).round();
    if (s < 60) return '$s s';
    final m = s ~/ 60;
    final r = s % 60;
    return r == 0 ? '$m min' : '$m min ${r.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final clips = project.clips.length;
    final texts = project.texts.length;
    final cues = project.subtitles.length;
    final ratio = project.canvas.width >= project.canvas.height
        ? 'Paysage'
        : 'Portrait';
    final rows = <(IconData, String)>[
      (
        Icons.movie_outlined,
        clips > 1 ? '$clips parties · ${_duration(project.totalDurationMs)}' : '1 partie · ${_duration(project.totalDurationMs)}'
      ),
      (
        Icons.title,
        texts == 0
            ? 'Aucun texte'
            : texts == 1
                ? '1 texte à l’écran'
                : '$texts textes à l’écran'
      ),
      (
        Icons.subtitles_outlined,
        cues == 0
            ? 'Aucun sous-titre'
            : cues == 1
                ? '1 réplique sous-titrée'
                : '$cues répliques sous-titrées'
      ),
      (Icons.aspect_ratio, '$ratio · ${project.canvas.width}×${project.canvas.height}'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: g.elevated,
        borderRadius: BorderRadius.circular(GraceRadius.m),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Résumé',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: g.textPrimary)),
          const SizedBox(height: 10),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(row.$1, size: 18, color: g.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(row.$2,
                        style: TextStyle(
                            fontSize: 14, color: g.textPrimary)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Concrete proof for the user: the file name, its real size, and where it
/// went. No vague "export terminé" without a traceable artifact.
class _OutputSummary extends StatelessWidget {
  const _OutputSummary({required this.path, required this.g});
  final String? path;
  final GraceColors g;

  @override
  Widget build(BuildContext context) {
    final file = path == null ? null : File(path!);
    final exists = file != null && file.existsSync();
    final sizeMb = exists ? file.lengthSync() / (1024 * 1024) : 0.0;
    final name = path?.split('/').last ?? '';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: g.elevated,
        borderRadius: BorderRadius.circular(GraceRadius.m),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exists ? 'Vidéo créée' : 'Fichier introuvable',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: g.textPrimary)),
          const SizedBox(height: 4),
          Text(name,
              style: TextStyle(fontSize: 12, color: g.textSecondary)),
          if (exists) ...[
            Text('${sizeMb.toStringAsFixed(1).replaceAll('.', ',')} Mo',
                style: TextStyle(fontSize: 12, color: g.textSecondary)),
            const SizedBox(height: 6),
            Text('« Enregistrer dans la galerie » la garde dans votre '
                'téléphone (album GraceEdit).',
                style: TextStyle(fontSize: 12, color: g.textSecondary)),
          ],
        ],
      ),
    );
  }
}
