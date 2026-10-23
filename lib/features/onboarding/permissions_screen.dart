/// Privacy step: explains, before the first project, that the system picker
/// needs no permission and that nothing leaves the phone. No permission is
/// requested here on purpose — Android asks only when the user films, and a
/// beginner must never be blocked by a wall of scary dialogs.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/tokens.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final g = context.grace;
    return Scaffold(
      appBar: AppBar(title: const Text('Vos fichiers')),
      body: ListView(
        padding: const EdgeInsets.all(GraceSpacing.l),
        children: [
          const SizedBox(height: GraceSpacing.l),
          Icon(Icons.lock_outline, size: 56, color: g.primary),
          const SizedBox(height: GraceSpacing.l),
          Text(
            'Rien ne quitte votre téléphone',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: g.textPrimary),
          ),
          const SizedBox(height: GraceSpacing.s),
          Text(
            'Pas de compte, pas d’envoi sur Internet : vos vidéos restent '
            'dans GraceEdit.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: g.textSecondary),
          ),
          const SizedBox(height: GraceSpacing.xl),
          const _Point(
            icon: Icons.photo_library_outlined,
            title: 'Choisir une vidéo',
            text: 'Aucune autorisation n’est nécessaire : Android vous laisse '
                'désigner vous-même le fichier.',
          ),
          const _Point(
            icon: Icons.videocam_outlined,
            title: 'Filmer une vidéo',
            text: 'Android demandera l’accès à la caméra seulement à ce '
                'moment-là, pas maintenant.',
          ),
          const _Point(
            icon: Icons.cloud_off_outlined,
            title: 'Hors ligne',
            text: 'L’éditeur et l’export fonctionnent sans connexion.',
          ),
          const SizedBox(height: GraceSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Commencer'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final g = context.grace;
    return Padding(
      padding: const EdgeInsets.only(bottom: GraceSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: g.textSecondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: g.textPrimary)),
                const SizedBox(height: 2),
                Text(text,
                    style: TextStyle(fontSize: 13, color: g.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
