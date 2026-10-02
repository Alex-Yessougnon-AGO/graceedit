# 02 — Product Requirements Document

## Scope
P0 = Android MVP. P1 = first major release. P2 = advanced/AI. P3 = future platforms.

## Core entities
User, Project, MediaAsset, VideoClip, AudioClip, TextLayer, SubtitleTrack, Effect, Transition, Template, Recipe, ExportJob, ExportProfile, Thumbnail, ProjectHistory, BrandKit, AIRecommendation.

## Media
### P0
- Import video/images/audio.
- Multiple selection.
- Preserve originals.
- Read metadata.
- Create project thumbnail.
- Generate media thumbnails asynchronously.
- Unsupported-media explanation.

## Camera
### P0
- Record video/audio.
- Preview.
- Retake.
- Save to project.
### P1
- Front/rear camera, torch where supported, capture quality options.

## Playback
P0: play/pause, seek, duration, mute, fullscreen, scrubbing, frame preview.

## Timeline
### P0
- Primary video track.
- Audio track.
- Text/subtitle layer.
- Trim, split, delete, reorder.
- Undo/redo.
- Snap.
- Timeline zoom.
### P1
- Multi-track, overlays, transitions.
### P2
- Keyframes, masks, blend modes, speed curves.

## Thumbnails — P0
- Project cover.
- Library/media thumbnail.
- Template thumbnail.
- Timeline strip thumbnails.
- Loading/error/fallback states.
- Local cache.
- Background generation.
- No blocking the editor.

## Text — P0
Text, font, size, weight, color, alignment, position, background, duration.
P1: presets, animation, brand fonts.

## Subtitles
P0: manual subtitles, SRT import, styling.
P1: automatic captions.
P2: word timing, caption cleanup, emphasis.

## Audio
P0: music, volume, mute, trim, fades, voice-over.
P1: speech enhancement, noise reduction, ducking.
P2: EQ, compressor, limiter, loudness matching.

## Visual adjustments
P0: brightness, contrast, saturation, crop, rotate, basic filters.
P1: temperature, tint, highlights/shadows.
P2: curves, LUTs.

## Templates/Recipes
P0:
- Sermon
- Testimony
- Worship
- Announcement
- Bible verse
- Quote
- Social short

A template is a project configuration, not just a pre-rendered video.

## Smart assistant
P1: format, template, enhancement, subtitle style and export recommendations.
P2: highlights, silence reduction, auto-reframe, one-tap short creation.

## Export
### P0
MP4, H.264 where supported, AAC where supported, 720p, 1080p, 24/30fps, 9:16, 16:9, 1:1.
### P1
1080p60 where supported, quality/size presets.
### P2
1440p, 4K UHD, 4K30, 4K60 where supported, HEVC/H.265, HDR where supported.
### P3
Professional codecs/workflows only if justified.

The UI must be capability-aware. Never promise 4K60 just because the device is Android.

## Project persistence
P0: autosave, recovery, rename, duplicate, delete, continue editing.
P1: archive/export project.
P3: cloud sync.

## Non-functional requirements
- Responsive UI while processing.
- Hardware-accelerated preview/export when available.
- Never load full large videos into RAM.
- Clear errors and recovery.
- 48dp minimum interactive target; 52–56dp preferred for major actions.
- Editing/export works without Internet.
- Jev API key never ships in the client.

## Acceptance principle
Every feature must answer:
> Can a beginner discover it, understand it, undo it and recover from mistakes?

## Future Creative Studio — P3/P4 scope
The following capabilities are intentionally outside the Android MVP but must be considered in the architecture.

### AI creation
- Text-to-image briefs.
- Image-to-image/editing workflows where supported.
- Text-to-video or storyboard-to-video workflows where supported.
- Text-to-speech/voice-over.
- Music and sound-effect generation where legally and technically available.
- Script, scenario, hook, storyboard and shot-list generation.
- Thumbnail and poster generation.

### Creative assembly
A user can describe an outcome such as:
> “Create a 30-second church youth-event announcement for WhatsApp and Instagram.”

GraceEdit should be able to produce a structured creative plan:
- objective;
- audience;
- message;
- tone;
- visual direction;
- copy;
- scene/shot plan;
- required assets;
- typography;
- colors;
- composition;
- audio direction;
- output formats.

The plan is reviewed before expensive generation when appropriate.

### AI creative roles
The system may expose specialized roles such as:
- Creative Director
- Graphic Designer
- Art Director
- UX Designer
- UI Designer
- Motion Designer
- Video Editor
- Scriptwriter
- Storyboard Artist
- Copywriter
- Brand Designer
- Audio Designer
- Thumbnail Designer
- Social Content Strategist

A role is a controlled configuration containing skills, design principles, tools, constraints, evaluation criteria and prompt/system instructions. Roles must not be treated as unrestricted autonomous agents.

### Template intelligence
Templates become structured editable systems with:
- semantic slots;
- layout constraints;
- typography rules;
- color roles;
- image/video placeholders;
- animation rules;
- responsive variants;
- industry/category metadata;
- quality and accessibility checks.

AI may recommend or customize templates instead of generating everything from zero.

### Professional poster workflow
Brief → choose industry/audience → select or generate creative directions → preview 3–5 directions → select direction → generate/find assets → compose → typography/layout checks → user refinement → export variants.

### UX/UI design assistance
Future GraceEdit may generate wireframes, design directions, UI layouts, component suggestions and design-system tokens. Any generated UI remains editable and must expose structure rather than only exporting a flat image.
