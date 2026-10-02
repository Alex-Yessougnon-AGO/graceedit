# 14 — Implementation Plan

## Phase 0
- Initialize Flutter repository.
- Configure linting/CI.
- Define module structure.
- Define project model.
- Define command model.
- Define storage.
- Define platform interfaces.
- Create license inventory.

## Phase 1 — Android media spike
- Media3 integration.
- Transformer integration.
- CameraX integration.
- Playback.
- Import.
- Metadata.
- Basic export.
- Hardware encoder tests.

## Phase 2 — Thumbnail engine
- Representative frame extraction.
- Project cover.
- Library thumbnails.
- Timeline frames.
- Cache.
- Background generation.
- Cancellation/invalidation.

## Phase 3 — Project/timeline
- Project.
- Asset.
- Clip.
- Track.
- Trim.
- Split.
- Delete.
- Reorder.
- Undo/redo.
- Autosave.

## Phase 4 — Beginner editor
- Preview.
- Contextual actions.
- Trim UI.
- Text.
- Basic subtitles.
- Music.
- Brightness.
- Contrast.
- Saturation.
- Crop.
- Rotate.

## Phase 5 — Export/share
- Export profiles.
- Capability detection.
- Progress.
- Cancel.
- Retry.
- Low-storage handling.
- Gallery.
- Android share sheet.

## Phase 6 — Templates
- Template schema.
- Recipe schema.
- Browser.
- Preview.
- Apply.
- Customize.
- Save.

## Phase 7 — Jev gateway
- Backend gateway.
- Server key.
- Structured state.
- Choice/Score/Noul.
- Confidence thresholds.
- Fallback.
- Feature flags.

## Phase 8 — Auto captions
- whisper.cpp.
- Model management.
- Transcription worker.
- Timestamps.
- Caption editor.
- Performance tests.

## Phase 9 — Smart editing
- Silence analysis.
- Highlight candidates.
- Auto-reframe.
- Auto enhancement.
- Short generator.
- Review workflow.

## Phase 10 — Studio
- Multi-track.
- Inspector.
- Transitions.
- Overlays.
- Keyframes.
- Color.
- Audio.

## Phase 11 — Pro export
- 1080p60.
- 1440p.
- 4K30.
- 4K60 where supported.
- HEVC.
- HDR.
- Export diagnostics.

## Phase 12 — iOS
- Swift media engine.
- AVFoundation.
- Camera.
- Export.
- Capability mapping.
- Shared schema.

## Phase 13 — Desktop
- Large-screen UX.
- Keyboard shortcuts.
- Persistent panels.
- Proxy media.
- Batch export.

## Phase 14 — Web
- WebCodecs spike.
- WASM media operations.
- Local storage.
- Browser compatibility.
- Optional cloud render.

## Agent implementation rules
1. Read relevant docs.
2. Implement one vertical slice.
3. Test.
4. Static analysis.
5. Build Android.
6. Run on emulator/device.
7. Capture screenshots.
8. Verify against screen inventory.
9. Update progress.
10. Continue only after the slice is stable.

## Definition of Done
Implemented + tested + accessible + recoverable + documented + integrated + loading/empty/error states + acceptable performance.

## Future Creative Studio implementation phases
### C1 — Creative core
- CreativeBrief model.
- CreativeProject model.
- Asset registry.
- BrandKit model.
- Structured design scene graph.
- Template schema with semantic slots and constraints.

### C2 — AI role system
- Role registry.
- Versioned skills.
- Prompt/system packs.
- Tool permissions.
- Output schemas.
- Evaluation criteria.

### C3 — Graphic Studio
- Poster/flyer editor.
- Social formats.
- Thumbnail editor.
- Template recommendations.
- AI layout assistance.
- Typography and brand checks.

### C4 — Generation providers
- Provider interfaces.
- Async job queue.
- Draft/final generation.
- Cancellation/retry.
- Asset provenance.
- Cost controls.

### C5 — Story-to-media
- Script.
- Storyboard.
- Shot list.
- Asset generation/import.
- Automatic video assembly.
- Campaign variants.

### C6 — Creative team orchestration
- Creative Director routing.
- Specialist role execution.
- Quality Reviewer.
- Human approval gates.
- Reversible revisions.

### C7 — UX/UI Studio
- Wireframe generation.
- UI composition.
- Design tokens.
- Responsive variants.
- Component/handoff metadata.
