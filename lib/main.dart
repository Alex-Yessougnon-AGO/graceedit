import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/generated/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Point d'entrée principal de l'application GraceEdit V1.
///
/// Le thème et les traductions sont disponibles dès la première image : le
/// splash (`ENT-01`) est une route comme les autres et attend lui-même la fin
/// du bootstrap. On n'affiche donc qu'un seul splash perçu.
void main() => runApp(const ProviderScope(child: GraceEditApp()));

class GraceEditApp extends StatelessWidget {
  const GraceEditApp({super.key});

  @override
  Widget build(BuildContext context) {
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
