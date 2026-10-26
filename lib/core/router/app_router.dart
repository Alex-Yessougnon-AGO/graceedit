import 'package:go_router/go_router.dart';

import '../../features/editor/editor_screen.dart';
import '../../features/export/export_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/import/import_screen.dart';
import '../../features/import/permission_screen.dart';
import '../../features/projects/projects_screen.dart';
import '../../features/projects/relink_screen.dart';
import '../../features/projects/trash_screen.dart';
import '../../features/settings/diagnostic_screen.dart';
import '../../features/settings/help_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/storage_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/system/storage_full_screen.dart';
import '../../features/welcome/welcome_screen.dart';

/// Routes de la V1 — source : `docs/graceedit/FLUX_V1.md` §3.
///
/// Les feuilles, fenêtres et modes de l'éditeur (texte, audio, ajustements,
/// format, cadrer, couverture) sont des **états internes** de l'éditeur, pas
/// des routes de premier niveau.
final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/import/new',
      builder: (context, state) => const ImportScreen(),
    ),
    GoRoute(
      path: '/import/permission',
      builder: (context, state) => const PermissionScreen(),
    ),
    GoRoute(
      path: '/import/permission/denied',
      builder: (context, state) => const PermissionScreen(denied: true),
    ),
    GoRoute(
      path: '/editor/:projectId',
      builder: (context, state) =>
          EditorScreen(projectId: state.pathParameters['projectId'] ?? ''),
    ),
    GoRoute(
      path: '/export/:projectId',
      builder: (context, state) =>
          ExportScreen(projectId: state.pathParameters['projectId'] ?? ''),
    ),
    GoRoute(
      path: '/export/:projectId/progress',
      builder: (context, state) => ExportProgressScreen(
        projectId: state.pathParameters['projectId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/export/:projectId/result',
      builder: (context, state) => ExportResultScreen(
        projectId: state.pathParameters['projectId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/export/:projectId/error',
      builder: (context, state) => ExportErrorScreen(
        projectId: state.pathParameters['projectId'] ?? '',
        cause: state.uri.queryParameters['cause'] ?? 'render',
      ),
    ),
    GoRoute(
      path: '/projects',
      builder: (context, state) => const ProjectsScreen(),
    ),
    GoRoute(
      path: '/projects/trash',
      builder: (context, state) => const TrashScreen(),
    ),
    GoRoute(
      path: '/projects/:projectId/relink',
      builder: (context, state) =>
          RelinkScreen(projectId: state.pathParameters['projectId'] ?? ''),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/storage',
      builder: (context, state) => const StorageScreen(),
    ),
    GoRoute(
      path: '/settings/help',
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: '/settings/help/diagnostic',
      builder: (context, state) => const DiagnosticScreen(),
    ),
    GoRoute(
      path: '/system/storage-full',
      builder: (context, state) => const StorageFullScreen(),
    ),
  ],
);
