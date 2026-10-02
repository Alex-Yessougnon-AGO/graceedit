library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/state/providers.dart';
import 'features/editor/editor_screen.dart';
import 'features/export/export_screen.dart';
import 'features/home/home_screen.dart';
import 'features/settings/settings_screen.dart';
import 'theme/tokens.dart';

GoRouter buildRouter() => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
        GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
        GoRoute(
          path: '/editor/:id',
          builder: (c, s) => EditorScreen(projectId: s.pathParameters['id']!),
        ),
        GoRoute(path: '/export/:id', builder: (c, s) => const ExportScreen()),
      ],
    );

class GraceApp extends ConsumerWidget {
  const GraceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'GraceEdit',
      debugShowCheckedModeBanner: false,
      theme: graceTheme(Brightness.light),
      darkTheme: graceTheme(Brightness.dark),
      themeMode: themeMode,
      routerConfig: buildRouter(),
    );
  }
}
