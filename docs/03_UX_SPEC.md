# 03 — UX Specification

## Core mental model
Traditional editors expose tools. GraceEdit exposes outcomes.

Instead of:
“Trim / LUT / Gain / Keyframe”

show:
“Make it shorter / Improve the picture / Improve the voice / Add words”.

## Two modes
### Create mode
For beginners:
- Create
- Improve
- Shorten
- Add words
- Add music
- Prepare for sharing

### Studio mode
For experts:
- Full timeline
- Tracks
- Inspector
- Effects
- Keyframes
- Audio
- Color
- Export

Both use the same project model and rendering engine.

## Progressive disclosure
Level 1: 3–5 obvious actions.
Level 2: common controls.
Level 3: advanced settings.
Level 4: Studio.

## Screen rule
Each screen should answer one question and have one dominant next action.

## Beginner workflow
1. Choose video.
2. Ask what the user wants.
3. Apply a safe recommendation.
4. Show preview.
5. Let the user undo.
6. Save/share.

## Onboarding
Do not use a long slideshow. Teach by doing:
- choose video;
- shorten it;
- add a title;
- preview;
- save/share.

## Language
Prefer:
- “Make it brighter”
- “Make the voice clearer”
- “Remove this part”
- “Add words”
- “Save my video”

Avoid technical terms until Studio.

## Thumbnails
Every media object should be recognizable visually.
A thumbnail must:
- load progressively;
- preserve aspect ratio;
- use a useful frame;
- never stretch;
- have a fallback.

## Accessibility
- 48dp minimum touch target.
- Larger primary controls.
- TalkBack labels.
- Large text support.
- High contrast.
- No color-only meaning.
- Gestures must have accessible alternatives.

## Automation trust
AI changes must show:
- what changed;
- before/after when relevant;
- undo;
- confidence or confirmation when uncertainty matters.

## UX test
Give a new user a phone and say:
> “Create a video ready to share on WhatsApp from this video.”

Do not explain the interface. Measure completion, time, errors, hesitation, questions and abandonment.
