/// Asset library: session project assets when an editor session is open,
/// otherwise the global view (all assets across projects).
/// Search, preview, delete (with thumbnail invalidation).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/grace_project.dart';
import '../../core/state/providers.dart';
import '../../theme/tokens.dart';
import '../nav/grace_nav.dart';
import 'thumb_widget.dart';

class AssetsScreen extends ConsumerStatefulWidget {
  const AssetsScreen({super.key});
  @override
  ConsumerState<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends ConsumerState<AssetsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(editorSessionProvider);
    final g = context.grace;
    if (session != null) {
      return _buildSessionView(session.project, isGlobal: false);
    }
    final all = ref.watch(allAssetsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bibliothèque')),
      bottomNavigationBar: const GraceNav(index: 1),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(GraceSpacing.m),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: all.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Chargement impossible.')),
              data: (items) {
                final shown = items
                    .where((o) =>
                        _query.isEmpty ||
                        o.asset.path.toLowerCase().contains(_query.toLowerCase()) ||
                        o.projectName.toLowerCase().contains(_query.toLowerCase()))
                    .toList();
                if (shown.isEmpty) {
                  return Center(
                      child: Text('Aucun média importé.',
                          style: TextStyle(color: g.textSecondary)));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(GraceSpacing.m),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
                  ),
                  itemCount: shown.length,
                  itemBuilder: (c, i) => _Tile(
                    asset: shown[i].asset,
                    footnote: shown[i].projectName,
                    onDelete: () => _deleteGlobal(shown[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionView(GraceProject project, {required bool isGlobal}) {
    final g = context.grace;
    final assets = project.assets
        .where((a) => _query.isEmpty || a.path.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Bibliothèque')),
      bottomNavigationBar: const GraceNav(index: 1),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(GraceSpacing.m),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GraceSpacing.m),
            child: Row(children: [
              Text(project.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ref.read(editorSessionProvider.notifier).state = null;
                  setState(() {});
                },
                child: const Text('Voir tout'),
              ),
            ]),
          ),
          Expanded(
            child: assets.isEmpty
                ? Center(
                    child: Text('Aucun média importé.',
                        style: TextStyle(color: g.textSecondary)))
                : GridView.builder(
                    padding: const EdgeInsets.all(GraceSpacing.m),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
                    ),
                    itemCount: assets.length,
                    itemBuilder: (c, i) => _Tile(
                      asset: assets[i],
                      footnote: assets[i].kind.name,
                      onDelete: () => _deleteSession(assets[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSession(MediaAsset a) async {
    if (!await _confirm(a.path.split('/').last)) return;
    final session = ref.read(editorSessionProvider);
    if (session == null) return;
    setState(() {
      session.project.assets.removeWhere((x) => x.id == a.id);
      session.project.clips.removeWhere((cl) => cl.assetId == a.id);
      session.project.touch();
    });
    await ref.read(thumbnailServiceProvider).invalidateAsset(a.id);
    await ref.read(projectRepositoryProvider).save(session.project);
    ref.invalidate(allAssetsProvider);
  }

  Future<void> _deleteGlobal(OwnedAsset o) async {
    if (!await _confirm('${o.asset.path.split('/').last}\n(${o.projectName})')) {
      return;
    }
    final repo = ref.read(projectRepositoryProvider);
    final project = await repo.load(o.projectId);
    if (project == null) return;
    project.assets.removeWhere((x) => x.id == o.asset.id);
    project.clips.removeWhere((cl) => cl.assetId == o.asset.id);
    project.touch();
    await repo.save(project);
    await ref.read(thumbnailServiceProvider).invalidateAsset(o.asset.id);
    await ref.read(projectsProvider.notifier).refresh();
    ref.invalidate(allAssetsProvider);
  }

  Future<bool> _confirm(String label) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer cet asset ?'),
        content: Text(label),
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
    return ok == true;
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.asset, required this.footnote, required this.onDelete});
  final MediaAsset asset;
  final String footnote;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onDelete,
      child: Stack(
        children: [
          GraceThumb(
            assetId: asset.id, sourcePath: asset.path,
            kind: asset.kind.name,
            width: double.infinity, height: double.infinity,
          ),
          Positioned(
            bottom: 4, left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(footnote,
                  style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}
