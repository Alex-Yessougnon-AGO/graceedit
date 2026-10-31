import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graceedit/core/models/project.dart';
import 'package:graceedit/features/editor/cover_screen.dart';
import 'package:graceedit/features/export/export_screen.dart';
import 'package:graceedit/features/home/home_screen.dart';
import 'package:graceedit/features/import/permission_screen.dart';
import 'package:graceedit/features/projects/projects_screen.dart';
import 'package:graceedit/features/projects/trash_screen.dart';
import 'package:graceedit/features/settings/diagnostic_screen.dart';
import 'package:graceedit/features/settings/help_screen.dart';
import 'package:graceedit/features/settings/settings_screen.dart';
import 'package:graceedit/features/settings/storage_screen.dart';
import 'package:graceedit/features/system/storage_full_screen.dart';
import 'package:graceedit/features/welcome/welcome_screen.dart';

import 'harness.dart';

/// Un écran à contrôler : nom, constructeur, et projets à précharger.
class _Case {
  const _Case(this.name, this.screen, {this.projects = const []});

  final String name;
  final Widget screen;
  final List<Project> projects;
}

void main() {
  final cases = <_Case>[
    _Case('ENT-02 Bienvenue', const WelcomeScreen()),
    _Case('HOM-01 Accueil (vide)', const HomeScreen()),
    _Case(
      'HOM-01 Accueil (avec projet)',
      const HomeScreen(),
      projects: [sampleProject()],
    ),
    _Case('PRJ Projets (vide)', const ProjectsScreen()),
    _Case(
      'PRJ Projets (avec projet)',
      const ProjectsScreen(),
      projects: [sampleProject()],
    ),
    _Case('PRJ Corbeille (vide)', const TrashScreen()),
    _Case(
      'PRJ Corbeille (avec projet)',
      const TrashScreen(),
      projects: [sampleProject().copyWith(trashedAt: DateTime(2026, 10, 3))],
    ),
    _Case('SET-01 Réglages', const SettingsScreen()),
    _Case('SET-02 Stockage', const StorageScreen()),
    _Case('SET-03 Aide', const HelpScreen()),
    _Case('SET-03 Diagnostic', const DiagnosticScreen()),
    _Case('SYS-03 Stockage plein', const StorageFullScreen()),
    _Case('IMP-03 Autorisation médias', const PermissionScreen()),
    _Case('IMP-03 Autorisation refusée', const PermissionScreen(denied: true)),
    _Case(
      'EXP-01 Réglages d’export',
      const ExportScreen(projectId: 'p1'),
      projects: [sampleProject()],
    ),
    _Case(
      'EXP-04 Échec de rendu',
      const ExportErrorScreen(projectId: 'p1'),
      projects: [sampleProject()],
    ),
    _Case(
      'EXP-04 Échec galerie',
      const ExportErrorScreen(projectId: 'p1', cause: 'gallery'),
      projects: [sampleProject()],
    ),
    _Case(
      'EXP-04 Stockage insuffisant',
      const ExportErrorScreen(projectId: 'p1', cause: 'storage'),
      projects: [sampleProject()],
    ),
    _Case(
      'EDT-07 Couverture (vidéo)',
      const CoverScreen(projectId: 'p1'),
      projects: [sampleProject()],
    ),
    _Case(
      'EDT-07 Couverture (galerie)',
      const CoverScreen(projectId: 'p1'),
      projects: [
        sampleProject().copyWith(
          coverSource: CoverSource.gallery,
          coverPath: '/tmp/graceedit-cover-test.jpg',
        ),
      ],
    ),
  ];

  for (final testCase in cases) {
    group(testCase.name, () {
      for (final brightness in Brightness.values) {
        testWidgets('${brightness.name} — accessibilité et rendu', (
          tester,
        ) async {
          useReferenceScreen(tester);
          // Le stockage est sur disque : hors de la zone d'horloge simulée.
          final harness = (await tester.runAsync(
            () => GraceHarness.create(projects: testCase.projects),
          ))!;
          addTearDown(() => tester.runAsync(harness.dispose));

          await tester.pumpWidget(
            harness.app(testCase.screen, brightness: brightness),
          );
          await tester.pump(const Duration(milliseconds: 400));

          await expectAccessible(tester);
          await expectNoOverflow(tester);
        });
      }

      testWidgets('police à 200 % — aucun débordement', (tester) async {
        useReferenceScreen(tester);
        final harness = (await tester.runAsync(
          () => GraceHarness.create(projects: testCase.projects),
        ))!;
        addTearDown(() => tester.runAsync(harness.dispose));

        await tester.pumpWidget(harness.app(testCase.screen, textScale: 2));
        await tester.pump(const Duration(milliseconds: 400));

        await expectNoOverflow(tester);
      });
    });
  }
}
