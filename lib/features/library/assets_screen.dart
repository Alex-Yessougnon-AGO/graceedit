/// Asset library: session project assets when an editor session is open,
/// otherwise the global view (all assets across projects).
/// Search, preview, delete (with thumbnail invalidation).
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(editorSessionProvider);
    final g = context.grace;
    if (session != null && !_showAll) {
      return _buildSessionView(session.project);
    }
    final all = ref.watch(allAssetsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliothèque'),
        actions: [
          if (session != null)
            TextButton(
              onPressed: () => setState(() => _showAll = false),
              child: const Text('Mon projet'),
            ),
        ],
      ),
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
              error: (_, _) => const Center(child: Text('Chargement impossible.')),
              data: (items) {
                final shown = items
                    .where((o) =>
                        _query.isEmpty ||
                        o.asset.path.toLowerCase().contains(_query.toLowerCase()) ||
                        o.projectName.toLowerCase().contains(_query.toLowerCase()))
                    .toList();
                if (shown.isEmpty) {
                  return Center(
                      child: Text('Aucune vidéo importée.',
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

  Widget _buildSessionView(GraceProject project) {
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
                onPressed: () => setState(() => _showAll = true),
                child: const Text('Voir tout'),
              ),
            ]),
          ),
          Expanded(
            child: assets.isEmpty
                ? Center(
                    child: Text('Aucune vidéo importée.',
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
                      footnote: _kindLabel(assets[i].kind),
                      onDelete: () => _deleteSession(assets[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSession(MediaAsset a) async {
    final session = ref.read(editorSessionProvider);
    if (session == null) return;
    final used =
        session.project.clips.where((cl) => cl.assetId == a.id).length;
    if (!await _confirm(
      a.path.split('/').last,
      extra: used == 0
          ? null
          : 'Utilisé $used fois dans la vidéo : il sera aussi retiré.',
    )) {
      return;
    }
    setState(() {
      session.project.assets.removeWhere((x) => x.id == a.id);
      session.project.clips.removeWhere((cl) => cl.assetId == a.id);
      session.project.touch();
    });
    await ref.read(thumbnailServiceProvider).invalidateAsset(a.id);
    await ref.read(projectRepositoryProvider).save(session.project);
    await _deleteFileIfUnused(a.path);
    ref.invalidate(allAssetsProvider);
  }

  Future<void> _deleteGlobal(OwnedAsset o) async {
    final repo = ref.read(projectRepositoryProvider);
    final project = await repo.load(o.projectId);
    if (project == null) return;
    final used = project.clips.where((cl) => cl.assetId == o.asset.id).length;
    if (!await _confirm(
      '${o.asset.path.split('/').last}\n(${o.projectName})',
      extra: used == 0
          ? null
          : 'Utilisé $used fois dans la vidéo : il sera aussi retiré.',
    )) {
      return;
    }
    project.assets.removeWhere((x) => x.id == o.asset.id);
    project.clips.removeWhere((cl) => cl.assetId == o.asset.id);
    project.touch();
    await repo.save(project);
    await ref.read(thumbnailServiceProvider).invalidateAsset(o.asset.id);
    await _deleteFileIfUnused(o.asset.path);
    await ref.read(projectsProvider.notifier).refresh();
    ref.invalidate(allAssetsProvider);
  }

  /// Remove the copied media file once no project references it any more.
  Future<void> _deleteFileIfUnused(String path) async {
    final all = await ref.read(projectRepositoryProvider).listAll();
    for (final p in all) {
      if (p.assets.any((x) => x.path == path)) return;
    }
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {
      // A locked or already-deleted file is not worth an error dialog.
    }
  }

  Future<bool> _confirm(String label, {String? extra}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer ce fichier ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            if (extra != null) ...[
              const SizedBox(height: 8),
              Text(extra, style: const TextStyle(fontSize: 13)),
            ],
          ],
        ),
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

  /// Plain French label for the kind badge — never the enum name.
  static String _kindLabel(MediaKind kind) => switch (kind) {
        MediaKind.video => 'Vidéo',
        MediaKind.image => 'Photo',
        MediaKind.audio => 'Audio',
        MediaKind.text => 'Texte',
        MediaKind.subtitle => 'Sous-titre',
      };
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
          // Visible delete affordance: long-press alone is invisible to a
          // beginner.
          Positioned(
            top: 2, right: 2,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onDelete,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.delete_outline,
                      size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
