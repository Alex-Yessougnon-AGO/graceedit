# 13 — Test Specification

## Layers
1. Unit.
2. Project model.
3. Commands/undo.
4. Rendering.
5. Media compatibility.
6. UI.
7. Integration.
8. End-to-end.
9. Accessibility.
10. UX usability.
11. Performance.
12. Crash/recovery.

## Beginner scenarios
- Import one video and save it.
- Make it shorter.
- Add text.
- Add subtitles.
- Improve it.
- Prepare for WhatsApp.
- Undo a change.

## Device matrix
At minimum:
- low RAM Android;
- mid-range Android;
- high-end Android;
- multiple screen sizes;
- supported Android versions;
- constrained storage.

## Media matrix
- MP4/H.264;
- H.265 where supported;
- MOV;
- portrait/landscape/square;
- 24/30/60fps;
- short/long recordings;
- large files;
- no audio;
- corrupted media.

## Thumbnail tests
- generation;
- representative frame;
- cache hit/miss;
- cancellation;
- low storage;
- corrupt source;
- URI source;
- timeline zoom;
- rapid scrolling.

## Export tests
- 720p;
- 1080p;
- 1080p60 where supported;
- future 4K/4K60/HDR;
- insufficient storage;
- unsupported codec;
- unsupported frame rate;
- cancellation;
- backgrounding;
- interrupted export;
- retry.

## Accessibility
TalkBack, large text, high contrast, reduced motion, touch targets, semantic labels and error comprehension.

## Recovery
Kill the app during import, thumbnail generation, editing, autosave and export. The project must remain recoverable and failed exports must not be shown as successful.

## Jev tests
- valid state;
- malformed state;
- low confidence;
- conflicting signals;
- timeout;
- unavailable;
- rate limit;
- fallback.

AI output must never bypass deterministic validation.

## Release gates
Do not ship if common imports fail, exports frequently fail, projects can be lost, undo is unreliable, thumbnails cause serious performance issues, or basic editing crashes low-end target devices.

## Future Creative Studio tests
### Graphic design
- Generated layouts remain editable.
- Text never silently overflows.
- Minimum readability/contrast rules are enforced.
- Brand Kit rules are respected.
- Multiple aspect-ratio variants preserve hierarchy.
- Template customization does not destroy required constraints.

### Generative media
- Generation jobs can be cancelled/retried.
- Failed provider jobs do not corrupt the project.
- Asset provenance/provider/model metadata is retained where available.
- Generated assets are cached without blocking the editor.

### Creative roles
- Role configuration is versioned.
- Prompt/skill changes are testable.
- Roles cannot bypass permission/security boundaries.
- Evaluation criteria are applied consistently.

### End-to-end creative workflow
Brief → direction → template/generation → assets → composition → quality checks → variants → export.
