import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:graceedit/core/models/project.dart';
import 'package:graceedit/core/store/app_store.dart';
import 'package:graceedit/features/editor/editor_controller.dart';

Project _project({int durationMs = 10000, ExportRecord? lastExport}) => Project(
  id: 'p1',
  title: 'Projet',
  createdAt: DateTime(2026, 1, 1),
  modifiedAt: DateTime(2026, 1, 1),
  media: const [
    MediaRef(
      id: 'm',
      uri: 'content://media/1',
      name: 'clip.mp4',
      kind: MediaKind.video,
      durationMs: 10000,
      sizeBytes: 1000,
      width: 1920,
      height: 1080,
    ),
  ],
  clips: [Clip(id: 'c1', mediaId: 'm', trimStartMs: 0, trimEndMs: durationMs)],
  lastExport: lastExport,
);

void main() {
  late Directory root;
  late AppStore store;
  late EditorController controller;

  Future<EditorController> create({Project? project}) async {
    root = await Directory.systemTemp.createTemp('graceedit_editor_');
    store = AppStore(root: root);
    await store.init();
    final source = project ?? _project();
    await store.addProject(source);
    final created = EditorController(store: store, project: source);
    // `_session()` est asynchrone (écriture de session) : on la laisse finir
    // avant de rendre la main au test.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    addTearDown(() async {
      created.dispose();
      try {
        if (await root.exists()) await root.delete(recursive: true);
      } on FileSystemException {
        // Le dossier temporaire peut déjà avoir été purgé par le système.
      }
    });
    return created;
  }

  group('sélection', () {
    test('sélectionner un clip puis le désélectionner', () async {
      controller = await create();
      controller.selectClip('c1');
      expect(controller.selection, SelectionType.clip);
      expect(controller.selectedClip?.id, 'c1');
      controller.clearSelection();
      expect(controller.selection, SelectionType.none);
      expect(controller.selectedClip, isNull);
    });

    test('readOnly est activé si le projet a déjà été exporté', () async {
      controller = await create(
        project: _project(
          lastExport: ExportRecord(
            path: '/g/a.mp4',
            name: 'a.mp4',
            width: 1920,
            height: 1080,
            durationMs: 10000,
            sizeBytes: 1000,
            createdAt: DateTime(2026, 1, 2),
            inGallery: true,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.readOnly, isTrue);
    });
  });

  group('scinder', () {
    test('coupe au milieu en deux clips', () async {
      controller = await create();
      controller.selectClip('c1');
      controller.seek(4000);

      expect(controller.splitSelectedClip(), isTrue);
      expect(controller.project.clips, hasLength(2));
      expect(controller.project.clips[0].trimEndMs, 4000);
      expect(controller.project.clips[1].trimStartMs, 4000);
      expect(controller.project.durationMs, 10000);
    });

    test('refuse une coupe trop proche d’un bord', () async {
      controller = await create();
      controller.selectClip('c1');
      controller.seek(20);
      expect(controller.splitSelectedClip(), isFalse);
      expect(controller.project.clips, hasLength(1));
    });

    test('sans sélection, rien ne se passe', () async {
      controller = await create();
      controller.seek(4000);
      expect(controller.splitSelectedClip(), isFalse);
    });
  });

  group('rognage', () {
    test('borne la fin à la durée du média', () async {
      controller = await create();
      controller.trimClip('c1', end: 99000);
      expect(controller.project.clips.single.trimEndMs, 10000);
    });

    test('garde au moins 100 ms', () async {
      controller = await create();
      controller.trimClip('c1', start: 99999);
      final clip = controller.project.clips.single;
      expect(clip.trimEndMs - clip.trimStartMs, greaterThanOrEqualTo(100));
    });

    test('un clip inconnu est ignoré', () async {
      controller = await create();
      final before = controller.project;
      controller.trimClip('absent', end: 500);
      expect(controller.project, same(before));
    });
  });

  group('suppression et duplication', () {
    test('supprimer le clip vide le projet', () async {
      controller = await create();
      controller.removeClip('c1');
      expect(controller.project.clips, isEmpty);
      expect(controller.isEmpty, isTrue);
    });

    test('dupliquer ajoute un clip avec un nouvel identifiant', () async {
      controller = await create();
      controller.duplicateClip('c1');
      expect(controller.project.clips, hasLength(2));
      expect(
        controller.project.clips[0].id,
        isNot(controller.project.clips[1].id),
      );
      expect(controller.project.durationMs, 20000);
    });
  });

  group('annuler / rétablir', () {
    test('annuler restaure le format précédent', () async {
      controller = await create();
      controller.setFormat(ProjectFormat.vertical);
      expect(controller.canUndo, isTrue);

      controller.undo();
      expect(controller.project.format, ProjectFormat.horizontal);
      expect(controller.canRedo, isTrue);

      controller.redo();
      expect(controller.project.format, ProjectFormat.vertical);
    });

    test('annuler une scission la défait', () async {
      controller = await create();
      controller.selectClip('c1');
      controller.seek(5000);
      controller.splitSelectedClip();
      expect(controller.project.clips, hasLength(2));

      controller.undo();
      expect(controller.project.clips, hasLength(1));
    });

    test('une nouvelle modification vide la pile de rétablissement', () async {
      controller = await create();
      controller.setFormat(ProjectFormat.vertical);
      controller.undo();
      expect(controller.canRedo, isTrue);

      controller.setFormat(ProjectFormat.square);
      expect(controller.canRedo, isFalse);
    });

    test('sans historique, annuler ne fait rien', () async {
      controller = await create();
      controller.undo();
      expect(controller.project.format, ProjectFormat.horizontal);
    });

    test('un geste continu ne produit qu’une seule étape', () async {
      controller = await create();
      controller.beginGesture();
      controller.setVideoVolume(80);
      controller.setVideoVolume(60);
      controller.setVideoVolume(40);
      controller.endGesture();

      controller.undo();
      expect(controller.project.videoVolume, 100);
      expect(controller.canUndo, isFalse);
    });
  });

  group('texte', () {
    test('ajouter un texte le sélectionne et l’enregistre', () async {
      controller = await create();
      final item = controller.addText(text: 'Bonjour');
      expect(controller.project.texts, hasLength(1));
      expect(controller.selection, SelectionType.text);
      expect(controller.selectedText?.id, item.id);
    });

    test('modifier puis supprimer un texte', () async {
      controller = await create();
      final item = controller.addText(text: 'Bonjour');
      controller.updateText(item.copyWith(text: 'Salut'));
      expect(controller.project.texts.single.text, 'Salut');

      controller.removeText(item.id);
      expect(controller.project.texts, isEmpty);
    });
  });

  group('sauvegarde', () {
    test('les modifications finissent dans le stockage', () async {
      controller = await create();
      controller.setFormat(ProjectFormat.vertical);
      expect(controller.saveState, SaveState.saving);

      await controller.flush();
      expect(controller.saveState, SaveState.saved);
      expect(store.projectById('p1')?.format, ProjectFormat.vertical);
    });
  });
}
