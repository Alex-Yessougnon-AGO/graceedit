import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:graceedit/core/l10n/generated/app_localizations.dart';
import 'package:graceedit/core/models/settings.dart';
import 'package:graceedit/core/state/providers.dart';
import 'package:graceedit/core/theme/app_theme.dart';
import 'package:graceedit/core/ui/brand.dart';
import 'package:graceedit/features/splash/splash_screen.dart';

import 'harness.dart';

/// ENT-01 — Splash. La fiche impose : symbole de 120 dp centré dans la
/// fenêtre, glissement du bloc d'accent en 400 ms, message après 5 s,
/// état d'erreur explicite, aucun délai artificiel.
void main() {
  GoRouter router() => GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: '/welcome',
        builder: (_, _) => const Scaffold(body: Text('welcome-stub')),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('home-stub')),
      ),
    ],
  );

  /// Monte le splash ; `boot` permet de contrôler la fin de l'initialisation.
  Future<Completer<void>> pumpSplash(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    double textScale = 1,
    bool reduceMotion = false,
    Completer<void>? boot,
    bool failBoot = false,
  }) async {
    useReferenceScreen(tester);
    final gate = boot ?? Completer<void>();
    final r = router();
    addTearDown(r.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bootstrapProvider.overrideWith(
            (ref) => failBoot
                ? Future<void>.error(StateError('stockage indisponible'))
                : gate.future,
          ),
          settingsProvider.overrideWithValue(
            Settings(reduceMotion: reduceMotion),
          ),
        ],
        child: MaterialApp.router(
          theme: buildGraceTheme(brightness),
          darkTheme: buildGraceTheme(Brightness.dark),
          themeMode: brightness == Brightness.light
              ? ThemeMode.light
              : ThemeMode.dark,
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          debugShowCheckedModeBanner: false,
          routerConfig: r,
        ),
      ),
    );
    return gate;
  }

  testWidgets('le symbole fait 120 dp et il est centré dans la fenêtre', (
    tester,
  ) async {
    await pumpSplash(tester);
    await tester.pump();

    final mark = find.byType(GraceMark);
    expect(mark, findsOneWidget);
    expect(tester.getSize(mark), const Size(120, 120));
    // Fenêtre de référence 360 × 800 : centre exact, barres comprises.
    expect(tester.getCenter(mark), const Offset(180, 400));
  });

  testWidgets('le message « Préparation en cours… » apparaît après 5 s', (
    tester,
  ) async {
    await pumpSplash(tester);
    await tester.pump();

    expect(find.text('Préparation en cours…'), findsNothing);

    await tester.pump(const Duration(milliseconds: 4900));
    expect(find.text('Préparation en cours…'), findsNothing);

    await tester.pump(const Duration(milliseconds: 200));
    final message = find.text('Préparation en cours…');
    expect(message, findsOneWidget);

    // À 24 dp sous l'encre du symbole (96 dp de haut, centré en 400).
    expect(tester.getTopLeft(message).dy, closeTo(400 + 48 + 24, 0.5));
  });

  testWidgets('le bloc d’accent glisse en 400 ms puis reste immobile', (
    tester,
  ) async {
    await pumpSplash(tester);
    await tester.pump();

    double progress() =>
        tester.widget<GraceMark>(find.byType(GraceMark)).accentProgress;

    expect(progress(), 0);
    await tester.pump(const Duration(milliseconds: 200));
    expect(progress(), greaterThan(0));
    expect(progress(), lessThan(1));
    await tester.pump(const Duration(milliseconds: 200));
    expect(progress(), 1);
  });

  testWidgets('le mouvement réduit supprime l’animation', (tester) async {
    await pumpSplash(tester, reduceMotion: true);
    await tester.pump();

    expect(tester.widget<GraceMark>(find.byType(GraceMark)).accentProgress, 1);
  });

  testWidgets('le bootstrap terminé ouvre l’écran suivant', (tester) async {
    final gate = await pumpSplash(tester);
    await tester.pump();
    expect(find.text('welcome-stub'), findsNothing);

    gate.complete();
    await tester.pumpAndSettle();

    expect(find.text('welcome-stub'), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });

  testWidgets('un échec du bootstrap affiche une erreur actionnable', (
    tester,
  ) async {
    await pumpSplash(tester, failBoot: true);
    await tester.pump();

    expect(find.text("L'application n'a pas pu démarrer."), findsOneWidget);
    expect(
      find.text(
        'Vos projets sont intacts. Fermez les autres applications, '
        'puis réessayez.',
      ),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.byType(GraceMark), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('accessibilité du splash — ${brightness.name}', (tester) async {
      await pumpSplash(tester, brightness: brightness);
      await tester.pump(const Duration(seconds: 6));
      await expectAccessible(tester);
      expectNoOverflow(tester);
    });

    testWidgets('splash à 200 % — ${brightness.name}', (tester) async {
      await pumpSplash(tester, brightness: brightness, textScale: 2);
      await tester.pump(const Duration(seconds: 6));
      expectNoOverflow(tester);
      expect(find.text('Préparation en cours…'), findsOneWidget);
    });
  }
}
