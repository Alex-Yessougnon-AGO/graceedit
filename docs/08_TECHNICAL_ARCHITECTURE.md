# 08 — Technical Architecture

## Stack

### Shared/mobile UI
- Flutter
- Dart
- Riverpod
- GoRouter
- Material 3

### Android media
- Kotlin
- AndroidX Media3
- Media3 Transformer
- CameraX
- MediaCodec
- GPU/OpenGL where needed

### Future intelligence
- Jev
- whisper.cpp
- MediaPipe
- ONNX Runtime

## Architecture

```text
Flutter UI
  |
  +-- Presentation
  +-- State
  +-- Navigation
  |
  v
GraceEdit Core
  |
  +-- Project Model
  +-- Commands
  +-- Undo/Redo
  +-- Templates
  +-- Recipes
  +-- Export Profiles
  |
  v
Platform Interface
  |
  +-- Android/Kotlin
  |    +-- Media3
  |    +-- CameraX
  |    +-- MediaCodec
  |    +-- GPU
  |
  +-- Future iOS/Swift
  +-- Future Desktop
  +-- Future Web
```

## Project model
```json
{
  "schemaVersion": 1,
  "project": {
    "id": "project-id",
    "name": "My project",
    "canvas": {"width": 1080, "height": 1920, "fps": 30},
    "tracks": [],
    "assets": [],
    "settings": {}
  }
}
```

## Commands
AddClip, RemoveClip, SplitClip, TrimClip, MoveClip, AddText, EditText, AddSubtitle, EditSubtitle, AddAudio, SetVolume, AddEffect, RemoveEffect, SetCanvas, AddTransition, SetSpeed.

Every command must be serializable, undoable and testable.

## Storage
- Original media remains in device storage.
- Generated thumbnails/proxies use app cache.
- Project metadata uses structured local storage.
- Autosave uses atomic writes.

## Recovery
Maintain last stable state and recovery marker. On relaunch, offer restore rather than silently discarding work.

## Platform abstraction
Define:
MediaPlayer, ThumbnailProvider, FrameExtractor, VideoRenderer, AudioRenderer, CameraController, Exporter, CapabilityProvider.

## Capability detection
Expose:
- supported resolutions;
- supported frame rates;
- hardware encoders;
- codecs;
- HDR support;
- storage availability.

Never assume all Android devices support the same export profiles.

## Offline-first
Editing, thumbnails, preview and export are local. Jev is optional.

## Security
Jev API key must remain server-side. The mobile app talks to a GraceEdit gateway.

## Backend future
- auth;
- billing;
- Jev gateway;
- template catalog;
- cloud sync;
- analytics;
- feature flags.

Basic editing must not depend on the backend.

## Cross-platform
Share:
- project schema;
- commands;
- templates;
- UX rules.

Keep rendering implementations platform-specific.

## Future Creative Intelligence Architecture

```text
User Intent
   ↓
Creative Brief
   ↓
Creative Director / Role Router
   ↓
Creative Plan
   ├── Copy
   ├── Layout
   ├── Storyboard
   ├── Asset Plan
   ├── Audio Plan
   └── Output Variants
        ↓
Generation Providers / Local Models / User Assets
        ↓
Asset Registry + Provenance
        ↓
Deterministic Composition Engine
        ↓
Quality Gates
        ↓
Editable Creative Project
        ↓
Export / Publish
```

### Provider abstraction
Never hard-code GraceEdit to one image/video/audio generation provider. Define interfaces such as:
- ImageGenerationProvider
- ImageEditingProvider
- VideoGenerationProvider
- VideoTransformationProvider
- SpeechGenerationProvider
- MusicGenerationProvider
- Embedding/SearchProvider
- DesignAnalysisProvider

Providers can be cloud APIs, local models or future platform-native services.

### Creative role architecture
A role should be represented by structured data, not only a giant prompt:
```json
{
  "id": "graphic_designer",
  "skills": ["layout", "typography", "color", "visual_hierarchy"],
  "principles": ["clear_hierarchy", "balanced_spacing", "legibility"],
  "tools": ["template_search", "image_generation", "layout_engine"],
  "constraints": ["brand_kit", "safe_margins", "contrast"],
  "evaluation": ["readability", "hierarchy", "brand_fit"]
}
```

Prompt packs can exist as one layer of the role, but structured skills/constraints must remain machine-readable so the system can validate outputs.

### Editable design representation
Graphic designs must not be stored only as PNG/JPEG. Use a structured scene graph with:
- canvas;
- frames/containers;
- text nodes;
- image/video nodes;
- shapes;
- effects;
- transforms;
- constraints;
- style tokens;
- semantic roles;
- asset references.

This allows AI-generated posters to remain editable like real design files.

### Quality gates
Before presenting a generated design as finished, run deterministic or model-assisted checks for:
- text overflow;
- unreadable text;
- insufficient contrast;
- unsafe margins;
- inconsistent spacing;
- hierarchy problems;
- accidental clipping;
- incorrect aspect ratio;
- missing required brand elements.

### Cost and performance
Generation jobs must be asynchronous, resumable and cancellable. Preview/low-resolution generation should be possible before expensive final generation.
