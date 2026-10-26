import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graceedit/core/l10n/generated/app_localizations.dart';
import 'package:graceedit/core/models/project.dart';
import 'package:graceedit/core/models/settings.dart';
import 'package:graceedit/core/platform/native_gateway.dart';
import 'package:graceedit/core/state/providers.dart';
import 'package:graceedit/core/store/app_store.dart';
import 'package:graceedit/core/theme/app_theme.dart';

/// Taille de référence de la V1 : 360 × 800 dp.
const Size referenceSize = Size(360, 800);

const DeviceInfo testDevice = DeviceInfo(
  supports1080p: true,
  sdkInt: 33,
  model: 'Test',
  freeBytes: 8 * 1024 * 1024 * 1024,
  totalBytes: 64 * 1024 * 1024 * 1024,
);

Project sampleProject({
  String id = 'p1',
  String title = 'Vacances',
  List<Clip>? clips,
  List<MediaRef>? media,
  ExportRecord? lastExport,
}) {
  const mediaRef = MediaRef(
    id: 'm1',
    uri: 'content://media/1',
    name: 'clip.mp4',
    kind: MediaKind.video,
    durationMs: 12000,
    sizeBytes: 3 * 1024 * 1024,
    width: 1920,
    height: 1080,
  );
  return Project(
    id: id,
    title: title,
    createdAt: DateTime(2026, 10, 1),
    modifiedAt: DateTime(2026, 10, 2),
    media: media ?? const [mediaRef],
    clips:
        clips ??
        const [Clip(id: 'c1', mediaId: 'm1', trimStartMs: 0, trimEndMs: 12000)],
    lastExport: lastExport,
  );
}

/// Contexte de test : stockage sur disque temporaire, capacités fixes,
/// thème et langue choisis.
class GraceHarness {
  GraceHarness._(this.root, this.store);

  final Directory root;
  final AppStore store;

  /// Prépare un stockage vierge.
  static Future<GraceHarness> create({
    List<Project> projects = const [],
  }) async {
    final root = await Directory.systemTemp.createTemp('graceedit_screen_');
    final store = AppStore(root: root);
    await store.init();
    for (final project in projects) {
      await store.addProject(project);
    }
    return GraceHarness._(root, store);
  }

  Future<void> dispose() async {
    if (await root.exists()) await root.delete(recursive: true);
  }

  /// Monte `screen` dans une application complète (thème, langue, Riverpod).
  Widget app(
    Widget screen, {
    Brightness brightness = Brightness.light,
    double textScale = 1,
    AppLanguage language = AppLanguage.fr,
    List<Override> extraOverrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        storeProvider.overrideWith((ref) => store),
        bootstrapProvider.overrideWith((ref) async {}),
        deviceInfoProvider.overrideWith((ref) async => testDevice),
        ...extraOverrides,
      ],
      child: MaterialApp(
        theme: buildGraceTheme(brightness),
        darkTheme: buildGraceTheme(Brightness.dark),
        themeMode: brightness == Brightness.light
            ? ThemeMode.light
            : ThemeMode.dark,
        locale: Locale(language.name),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        debugShowCheckedModeBanner: false,
        home: MediaQuery(
          data: MediaQueryData(
            size: referenceSize,
            textScaler: TextScaler.linear(textScale),
          ),
          child: screen,
        ),
      ),
    );
  }
}

/// Règle la fenêtre de test à 360 × 800 dp et restaure ensuite.
void useReferenceScreen(WidgetTester tester) {
  tester.view.physicalSize = referenceSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// Vérifie les trois règles d'accessibilité du projet sur le rendu courant.
Future<void> expectAccessible(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
}

/// Vérifie qu'aucun contenu ne déborde à la taille et au zoom donnés.
Future<void> expectNoOverflow(WidgetTester tester) async {
  expect(tester.takeException(), isNull);
}
