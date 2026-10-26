import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:graceedit/core/l10n/generated/app_localizations_fr.dart';
import 'package:graceedit/core/models/project.dart';
import 'package:graceedit/core/models/settings.dart';
import 'package:graceedit/core/store/app_store.dart';

Project _project(String id, {DateTime? modified, String? title}) => Project(
  id: id,
  title: title ?? 'Projet $id',
  createdAt: DateTime(2026, 1, 1),
  modifiedAt: modified ?? DateTime(2026, 1, 1),
  media: const [
    MediaRef(
      id: 'm',
      uri: 'content://media/1',
      name: 'clip.mp4',
      kind: MediaKind.video,
      durationMs: 4000,
      sizeBytes: 1000,
      width: 1920,
      height: 1080,
    ),
  ],
  clips: const [Clip(id: 'c', mediaId: 'm', trimStartMs: 0, trimEndMs: 4000)],
);

void main() {
  late Directory root;
  late AppStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('graceedit_test_');
    store = AppStore(root: root);
    await store.init();
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('démarrage sur un dossier vide', () {
    expect(store.isReady, isTrue);
    expect(store.projects, isEmpty);
    expect(store.settings.welcomeSeen, isFalse);
  });

  group('sauvegarde et relecture', () {
    test('les projets survivent à un redémarrage', () async {
      await store.addProject(_project('a'));
      await store.setSettings(
        store.settings.copyWith(
          theme: AppThemeMode.dark,
          language: AppLanguage.en,
        ),
      );

      final reopened = AppStore(root: root);
      await reopened.init();

      expect(reopened.projects, hasLength(1));
      expect(reopened.projects.single.title, 'Projet a');
      expect(reopened.settings.theme, AppThemeMode.dark);
      expect(reopened.settings.language, AppLanguage.en);
    });

    test('saveProject met à jour la date de modification', () async {
      final project = _project('a', modified: DateTime(2026, 1, 1));
      await store.addProject(project);
      await store.saveProject(project.copyWith(title: 'Renommé'));

      expect(store.projectById('a')?.title, 'Renommé');
      expect(
        store.projectById('a')!.modifiedAt.isAfter(DateTime(2026, 1, 1)),
        isTrue,
      );
    });

    test('setWelcomeSeen n’écrit qu’une fois', () async {
      await store.setWelcomeSeen();
      expect(store.settings.welcomeSeen, isTrue);
      await store.setWelcomeSeen();
      expect(store.settings.welcomeSeen, isTrue);
    });
  });

  group('corbeille', () {
    test('mise à la corbeille puis restauration', () async {
      await store.addProject(_project('a'));
      await store.addProject(_project('b'));

      await store.trash(['a']);
      expect(store.activeProjects.map((p) => p.id), ['b']);
      expect(store.trashProjects.map((p) => p.id), ['a']);

      await store.restore(['a']);
      expect(store.activeProjects.map((p) => p.id).toSet(), {'a', 'b'});
      expect(store.trashProjects, isEmpty);
    });

    test('suppression définitive', () async {
      await store.addProject(_project('a'));
      await store.trash(['a']);
      await store.deletePermanently(['a']);
      expect(store.projects, isEmpty);
    });

    test('la purge supprime au-delà de 30 jours, pas avant', () async {
      final now = DateTime.now();
      final expired = _project('vieux')
          .copyWith(trashedAt: now.subtract(const Duration(days: 31)));
      final recent = _project('recent')
          .copyWith(trashedAt: now.subtract(const Duration(days: 29)));
      final active = _project('actif');

      store.projects = [expired, recent, active];
      await store.purgeExpiredTrash();

      expect(store.projects.map((p) => p.id).toSet(), {'recent', 'actif'});
      expect(store.trashProjects, hasLength(1));
    });

    test('la purge tourne au démarrage', () async {
      store.projects = [
        _project('vieux').copyWith(
          trashedAt: DateTime.now().subtract(const Duration(days: 40)),
        ),
      ];
      // Écriture directe du fichier d'état pour simuler une session passée.
      final state = File('${root.path}/state.json');
      await state.writeAsString(
        '{"settings":{"welcomeSeen":true},'
        '"projects":[${_json(store.projects.single)}],"cleanExit":true}',
      );

      final reopened = AppStore(root: root);
      await reopened.init();
      expect(reopened.projects, isEmpty);
      expect(reopened.settings.welcomeSeen, isTrue);
    });
  });

  group('duplication', () {
    test(
      'copie le projet avec un nouvel identifiant et un titre explicite',
      () async {
        await store.addProject(_project('a', title: 'Vacances'));
        final copies = await store.duplicate(
          ['a'],
          titleOf: (p) => AppLocalizationsFr().projectsDuplicateSuffix(p.title),
        );

        expect(copies, hasLength(1));
        expect(copies.single.id, isNot('a'));
        expect(copies.single.title, 'Vacances (copie)');
        expect(copies.single.clips, hasLength(1));
        expect(store.projects, hasLength(2));
      },
    );

    test(
      'la copie ne va pas dans la corbeille même si la source y est',
      () async {
        await store.addProject(_project('a'));
        await store.trash(['a']);
        final copies = await store.duplicate(
          ['a'],
          titleOf: (p) => AppLocalizationsFr().projectsDuplicateSuffix(p.title),
        );
        expect(copies.single.isTrashed, isFalse);
        expect(store.activeProjects, hasLength(1));
      },
    );
  });

  group('tri', () {
    test('récent, ancien, alphabétique', () async {
      await store.addProject(
        _project('vieux', modified: DateTime(2026, 1, 1), title: 'Bravo'),
      );
      await store.addProject(
        _project('neuf', modified: DateTime(2026, 6, 1), title: 'Alpha'),
      );

      expect(store.activeProjects.first.id, 'neuf');

      await store.setSettings(store.settings.copyWith(sort: SortOrder.oldest));
      expect(store.activeProjects.first.id, 'vieux');

      await store.setSettings(store.settings.copyWith(sort: SortOrder.name));
      expect(store.activeProjects.first.id, 'neuf');
    });
  });

  group('stockage', () {
    test('storageStats additionne les médias référencés', () async {
      await store.addProject(_project('a'));
      final stats = await store.storageStats();
      expect(stats.projectBytes, 1000);
      expect(stats.trashBytes, 0);
      expect(stats.usedBytes, greaterThanOrEqualTo(1000));
    });

    test('les médias en corbeille sont comptés à part', () async {
      await store.addProject(_project('a'));
      await store.trash(['a']);
      final stats = await store.storageStats();
      expect(stats.projectBytes, 0);
      expect(stats.trashBytes, 1000);
    });

    test('clearCache supprime les fichiers du cache', () async {
      final cache = await store.cacheDir();
      await File('${cache.path}/thumb.jpg').writeAsBytes(List.filled(2048, 7));

      final freed = await store.clearCache();
      expect(freed, 2048);
      expect(await cache.list().isEmpty, isTrue);
    });
  });

  group('session', () {
    test('openProjectId et cleanExit sont persistés', () async {
      await store.setSession(projectId: 'a', clean: false);
      final reopened = AppStore(root: root);
      await reopened.init();
      expect(reopened.openProjectId, 'a');
      expect(reopened.cleanExit, isFalse);
    });
  });
}

String _json(Project project) {
  final map = project.toJson();
  return '{"id":"${map['id']}","title":"${map['title']}",'
      '"createdAt":"${map['createdAt']}","modifiedAt":"${map['modifiedAt']}",'
      '"trashedAt":"${map['trashedAt']}"}';
}
