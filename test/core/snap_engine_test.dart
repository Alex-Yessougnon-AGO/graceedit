import 'package:flutter_test/flutter_test.dart';
import 'package:graceedit/features/editor/snap_engine.dart';

void main() {
  group('snapValue', () {
    test('accroche le candidat le plus proche dans le seuil', () {
      final outcome = snapValue(4980, [0, 5000, 10000], 120);
      expect(outcome.value, 5000);
      expect(outcome.hit, 5000);
    });

    test('hors seuil, la cible est inchangée', () {
      final outcome = snapValue(4700, [0, 5000, 10000], 120);
      expect(outcome.value, 4700);
      expect(outcome.hit, isNull);
    });

    test('seuil nul ou candidats vides : aucun accrochage', () {
      expect(snapValue(5000, [5000], 0).hit, isNull);
      expect(snapValue(5000, const [], 120).hit, isNull);
    });
  });

  group('snapCandidates', () {
    test('contient bords, tête de lecture et temps ronds triés', () {
      final candidates = snapCandidates(
        durationMs: 12000,
        playheadMs: 3000,
        spans: [(startMs: 2000, endMs: 7000)],
      );
      expect(
        candidates,
        containsAll([0, 3000, 2000, 7000, 5000, 10000, 12000]),
      );
      final sorted = [...candidates]..sort();
      expect(candidates, sorted);
    });
  });
}
