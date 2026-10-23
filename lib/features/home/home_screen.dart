import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:graceedit/core/l10n/generated/app_localizations.dart';
import 'package:graceedit/core/ui/grace_ui.dart';

/// Écran HOM-01 Accueil.
/// Permet de reprendre le dernier travail ou d'en commencer un nouveau.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Text(
          'HOM-01 Accueil\n'
          'Projets chargés depuis le repository local',
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