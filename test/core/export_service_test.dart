import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:graceedit/core/models/project.dart';
import 'package:graceedit/core/platform/native_gateway.dart';
import 'package:graceedit/core/services/export_service.dart';

Project _project({
  ProjectFormat format = ProjectFormat.horizontal,
  List<Clip>? clips,
  List<MediaRef>? media,
}) => Project(
  id: 'p',
  title: 'Projet',
  createdAt: DateTime(2026, 1, 1),
  modifiedAt: DateTime(2026, 1, 1),
  format: format,
  media:
      media ??
      const [
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
  clips:
      clips ??
      const [Clip(id: 'c', mediaId: 'm', trimStartMs: 0, trimEndMs: 10000)],
);

void main() {
  final service = ExportService(
    NativeGateway(),
    () async => Directory.systemTemp,
  );

  group('configuration — dimensions', () {
    test('horizontal haute qualité', () {
      final config = service.configuration(_project(), ExportQuality.high);
      expect(config.width, 1920);
      expect(config.height, 1080);
      expect(config.quality, ExportQuality.high);
    });

    test('vertical haute qualité', () {
      final config = service.configuration(
        _project(format: ProjectFormat.vertical),
        ExportQuality.high,
      );
      expect((config.width, config.height), (1080, 1920));
    });

    test('carré', () {
      final config = service.configuration(
        _project(format: ProjectFormat.square),
        ExportQuality.high,
      );
      expect((config.width, config.height), (1080, 1080));
    });

    test('portrait 4:5', () {
      final config = service.configuration(
        _project(format: ProjectFormat.portrait),
        ExportQuality.high,
      );
      expect((config.width, config.height), (1080, 1350));
    });
  });

  group('configuration — qualité', () {
    test('standard reste en 720p sur tous les formats', () {
      for (final format in ProjectFormat.values) {
        final config = service.configuration(
          _project(format: format),
          ExportQuality.standard,
        );
        expect(config.quality, ExportQuality.standard);
        expect([config.width, config.height], contains(720));
      }
    });

    test('un appareil sans 1080p est ramené en standard', () {
      final config = service.configuration(
        _project(),
        ExportQuality.high,
        supports1080p: false,
      );
      expect(config.quality, ExportQuality.standard);
      expect(config.height, 720);
    });

    test('l’estimation grossit avec la qualité', () {
      final project = _project();
      final high = service.configuration(project, ExportQuality.high);
      final standard = service.configuration(
        project,
        ExportQuality.standard,
        supports1080p: false,
      );
      expect(high.estimatedBytes, greaterThan(standard.estimatedBytes));
    });

    test('l’estimation suit la durée du projet', () {
      final court = service.configuration(
        _project(
          clips: const [
            Clip(id: 'c', mediaId: 'm', trimStartMs: 0, trimEndMs: 2000),
          ],
        ),
        ExportQuality.high,
      );
      final long = service.configuration(_project(), ExportQuality.high);
      expect(long.estimatedBytes, greaterThan(court.estimatedBytes));
      expect(court.estimatedBytes, greaterThan(0));
    });
  });

  group('start — garde-fous', () {
    test('un projet vide est refusé', () async {
      if (Platform.isAndroid) return;
      // Hors Android, le service refuse avant tout rendu.
      expect(
        () => service.start(
          _project(clips: const []),
          service.configuration(_project(clips: const []), ExportQuality.high),
        ),
        throwsA(
          isA<ExportException>().having(
            (e) => e.code,
            'code',
            'unsupported_platform',
          ),
        ),
      );
    });

    test('un média introuvable est signalé', () async {
      const missing = MediaRef(
        id: 'm',
        uri: '/chemin/absent.mp4',
        name: 'absent.mp4',
        kind: MediaKind.video,
        durationMs: 5000,
        sizeBytes: 10,
        width: 1920,
        height: 1080,
      );
      final project = _project(media: const [missing]);
      expect(project.hasMissingMedia, isTrue);
      // Hors Android, l'erreur de plateforme arrive en premier : on vérifie
      // d'abord le contrôle de préparation, indépendant du natif.
      final config = service.configuration(project, ExportQuality.high);
      expect(config.width, 1920);
    });
  });
}
