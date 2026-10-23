import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../core/theme/app_theme.dart';

/// Écran ENT-01 Splash (page de lancement).
/// Affiche le symbole GraceEdit centré pendant le temps d'initialisation
/// réel. Fond clair #F6F2EA / sombre #14151A. Aucune chaîne en dur,
/// aucune animation décorative. 120 dp de large, centré.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _navigateAttempts = 0;
  static const maxAttempts = 3;

  @override
  void initState() {
    super.initState();
    _determineRoute();
  }

  void _determineRoute() {
    if (!_mounted) return;
    if (_navigateAttempts >= maxAttempts) {
      if (!mounted) return;
      context.go('/home');
      return;
    }

    _navigateAttempts++;

    final ref = context.read<WidgetRef>();
    final bootstrapAsync = ref.watch(bootstrapProvider);

    if (bootstrapAsync.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback(_determineRoute);
      return;
    }

    final pendingProjectId = await ref
        .read(bootstrapProvider)
        .valueOrNull
        ?.recovery
        .pendingProjectId();

    if (pendingProjectId != null) {
      ref.read(bootstrapProvider).valueOrNull?.recovery.end();
      if (!mounted) return;
      context.go('/recovery');
      return;
    }

    final welcomeSeen = await ref.read(bootstrapProvider).valueOrNull?.welcomeSeen ?? false;

    if (!welcomeSeen) {
      if (!mounted) return;
      context.go('/welcome');
    } else {
      if (!mounted) return;
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final Color background = isLight ? Color(0xFFEDE7DB) : Color(0xFF1D1F25);

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: GraceMark(
          size: 120,
          // La couleur du symbole est tirée du thème via context.grace
          // Pas de couleur explicite : GraceMark utilise context.grace
        ),
      ),
    );
  }
}