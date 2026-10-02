# 10 — Jev AI Specification

## Role
Jev is GraceEdit's structured decision layer, not the renderer.

Current official Jev documentation describes:
- State;
- Choice;
- Score;
- Noul;
- probabilities/confidence;
- parallel questions.

Current input boundary: text, JSON objects and arrays of text. Image/audio/video are not currently direct inputs.

Source: https://thejevai.com/docs

## Architecture
```text
Media
 -> local media/audio analysis
 -> optional transcript
 -> structured state
 -> GraceEdit backend
 -> Jev
 -> typed decision
 -> deterministic GraceEdit action
```

## Decision services
- ContentClassifier
- FormatSelector
- EnhancementLevel
- RemoveSilence
- SubtitleStyleSelector
- TemplateMatcher
- ExportAdvisor
- WorkflowRouter

## Example state
```json
{
  "durationSeconds": 732,
  "width": 1920,
  "height": 1080,
  "brightnessScore": 0.32,
  "speechRatio": 0.78,
  "silenceRatio": 0.18,
  "audioLevelDb": -23,
  "faceDetected": true,
  "orientation": "landscape",
  "userIntent": "share on WhatsApp"
}
```

## Example decisions
```text
contentType = sermon
enhancement = light
subtitle = yes
subtitleStyle = high-contrast
ratio = 9:16
music = no
```

## Confidence policy
Initial product hypothesis:
- >=0.85: automatic recommendation;
- 0.65–0.84: recommendation + confirmation;
- <0.65: ask the user.

These thresholds must be validated with real product data.

## Safety
Jev must never perform irreversible changes. Its output becomes a reversible command after deterministic validation.

## Offline fallback
If Jev is unavailable:
- deterministic rules continue;
- manual workflow remains available;
- editing/export is not blocked.

## Security
Never put the Jev API key in the mobile application. Use a server-side gateway.

## Cost
Send only the smallest structured state required. Never send raw video just to classify a workflow.

## Future agent use
Jev can also support bounded development decisions such as test completeness or release readiness, but it must not bypass permissions or deployment controls.

## Jev in the future Creative Studio
Jev remains the **decision and routing layer**, not the generator and not the design renderer.

Potential decision services:
- CreativeIntentRouter
- CreativeRoleSelector
- TemplateMatcher
- DesignDirectionSelector
- LayoutStrategySelector
- AssetStrategySelector
- GenerationProviderSelector
- CopyVariantSelector
- VideoStructurePlanner
- StoryboardStrategy
- BrandComplianceDecision
- FormatVariantSelector
- RegenerationStrategy

### Example
A user says:
> “Je veux une affiche professionnelle pour une conférence de jeunes de mon église, moderne mais sobre.”

The pipeline can become:
1. classify intent;
2. select Graphic Designer + Art Director roles;
3. build a structured brief;
4. choose template-first vs generation-first;
5. propose visual directions;
6. generate/find required assets;
7. compose deterministically;
8. run quality checks;
9. ask for approval or refinement;
10. export variants.

Jev should decide bounded choices from structured state. It should not receive raw media unless the current Jev product explicitly supports that input in the future.

## Role prompt architecture
Prompt packs should be versioned assets:
- system principles;
- role expertise;
- domain knowledge;
- constraints;
- examples;
- anti-patterns;
- output schema;
- evaluation rubric.

A prompt alone is not a substitute for deterministic layout, typography and accessibility validation.
