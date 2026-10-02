/// Home screen: recent projects, create entry points.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/models/grace_project.dart';
import '../../core/state/providers.dart';
import '../../theme/tokens.dart';

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
        actions: [
          IconButton(
            tooltip: strings.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
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
          Row(
            children: [
              Expanded(
                child: _CreateCard(
                  icon: Icons.videocam_outlined,
                  label: strings.newVideo,
                  onTap: () => _create(context, ref, ProjectKind.video),
                ),
              ),
              const SizedBox(width: GraceSpacing.m),
              Expanded(
                child: _CreateCard(
                  icon: Icons.image_outlined,
                  label: strings.newPoster,
                  onTap: () => _create(context, ref, ProjectKind.poster),
                ),
              ),
            ],
          ),
          const SizedBox(height: GraceSpacing.l),
          Text(strings.recentProjects,
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w600, color: g.textPrimary)),
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
                    _ProjectTile(project: p, onOpen: () => _open(context, ref, p)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref, ProjectKind kind) async {
    final strings = ref.read(stringsProvider);
    final nameController = TextEditingController(
        text: kind == ProjectKind.video
            ? (strings.locale == AppLocale.fr ? 'Nouvelle vidéo' : 'New video')
            : (strings.locale == AppLocale.fr ? 'Nouvelle affiche' : 'New poster'));
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(strings.create),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(hintText: strings.projectNameHint),
          onSubmitted: (_) => Navigator.pop(c, nameController.text.trim()),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c, nameController.text.trim()),
            child: Text(strings.create),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !context.mounted) return;
    final p = await ref.read(projectsProvider.notifier).create(name: name, kind: kind);
    if (!context.mounted) return;
    _open(context, ref, p);
  }

  void _open(BuildContext context, WidgetRef ref, GraceProject p) {
    ref.read(editorSessionProvider.notifier).state = EditorSession(p);
    context.push('/editor/${p.id}');
  }
}

class _CreateCard extends StatelessWidget {
  const _CreateCard({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: g.primary, semanticLabel: label),
              const SizedBox(height: GraceSpacing.s),
              Text(label,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, color: g.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.project, required this.onOpen});
  final GraceProject project;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final g = context.grace;
    return Card(
      color: g.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GraceRadius.m),
        side: BorderSide(color: g.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: g.elevated,
            borderRadius: BorderRadius.circular(GraceRadius.s),
          ),
          child: Icon(
            project.kind == ProjectKind.video ? Icons.movie_outlined : Icons.image_outlined,
            color: g.textSecondary,
            semanticLabel: project.name,
          ),
        ),
        title: Text(project.name,
            style: TextStyle(fontWeight: FontWeight.w600, color: g.textPrimary)),
        subtitle: Text(
          project.clips.isEmpty
              ? project.canvas.width.toString() +
                  '×${project.canvas.height} · ${project.kind.name}'
              : '${project.clips.length} clips · ${project.formatDuration()}',
          style: TextStyle(color: g.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onOpen,
      ),
    );
  }
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
