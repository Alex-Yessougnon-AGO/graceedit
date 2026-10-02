import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:graceedit/core/ai/decision_provider.dart';
import 'package:graceedit/core/commands/commands.dart';
import 'package:graceedit/core/models/grace_project.dart';
import 'package:graceedit/core/platform/capabilities.dart';
import 'package:graceedit/core/services/import_service.dart';
import 'package:graceedit/core/services/thumbnails.dart';

void main() {
  group('GraceProject model', () {
    test('duration sums clip durations with speed', () {
      final p = GraceProject(name: 'Test', kind: ProjectKind.video);
      p.clips.add(VideoClip(id: 'a', assetId: 'x', startMs: 0, endMs: 4000));
      p.clips.add(VideoClip(id: 'b', assetId: 'x', startMs: 0, endMs: 2000, speed: 2.0));
      expect(p.totalDurationMs, 4000 + 1000);
    });

    test('json roundtrip preserves data', () {
      final p = GraceProject(name: 'Conf jeunes', kind: ProjectKind.video);
      p.assets.add(const MediaAsset(id: 'a1', kind: MediaKind.video, path: '/tmp/a.mp4', durationMs: 5000));
      p.clips.add(VideoClip(id: 'c1', assetId: 'a1', startMs: 0, endMs: 3000));
      p.texts.add(const TextLayer(id: 't1', text: 'Bienvenue'));
      p.subtitles.add(const SubtitleCue(id: 's1', text: 'Hello', startMs: 0, endMs: 1000));
      final restored = GraceProject.fromJson(p.toJson());
      expect(restored.name, 'Conf jeunes');
      expect(restored.clips.length, 1);
      expect(restored.texts.first.text, 'Bienvenue');
      expect(restored.subtitles.length, 1);
    });
  });

  group('CommandStack', () {
    test('add/undo/redo clip', () {
      final p = GraceProject(name: 'T', kind: ProjectKind.video);
      final stack = CommandStack();
      final clip = VideoClip(id: 'c1', assetId: 'a', startMs: 0, endMs: 2000);
      stack.execute(p, AddClipCommand(clip));
      expect(p.clips.length, 1);
      expect(stack.undo(p), true);
      expect(p.clips, isEmpty);
      expect(stack.redo(p), true);
      expect(p.clips.length, 1);
    });

    test('split then undo restores single clip', () {
      final p = GraceProject(name: 'T', kind: ProjectKind.video);
      final stack = CommandStack();
      stack.execute(p, AddClipCommand(VideoClip(id: 'c1', assetId: 'a', startMs: 0, endMs: 4000)));
      stack.execute(p, SplitClipCommand('c1', 1500));
      expect(p.clips.length, 2);
      expect(p.totalDurationMs, 4000);
      expect(stack.undo(p), true);
      expect(p.clips.length, 1);
      expect(p.clips.first.endMs, 4000);
    });

    test('trim + move + remove roundtrip', () {
      final p = GraceProject(name: 'T', kind: ProjectKind.video);
      final stack = CommandStack();
      stack.execute(p, AddClipCommand(VideoClip(id: 'c1', assetId: 'a', startMs: 0, endMs: 4000)));
      stack.execute(p, AddClipCommand(VideoClip(id: 'c2', assetId: 'a', startMs: 0, endMs: 2000)));
      stack.execute(p, TrimClipCommand('c1', newStartMs: 500, newEndMs: 3500));
      expect(p.clips.firstWhere((c) => c.id == 'c1').durationMs, 3000);
      stack.execute(p, MoveClipCommand('c1', 1));
      expect(p.clips.last.id, 'c1');
      expect(stack.undo(p), true);
      expect(p.clips.first.id, 'c1');
      stack.execute(p, RemoveClipCommand('c2'));
      expect(p.clips.length, 1);
      expect(stack.undo(p), true);
      expect(p.clips.length, 2);
    });
  });

  group('Capabilities & export profiles', () {
    test('modest device hides 4K-ish profiles but keeps V1 set', () {
      const modest = DeviceCapabilities(maxExportWidth: 1920, maxExportHeight: 1920, maxFps: 30);
      final supported = ExportProfile.supportedBy(modest);
      expect(supported.map((e) => e.id),
          containsAll([ExportProfileId.p720, ExportProfileId.p1080]));
    });
  });

  group('DecisionProvider fallback', () {
    test('local fallback never fails without network', () async {
      final provider = LocalFallbackDecisions();
      final t = await provider.chooseTemplate(brief: 'conférence jeunes', candidates: ['a', 'b']);
      expect(t.fallbackUsed, true);
      expect(t.value, 'a');
      final e = await provider.recommendExportProfile(
          sourceWidth: 1080, sourceHeight: 1920, candidates: ['p1080', 'vertical1080x1920']);
      expect(e.value, 'vertical1080x1920');
    });

    test('mock generation provider is labelled mock', () async {
      final mock = MockGenerationProvider();
      expect(mock.isMock, true);
      final r = await mock.generate(prompt: 'affiche conférence');
      expect(r.metadata['mock'], true);
    });
  });

  group('Phase 3 — clip props & subtitles', () {
    test('UpdateClipPropsCommand applies and reverts', () {
      final p = GraceProject(name: 'T', kind: ProjectKind.video);
      final stack = CommandStack();
      stack.execute(p, AddClipCommand(VideoClip(id: 'c1', assetId: 'a', startMs: 0, endMs: 4000)));
      stack.execute(p, UpdateClipPropsCommand('c1',
          speed: 2.0, volume: 0.5, rotation: 90,
          brightness: 0.1, contrast: 1.2, saturation: 0.8));
      final c = p.clips.first;
      expect(c.speed, 2.0);
      expect(c.rotation, 90);
      expect(c.durationMs, 2000);
      expect(stack.undo(p), true);
      expect(p.clips.first.speed, 1.0);
      expect(p.clips.first.rotation, 0);
    });

    test('subtitle style persists through json', () {
      final p = GraceProject(name: 'T', kind: ProjectKind.video);
      p.subtitleStyle = 'outline';
      p.subtitles.add(const SubtitleCue(id: 's1', text: 'Bonjour', startMs: 0, endMs: 1500));
      final restored = GraceProject.fromJson(p.toJson());
      expect(restored.subtitleStyle, 'outline');
      expect(restored.subtitles.first.text, 'Bonjour');
      // Old files without the field default to classic.
      final legacy = Map<String, dynamic>.from(p.toJson())..remove('subtitleStyle');
      expect(GraceProject.fromJson(legacy).subtitleStyle, 'classic');
    });
  });

  group('Phase 2 — thumbnails & import', () {
    test('cache key changes with version/size/frame', () {
      const a = ThumbnailRequest(
          assetId: 'x', sourcePath: '/tmp/a.mp4', sourceVersion: 1);
      const b = ThumbnailRequest(
          assetId: 'x', sourcePath: '/tmp/a.mp4', sourceVersion: 2);
      const c = ThumbnailRequest(
          assetId: 'x', sourcePath: '/tmp/a.mp4', sourceVersion: 1, frameMs: 800);
      expect(a.cacheKey, isNot(b.cacheKey));
      expect(a.cacheKey, isNot(c.cacheKey));
    });

    test('representative frame is never 0 and stays bounded', () {
      expect(ThumbnailService.representativeFrameMs(0), greaterThan(0));
      expect(ThumbnailService.representativeFrameMs(60000), lessThanOrEqualTo(5000));
      expect(ThumbnailService.representativeFrameMs(10000), 1000);
    });

    test('isReadable rejects empty/missing files', () async {
      expect(await ImportService.isReadable('/tmp/graceedit_missing_xyz.mp4'), false);
      final empty = File('${Directory.systemTemp.path}/grace_empty_test.bin');
      await empty.writeAsBytes([]);
      expect(await ImportService.isReadable(empty.path), false);
      await empty.writeAsBytes([1, 2, 3]);
      expect(await ImportService.isReadable(empty.path), true);
      await empty.delete();
    });
  });
}
