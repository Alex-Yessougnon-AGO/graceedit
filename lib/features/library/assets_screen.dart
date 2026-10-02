/// Asset library: unified view of the open project's assets.
/// Search, preview, delete. Tags/favorites arrive with campaign phase.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/grace_project.dart';
import '../../core/state/providers.dart';
import '../../theme/tokens.dart';
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
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bibliothèque')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Aucun projet ouvert.'),
              const SizedBox(height: 12),
              FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Accueil')),
            ],
          ),
        ),
      );
    }
    final assets = session.project.assets
        .where((a) => _query.isEmpty || a.path.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Bibliothèque')),
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
            child: assets.isEmpty
                ? Center(
                    child: Text('Aucun média importé.',
                        style: TextStyle(color: g.textSecondary)))
                : GridView.builder(
                    padding: const EdgeInsets.all(GraceSpacing.m),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8, mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: assets.length,
                    itemBuilder: (c, i) {
                      final a = assets[i];
                      return GestureDetector(
                        onLongPress: () => _confirmDelete(a),
                        child: Stack(
                          children: [
                            GraceThumb(
                              assetId: a.id, sourcePath: a.path,
                              kind: a.kind.name,
                              width: double.infinity, height: double.infinity,
                            ),
                            Positioned(
                              bottom: 4, left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  a.kind.name,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(MediaAsset a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer cet asset ?'),
        content: Text(a.path.split('/').last),
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
    if (ok == true) {
      final session = ref.read(editorSessionProvider);
      if (session == null) return;
      setState(() {
        session.project.assets.removeWhere((x) => x.id == a.id);
        session.project.clips.removeWhere((cl) => cl.assetId == a.id);
        session.project.touch();
      });
      await ref.read(thumbnailServiceProvider).invalidateAsset(a.id);
      await ref.read(projectRepositoryProvider).save(session.project);
    }
  }
}
