# GraceEdit — Production Documentation Pack

Version: 1.0 — 2026-10-01

GraceEdit is a mobile-first video creation assistant with a professional editor underneath. The primary UX goal is extreme simplicity for people with little or no editing knowledge, while preserving a Studio mode for experienced creators.

## Platform strategy
1. Android-first mobile MVP.
2. iOS next.
3. Desktop next.
4. Web last.

The project model, commands, templates and export-profile abstractions must be platform-independent from day one.

## Core principles
- Intent before tools.
- Simple by default, powerful on demand.
- Beginner-safe defaults.
- Undo everywhere.
- Non-destructive editing.
- Offline-first core editing.
- Thumbnails are first-class product objects.
- AI recommends/decides; deterministic code executes.
- Jev must never be a single point of failure.
- Export profiles must evolve from 720p/1080p to future 4K/60fps/HDR.
- Accessibility is a product requirement.
- Never expose technical terminology unless it helps the user.

## Documents
- 01_PRODUCT_BRIEF.md
- 02_PRD.md
- 03_UX_SPEC.md
- 04_INFORMATION_ARCHITECTURE.md
- 05_USER_FLOWS.md
- 06_SCREEN_INVENTORY.md
- 07_UI_DESIGN_SYSTEM.md
- 08_TECHNICAL_ARCHITECTURE.md
- 09_MEDIA_THUMBNAILS_EXPORT.md
- 10_JEV_AI_SPEC.md
- 11_ROADMAP.md
- 12_OPEN_SOURCE_LEGAL.md
- 13_TEST_SPEC.md
- 14_IMPLEMENTATION_PLAN.md
- 15_PRODUCT_DECISIONS.md
- 16_RESEARCH_SOURCES.md

## Important
This is a product/engineering plan, not legal advice. Before commercial distribution, audit the exact dependency versions, transitive dependencies, build flags, codecs, models, fonts, music, templates and trademarks.

## Extended vision — Creative Studio
GraceEdit is designed to evolve beyond video editing into a unified **AI Creative Studio**. Future releases may support:
- AI image generation and image editing;
- posters, flyers, social graphics, thumbnails and visual announcements;
- AI video generation, transformation and clip creation where providers/capabilities permit;
- voice, sound effects, music and other audio generation;
- scenario/script/storyboard generation;
- automatic assembly of generated and user-provided assets into coherent projects;
- presentation, UX/UI and visual-design assistance;
- specialized AI creative roles with explicit skills, constraints, workflows and prompt packs.

The goal is not to make every output look AI-generated. GraceEdit must optimize for **intent, hierarchy, typography, composition, readability, consistency and brand fit**. AI generation is only one step; composition and art direction are equally important.

See:
- 17_CREATIVE_STUDIO.md
- 18_AI_CREATIVE_ROLES.md
- 19_GENERATIVE_MEDIA_PIPELINE.md
- 20_GRAPHIC_DESIGN_SYSTEM.md
- 21_BRAND_KIT_AND_ASSET_LIBRARY.md
- 22_CREATIVE_PROJECT_MODEL.md
