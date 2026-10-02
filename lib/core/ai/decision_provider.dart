/// Jev = decision/orchestration engine, NOT the renderer.
/// GraceEdit must work without Jev via deterministic fallbacks.
/// API keys stay server-side; the app only sees typed decisions.
library;

/// Typed decision returned by Jev (or by the local fallback).
class JevDecision<T> {
  const JevDecision({
    required this.kind, required this.value,
    this.confidence = 1.0, this.explanation = '', this.fallbackUsed = false,
  });
  final String kind;
  final T value;
  final double confidence;
  final String explanation;
  final bool fallbackUsed;
}

abstract class DecisionProvider {
  Future<JevDecision<String>> chooseTemplate({
    required String brief, required List<String> candidates,
  });
  Future<JevDecision<String>> recommendExportProfile({
    required int sourceWidth, required int sourceHeight,
    required List<String> candidates,
  });
  Future<JevDecision<String>> chooseSubtitleStyle({required String brief});
}

/// Deterministic local fallback — always available offline.
class LocalFallbackDecisions implements DecisionProvider {
  @override
  Future<JevDecision<String>> chooseTemplate({
    required String brief, required List<String> candidates,
  }) async {
    if (candidates.isEmpty) {
      return const JevDecision(kind: 'template', value: '', fallbackUsed: true);
    }
    return JevDecision(
      kind: 'template', value: candidates.first,
      confidence: 0.5,
      explanation: 'Fallback local : premier template compatible.',
      fallbackUsed: true,
    );
  }

  @override
  Future<JevDecision<String>> recommendExportProfile({
    required int sourceWidth, required int sourceHeight,
    required List<String> candidates,
  }) async {
    final vertical = sourceHeight > sourceWidth;
    final pick = vertical
        ? (candidates.contains('vertical1080x1920') ? 'vertical1080x1920' : candidates.firstOrNull ?? '')
        : (candidates.contains('p1080') ? 'p1080' : candidates.firstOrNull ?? '');
    return JevDecision(
      kind: 'exportProfile', value: pick, confidence: 0.6,
      explanation: 'Fallback local : orientation source.',
      fallbackUsed: true,
    );
  }

  @override
  Future<JevDecision<String>> chooseSubtitleStyle({required String brief}) async =>
      const JevDecision(
        kind: 'subtitleStyle', value: 'classic', confidence: 0.5,
        explanation: 'Fallback local : style classique lisible.',
        fallbackUsed: true,
      );
}

/// Abstraction for generative providers (image/video/audio/STT/TTS).
/// Real providers come later; V1 ships a clearly-labelled mock.
enum GenerationStatus { queued, running, succeeded, failed, cancelled }

class GenerationResult {
  const GenerationResult({required this.assetPath, this.metadata = const {}});
  final String assetPath;
  final Map<String, dynamic> metadata;
}

abstract class GenerationProvider {
  String get id;
  String get displayName;
  bool get isMock;
  Future<GenerationResult> generate({required String prompt, Map<String, dynamic> options = const {}});
}

/// Clearly-labelled dev mock — never presented as real AI output.
class MockGenerationProvider implements GenerationProvider {
  @override String get id => 'mock';
  @override String get displayName => 'Mock local (dev)';
  @override bool get isMock => true;
  @override Future<GenerationResult> generate({
    required String prompt, Map<String, dynamic> options = const {},
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return GenerationResult(
      assetPath: '',
      metadata: {'mock': true, 'prompt': prompt},
    );
  }
}
