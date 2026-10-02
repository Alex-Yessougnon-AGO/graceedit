# 22 — Creative Project Model

## Goal
Unify video editing, graphic design, audio, scenarios and campaign outputs under one editable project model.

## High-level structure
```json
{
  "schemaVersion": 2,
  "project": {
    "id": "project-id",
    "name": "Youth Conference",
    "brief": {},
    "brandKitId": "brand-id",
    "assets": [],
    "outputs": [],
    "creativeDirections": [],
    "timeline": {},
    "designScenes": [],
    "scripts": [],
    "storyboards": [],
    "settings": {}
  }
}
```

## Asset
An asset is a reusable reference to media or generated content. It should include type, source, dimensions/duration, location, provenance metadata, generation metadata where available and usage references.

## Output
An output represents a concrete deliverable: poster, video, thumbnail, social post, audio, etc. Multiple outputs may share one master brief and assets.

## Design scene
A graphic design scene contains a canvas and editable nodes. Nodes can be text, image, video, shape, icon or group, with transforms, styles and semantic roles.

## Campaign
A campaign links a brief to multiple deliverables and variants. Example:
- Poster 1080×1350
- WhatsApp status 1080×1920
- Instagram post 1080×1080
- 30-second video 1080×1920
- YouTube thumbnail 1280×720
- Caption

## Versioning
Every important AI transformation creates a reversible version or command. The user can compare, restore or fork a direction.

## Compatibility
The project model must remain platform-independent so the same creative project can eventually be opened on Android, iOS, desktop and web.
