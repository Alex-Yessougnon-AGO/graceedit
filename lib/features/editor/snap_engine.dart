/// Aimantation de la timeline (Étape 1, inspirée de CapCut/VN).
///
/// Fonction pure, sans état : étant donné une position cible et une liste
/// de candidats (en ms), elle renvoie la position aimantée si un candidat
/// est dans le seuil, sinon la cible inchangée. Le seuil est exprimé en ms
/// par l'appelant, qui le calcule depuis le zoom (8 dp à l'écran) : ainsi
/// l'aimantation se ressent de la même façon à tous les niveaux de zoom.
library;

/// Résultat d'une aimantation : [value] est la position à appliquer,
/// [hit] le candidat accroché (null si aucun).
typedef SnapOutcome = ({int value, int? hit});

/// Aimante [targetMs] sur le candidat le plus proche dans [thresholdMs].
SnapOutcome snapValue(int targetMs, List<int> candidates, int thresholdMs) {
  if (thresholdMs <= 0 || candidates.isEmpty) {
    return (value: targetMs, hit: null);
  }
  int? best;
  var bestDistance = thresholdMs + 1;
  for (final candidate in candidates) {
    final distance = (candidate - targetMs).abs();
    if (distance < bestDistance) {
      bestDistance = distance;
      best = candidate;
    }
  }
  if (best == null) return (value: targetMs, hit: null);
  return (value: best, hit: best);
}

/// Candidats d'aimantation d'un projet : début et fin du projet, tête de
/// lecture, bords de chaque élément (clips, textes, audios) et temps
/// ronds toutes les 5 secondes. Les doublons sont éliminés.
List<int> snapCandidates({
  required int durationMs,
  required int playheadMs,
  required List<({int startMs, int endMs})> spans,
}) {
  final values = <int>{0, durationMs, playheadMs};
  for (final span in spans) {
    values.add(span.startMs);
    values.add(span.endMs);
  }
  for (var second = 0; second <= durationMs; second += 5000) {
    values.add(second);
  }
  return values.toList()..sort();
}
