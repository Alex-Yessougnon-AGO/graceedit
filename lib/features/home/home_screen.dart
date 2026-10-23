/// Home screen: recent projects, create entry points.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/models/grace_project.dart';
import '../../core/state/providers.dart';
import '../../theme/tokens.dart';
import '../library/thumb_widget.dart';
import '../nav/grace_nav.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final projects = ref.watch(projectsProvider);
    final g = context.grace;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appName,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
      ),
      bottomNavigationBar: const GraceNav(index: 0),
      body: ListView(
        padding: const EdgeInsets.all(GraceSpacing.m),
        children: [
          Text(strings.homeTitle,
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w700, color: g.textPrimary)),
          const SizedBox(height: 4),
          Text(strings.homeSubtitle,
              style: TextStyle(fontSize: 15, color: g.textSecondary)),
          const SizedBox(height: GraceSpacing.l),
          _CreateCard(
            icon: Icons.add,
            label: strings.newVideo,
            subtitle: strings.locale == AppLocale.fr
                ? 'Importer une vidéo, puis la couper et ajouter du texte'
                : 'Import a video, then trim it and add text',
            onTap: () => GraceNav.createVideo(context, ref),
          ),
          const SizedBox(height: GraceSpacing.l),
          Text(strings.recentProjects,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: g.textPrimary)),
          const SizedBox(height: GraceSpacing.s),
          projects.when(
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator())),
            error: (e, _) => _ErrorBox(
                message: strings.errorGeneric,
                onRetry: () => ref.read(projectsProvider.notifier).refresh()),
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(strings.emptyProjects,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: g.textSecondary, fontSize: 15)),
                );
              }
              return Column(
                children: [
                  for (final p in list)
                    _ProjectTile(
                      project: p,
                      onOpen: () => _open(context, ref, p),
                      onDelete: () => _deleteProject(context, ref, p),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref, GraceProject p) {
    ref.read(editorSessionProvider.notifier).state = EditorSession(p);
    context.push('/editor/${p.id}');
  }

  Future<void> _deleteProject(
      BuildContext context, WidgetRef ref, GraceProject p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer ce projet ?'),
        content: Text('« ${p.name} » sera retiré de la liste. '
            'Cette action est définitive.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Garder')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok != true) return;
    // Never delete a media file another project still uses.
    final all = ref.read(projectsProvider).value ?? const <GraceProject>[];
    final stillUsed = <String>{};
    for (final other in all) {
      if (other.id == p.id) continue;
      for (final a in other.assets) {
        stillUsed.add(a.path);
      }
    }
    await ref.read(projectsProvider.notifier).remove(p.id);
    for (final a in p.assets) {
      await ref.read(thumbnailServiceProvider).invalidateAsset(a.id);
      if (stillUsed.contains(a.path)) continue;
      try {
        final f = File(a.path);
        if (await f.exists()) await f.delete();
      } catch (_) {
        // A locked or already-deleted file is not worth an error dialog.
      }
    }
  }
}

class _CreateCard extends StatelessWidget {
  const _CreateCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = context.grace;
    return Material(
      color: g.surface,
      borderRadius: BorderRadius.circular(GraceRadius.l),
      child: InkWell(
        borderRadius: BorderRadius.circular(GraceRadius.l),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(GraceSpacing.l),
          decoration: BoxDecoration(
            border: Border.all(color: g.border),
            borderRadius: BorderRadius.circular(GraceRadius.l),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: g.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 26, color: g.onPrimary),
              ),
              const SizedBox(width: GraceSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: g.textPrimary)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: TextStyle(
                              fontSize: 13, color: g.textSecondary)),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: g.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({
    required this.project,
    required this.onOpen,
    required this.onDelete,
  });
  final GraceProject project;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final g = context.grace;
    return Card(
      color: g.surface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GraceRadius.m),
        side: BorderSide(color: g.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(GraceRadius.m),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 80, height: 60,
                child: Stack(
                  children: [
                    GraceThumb(
                      assetId: 'project-${project.id}',
                      sourcePath: _thumbSource,
                      kind: _thumbKind,
                      width: 80, height: 60,
                    ),
                    if (project.clips.isNotEmpty)
                      Positioned(
                        bottom: 4, right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(project.formatDuration(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: GraceSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.name,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: g.textPrimary)),
                    const SizedBox(height: 4),
                    Text(
                      project.clips.isEmpty
                          ? '${project.canvas.width}×${project.canvas.height} · '
                              '${project.kind == ProjectKind.video ? 'Vidéo' : 'Affiche'}'
                          : '${project.clips.length} ${project.clips.length > 1 ? 'parties' : 'partie'} · ${project.formatDuration()}',
                      style: TextStyle(color: g.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Options du projet',
                icon: Icon(Icons.more_vert, color: g.textSecondary),
                onSelected: (v) {
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (c) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Supprimer le projet'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// First video/image asset backs the tile thumbnail; otherwise icon fallback.
  MediaAsset? get _firstMedia {
    for (final a in project.assets) {
      if (a.kind == MediaKind.video || a.kind == MediaKind.image) return a;
    }
    return null;
  }

  String get _thumbSource => _firstMedia?.path ?? '';
  String get _thumbKind => _firstMedia?.kind.name ?? 'video';
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(message),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: onRetry, child: const Text('Réessayer / Retry')),
      ],
    );
  }
}
