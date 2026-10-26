import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graceedit/core/models/project.dart';

Project _project({List<Clip>? clips, List<MediaRef>? media}) => Project(
  id: 'p1',
  title: 'Projet',
  createdAt: DateTime(2026, 10, 1),
  modifiedAt: DateTime(2026, 10, 2),
  media:
      media ??
      const [
        MediaRef(
          id: 'm1',
          uri: 'content://media/1',
          name: 'clip.mp4',
          kind: MediaKind.video,
          durationMs: 8000,
          sizeBytes: 2048,
          width: 1920,
          height: 1080,
        ),
      ],
  clips:
      clips ??
      const [Clip(id: 'c1', mediaId: 'm1', trimStartMs: 0, trimEndMs: 5000)],
);

void main() {
  group('Project — durée', () {
    test('somme des clips', () {
      expect(_project().durationMs, 5000);
    });

    test('un rognage négatif ne produit pas de durée négative', () {
      const clip = Clip(
        id: 'c',
        mediaId: 'm',
        trimStartMs: 4000,
        trimEndMs: 1000,
      );
      expect(clip.durationMs, 0);
    });

    test('projet vide', () {
      expect(_project(clips: const []).isEmpty, isTrue);
      expect(_project().isEmpty, isFalse);
    });
  });

  group('Project — médias manquants', () {
    test('un chemin local absent est signalé', () {
      const missing = MediaRef(
        id: 'm2',
        uri: '/chemin/qui/nexiste/pas.mp4',
        name: 'absent.mp4',
        kind: MediaKind.video,
        durationMs: 0,
        sizeBytes: 0,
        width: 0,
        height: 0,
      );
      expect(missing.fileMissing, isTrue);
      expect(_project(media: const [missing]).hasMissingMedia, isTrue);
      expect(_project().hasMissingMedia, isFalse);
    });

    test('une URI de contenu Android n’est pas testée sur disque', () {
      expect(_project().media.first.fileMissing, isFalse);
    });

    test('le drapeau missing suffit', () {
      final flagged = _project().media.first.copyWith(missing: true);
      expect(_project(media: [flagged]).missingMedia, hasLength(1));
    });
  });

  group('Project — sérialisation', () {
    test('aller-retour complet', () {
      final source = _project().copyWith(
        format: ProjectFormat.vertical,
        fitMode: FitMode.fit,
        videoVolume: 40,
        coverSource: CoverSource.gallery,
        coverPath: '/tmp/cover.jpg',
        coverTimeMs: 1200,
        texts: const [
          TextItem(
            id: 't1',
            text: 'Bonjour',
            startMs: 0,
            durationMs: 2000,
            preset: TextPreset.title,
            align: TextAlign.left,
          ),
        ],
        audios: const [
          AudioItem(
            id: 'a1',
            mediaId: 'm1',
            startMs: 0,
            trimStartMs: 500,
            trimEndMs: 4000,
            volume: 60,
            fadeInMs: 200,
            fadeOutMs: 400,
          ),
        ],
      );
      final restored = Project.fromJson(source.toJson());

      expect(restored.id, source.id);
      expect(restored.title, source.title);
      expect(restored.format, ProjectFormat.vertical);
      expect(restored.fitMode, FitMode.fit);
      expect(restored.videoVolume, 40);
      expect(restored.coverSource, CoverSource.gallery);
      expect(restored.coverPath, '/tmp/cover.jpg');
      expect(restored.coverTimeMs, 1200);
      expect(restored.texts.single.text, 'Bonjour');
      expect(restored.texts.single.preset, TextPreset.title);
      expect(restored.texts.single.align, TextAlign.left);
      expect(restored.audios.single.fadeInMs, 200);
      expect(restored.clips.single.trimEndMs, 5000);
      expect(restored.durationMs, source.durationMs);
    });

    test('un JSON incomplet retombe sur les valeurs par défaut', () {
      final restored = Project.fromJson({'id': 'x', 'title': 'T'});
      expect(restored.format, ProjectFormat.horizontal);
      expect(restored.fitMode, FitMode.fill);
      expect(restored.media, isEmpty);
      expect(restored.videoVolume, 100);
      expect(restored.texts, isEmpty);
      expect(restored.lastExport, isNull);
    });

    test('l’export enregistré survit à l’aller-retour', () {
      final record = ExportRecord(
        path: '/galerie/film.mp4',
        name: 'film.mp4',
        width: 1080,
        height: 1920,
        durationMs: 5000,
        sizeBytes: 4 * 1024 * 1024,
        createdAt: DateTime(2026, 10, 3, 10, 30),
        inGallery: true,
      );
      final restored = Project.fromJson(
        _project().copyWith(lastExport: record).toJson(),
      );
      expect(restored.lastExport?.name, 'film.mp4');
      expect(restored.lastExport?.inGallery, isTrue);
      expect(restored.lastExport?.sizeBytes, 4 * 1024 * 1024);
    });
  });

  group('Project — corbeille', () {
    test('trashedAt marque le projet, clearTrash le restaure', () {
      final trashed = _project().copyWith(trashedAt: DateTime(2026, 10, 5));
      expect(trashed.isTrashed, isTrue);
      expect(trashed.copyWith(clearTrash: true).isTrashed, isFalse);
    });
  });

  group('Project — réglages', () {
    test('le volume vidéo reste borné', () {
      expect(_project().copyWith(videoVolume: 150).videoVolumeValue, 100);
      expect(_project().copyWith(videoVolume: -20).videoVolumeValue, 0);
    });

    test('hasCustomClipVolume détecte un réglage par clip', () {
      expect(_project().hasCustomClipVolume, isFalse);
      expect(
        _project(
          clips: const [
            Clip(
              id: 'c1',
              mediaId: 'm1',
              trimStartMs: 0,
              trimEndMs: 1000,
              volume: 30,
            ),
          ],
        ).hasCustomClipVolume,
        isTrue,
      );
    });

    test('mediaById retrouve le média ou renvoie null', () {
      expect(_project().mediaById('m1')?.name, 'clip.mp4');
      expect(_project().mediaById('absent'), isNull);
    });
  });

  group('ProjectFormat', () {
    test('chaque format convertit en clé et retour', () {
      for (final format in ProjectFormat.values) {
        expect(ProjectFormat.fromKey(format.key), format);
      }
    });

    test('une clé inconnue retombe sur le format horizontal', () {
      expect(ProjectFormat.fromKey('inconnu'), ProjectFormat.horizontal);
      expect(ProjectFormat.fromKey(null), ProjectFormat.horizontal);
    });

    test('des dimensions de sortie cohérentes avec le ratio', () {
      for (final format in ProjectFormat.values) {
        final ratio = format.outputHeight / format.outputWidth;
        expect(ratio, closeTo(1 / format.ratio, 0.001));
      }
    });
  });

  group('Adjustments', () {
    test('neutre par défaut', () {
      expect(const Adjustments().isNeutral, isTrue);
      expect(const Adjustments(brightness: 10).isNeutral, isFalse);
    });

    test('aller-retour JSON', () {
      final restored = Adjustments.fromJson(
        const Adjustments(brightness: -12, contrast: 8, saturation: 3).toJson(),
      );
      expect(restored.brightness, -12);
      expect(restored.contrast, 8);
      expect(restored.saturation, 3);
    });
  });

  group('TextItem', () {
    test('endMs suit le début et la durée', () {
      const item = TextItem(id: 't', text: 'a', startMs: 1000, durationMs: 500);
      expect(item.endMs, 1500);
    });
  });
}
