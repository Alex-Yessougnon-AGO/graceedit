import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/state/app_providers.dart';
import 'features/splash/splash_screen.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'core/router/app_router.dart';

/// Point d'entrée principal de l'application GraceEdit V1.
void main() => runApp(const GraceEditApp());

/// L'application Riverpod wrapper.
class GraceEditApp extends ConsumerWidget {
  const GraceEditApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Regarder le bootstrap ; tant qu'il n'est pas terminé, on montre le splash.
    final bootstrapAsync = ref.watch(bootstrapProvider);

    // Durant le chargement, on affiche le splash.
    if (bootstrapAsync.isLoading) {
      return const SplashScreen();
    }

    // Bootstrap terminé — on peut afficher l'app avec navigation.
    return MaterialApp.router(
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      title: 'GraceEdit',
      theme: buildGraceTheme(Brightness.light),
      darkTheme: buildGraceTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
    );
  }
}