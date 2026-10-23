/// Shared bottom navigation (Home design): Accueil, Bibliothèque,
/// central Create FAB, Profil. Editor/Export stay full-workspace.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
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
              onPressed: () => createVideo(context, ref),
              child: const Icon(Icons.add, semanticLabel: 'Créer'),
            ),
          ),
          _Item(
            icon: Icons.settings_outlined, activeIcon: Icons.settings,
            label: 'Réglages', selected: index == 3,
            onTap: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }

  /// Creates a video project (with a name) and opens the editor. V1 has no
  /// poster project: offering one would lead to a dead end, so the FAB goes
  /// straight to the only content type that can really be exported.
  static Future<void> createVideo(BuildContext context, WidgetRef ref) async {
    final strings = ref.read(stringsProvider);
    final controller = TextEditingController(text: strings.newVideo);
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(strings.newVideo),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: strings.projectNameHint),
          onSubmitted: (_) => Navigator.pop(c, controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(
                strings.locale == AppLocale.fr ? 'Annuler' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, controller.text.trim()),
            child: Text(strings.create),
          ),
        ],
      ),
    );
    if (name == null || !context.mounted) return;
    final cleanName = name.trim().isEmpty ? strings.newVideo : name.trim();
    final p = await ref
        .read(projectsProvider.notifier)
        .create(name: cleanName, kind: ProjectKind.video);
    if (!context.mounted) return;
    ref.read(editorSessionProvider.notifier).state = EditorSession(p);
    context.push('/editor/${p.id}');
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
