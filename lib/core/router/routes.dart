/// Enum des routes disponibles de l'application.
enum AppRoute {
  splash('/splash'),
  welcome('/welcome'),
  home('/home'),
  importNew('/import/new'),
  projects('/projects'),
  settings('/settings');

  final String path;
  const AppRoute(this.path);
  String get pathString => path;
}

/// Mapping des routes nommées vers les chemins GoRouter.
final Map<AppRoute, String> appRoutePaths = {
  AppRoute.splash: '/splash',
  AppRoute.welcome: '/welcome',
  AppRoute.home: '/home',
  AppRoute.importNew: '/import/new',
  AppRoute.projects: '/projects',
  AppRoute.settings: '/settings',
};