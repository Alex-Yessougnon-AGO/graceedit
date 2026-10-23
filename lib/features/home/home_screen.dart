import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/app_providers.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/grace_ui.dart';

/// Écran HOM-01 Accueil.
/// Permet de reprendre le dernier travail ou d'en commencer un nouveau.
/// Deux variantes : avec projets (HOM-01A) ou sans (HOM-01B).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsControllerProvider);

    return Scaffold(
      body: Center(
        child: Text(
          'HOM-01 Accueil\n'
          'Variante A: avec projets\n'
          'Variante B: aucun projet',
          style: const TextStyle(color: Colors.black87),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/import/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}