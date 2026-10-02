# 15 — Product Decisions and Expert Recommendations

## 1. Thumbnails are core
They solve recognition, project recall, timeline comprehension, template discovery and export history.

Required surfaces:
- home project cards;
- projects library;
- media import review;
- template cards;
- timeline;
- export result/history;
- recent media.

## 2. Project cards are visual
Always show a meaningful thumbnail, name and duration.

## 3. Timeline must be visually understandable
Beginner:
```text
[frame][frame][frame][frame]
          ^
       playhead
```

## 4. Export complexity is progressive
Beginner:
> Recommended for WhatsApp

Advanced:
> 1080p / 30fps / quality

Future Studio:
> 4K / 60fps / HEVC / HDR

## 5. Design for 4K now, expose later
Project schema and ExportProfile abstraction support future 4K from the beginning. UI reveals it only when appropriate.

## 6. Capability-aware export
Show profiles according to:
- source;
- device encoder;
- storage;
- thermal/performance constraints;
- product policy.

## 7. AI is reversible
Recommendation → preview → user acceptance → deterministic command.

## 8. Offline-first
Basic editing does not require an account, subscription or Internet.

## 9. Beginner and expert share one product
Same project model, assets and engine. Different interaction layer.

## 10. Optimize for outcomes
Primary actions use verbs and goals: Create, Improve, Shorten, Add, Share.

## 11. Automation grows gradually
Recommendation → preview → one-tap → automatic workflows → automatic highlight creation.

## 12. Perceived speed matters
Use immediate previews, progressive thumbnails, background work and clear progress.

## 13. User must know what is happening
Every processing state explains:
- current operation;
- whether the project is saved;
- whether the operation can be cancelled.

## 14. Avoid AI everywhere
Use deterministic code for capability checks, file validation, basic adjustments and export. Use Jev for bounded judgment and routing.

## 15. GraceEdit should become a Creative Studio, not a pile of AI buttons
All future AI creation features should enter through a shared creative brief and project model.

## 16. Generation is not design
A raw AI image/video/audio output is an asset. Professional quality comes from direction, composition, typography, editing, adaptation and review.

## 17. Template-first when appropriate
For posters, social graphics and business/church communications, GraceEdit should often recommend an editable template before generating from scratch. This improves consistency, speed and controllability.

## 18. AI roles need real skills
“Graphic Designer” or “UX Designer” must represent a structured competency pack: principles, skills, tools, constraints, examples and evaluation criteria. Prompts are one implementation layer, not the whole architecture.

## 19. Never flatten editable work unnecessarily
A generated poster should remain editable as structured layers. A generated campaign should retain its script, scenes, assets, layouts and variants.

## 20. One brief, many outputs
A strong long-term workflow is:
Brief → concept → assets → master composition → variants.

For example, one church event brief can produce:
- announcement poster;
- Instagram post;
- WhatsApp status;
- 30-second video;
- YouTube thumbnail;
- caption;
- voice-over;
- story/reel version.

## 21. Anti-AI-look is a product requirement
Quality systems should penalize generic composition, excessive effects, poor typography, random decorative elements, inconsistent spacing and weak information hierarchy. The goal is intentional design, not maximal generation.

## 22. Brand memory
Brand Kit should persist colors, fonts, logos, tone, imagery preferences, spacing conventions and prohibited elements. AI must use this context when creating brand-bound assets.

## 23. Human approval at consequential steps
Users approve creative direction, expensive generation and final publishing/export when appropriate. Automatic actions remain reversible.
