/// Shared bottom navigation (Home design): Accueil, Bibliothèque,
/// central Create FAB, Profil. Editor/Export stay full-workspace.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/grace_project.dart';
import '../../core/state/providers.dart';
import '../../theme/tokens.dart';

class GraceNav extends ConsumerWidget {
  const GraceNav({super.key, required this.index});
  /// 0 = Accueil, 1 = Bibliothèque, 3 = Profil (2 = FAB Créer).
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = context.grace;
    return BottomAppBar(
      color: g.surface,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Item(
            icon: Icons.home_outlined, activeIcon: Icons.home,
            label: 'Accueil', selected: index == 0,
            onTap: () => context.go('/'),
          ),
          _Item(
            icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library,
            label: 'Bibliothèque', selected: index == 1,
            onTap: () => context.go('/assets'),
          ),
          // Center FAB
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FloatingActionButton(
              backgroundColor: g.primary,
              foregroundColor: g.onPrimary,
              tooltip: 'Créer',
              onPressed: () => showCreateSheet(context, ref),
              child: const Icon(Icons.add, semanticLabel: 'Créer'),
            ),
          ),
          _Item(
            icon: Icons.person_outlined, activeIcon: Icons.person,
            label: 'Profil', selected: index == 3,
            onTap: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }

  /// Shared create sheet: video or poster. Used by FAB and create cards.
  static Future<void> showCreateSheet(BuildContext context, WidgetRef ref) async {
    final kind = await showModalBottomSheet<ProjectKind>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Nouvelle vidéo'),
              onTap: () => Navigator.pop(c, ProjectKind.video),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Nouvelle affiche'),
              onTap: () => Navigator.pop(c, ProjectKind.poster),
            ),
          ],
        ),
      ),
    );
    if (kind == null || !context.mounted) return;
    final repo = ref.read(projectRepositoryProvider);
    final name = kind == ProjectKind.video ? 'Nouvelle vidéo' : 'Nouvelle affiche';
    final p = GraceProject(name: name, kind: kind);
    await repo.save(p);
    await ref.read(projectsProvider.notifier).refresh();
    ref.read(editorSessionProvider.notifier).state = EditorSession(p);
    if (context.mounted) context.push('/editor/${p.id}');
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon, required this.activeIcon, required this.label,
    required this.selected, required this.onTap,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = context.grace;
    final color = selected ? g.primary : g.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? activeIcon : icon, color: color, semanticLabel: label),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
