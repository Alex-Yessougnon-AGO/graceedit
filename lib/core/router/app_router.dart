import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/import/import_new_screen.dart';
import '../../features/projects/projects_screen.dart';
import '../../features/settings/settings_screen.dart';

/// Routes of the application, defined per `FLUX_V1.md` §3.
final router = GoRouter(
  routes: [
    /// ENT-01 Splash (page de lancement, durée réelle).
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    /// SYS-01 Récupération (projet non sauvegardé avant fermeture).
    GoRoute(
      path: '/recovery',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('SYS-01: Récupération - à implémenter'),
        ),
      ),
    ),

    /// ENT-02 Bienvenue (premier lancement).
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),

    /// HOM-01 Accueil (reprise ou nouveau projet).
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),

    /// IMP-01 Sélecteur de médias du système (déclenché depuis ENT-02 ou HOM-01).
    GoRoute(
      path: '/import/new',
      builder: (context, state) => const ImportNewScreen(),
    ),

    /// PRJ-01 Projets (liste, grille, sélection, corbeille).
    GoRoute(
      path: '/projects',
      builder: (context, state) => const ProjectsScreen(),
    ),

    /// SET-01/RÉGLAGES.
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  initialLocation: '/splash',
);