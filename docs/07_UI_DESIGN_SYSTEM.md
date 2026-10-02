# 07 — UI Design System

## Visual direction
Soft, welcoming and friendly, but not childish. Premium enough for creators and organizations.

Qualities:
- calm;
- readable;
- warm;
- confident;
- uncluttered.

## Layout
- generous spacing;
- clear hierarchy;
- rounded surfaces where useful;
- large preview;
- contextual bottom sheets;
- obvious primary action.

Avoid dense icon grids and decorative UI that competes with media.

## Touch
48dp minimum interactive target; 52–56dp preferred for major actions.

## Typography
Use a highly legible sans-serif. Support large text without breaking the editor.

## Buttons
One dominant primary action per screen. Destructive actions are explicit.

## Project card
```text
[ THUMBNAIL ]
Sermon du dimanche
12:42
Modifié il y a 5 min
```

## Thumbnail rules
### Library/project
- project-canvas ratio;
- representative frame;
- duration badge;
- cached low-resolution image.

### Timeline
- adaptive density;
- progressive loading;
- visible range prioritized;
- no thousands of bitmaps in memory.

### Templates
- clear preview;
- no misleading unavailable assets.

## Semantic color tokens
background, surface, elevatedSurface, textPrimary, textSecondary, border, primary, success, warning, destructive, information.

## Motion
Use motion to communicate selection, progress and state changes. Keep it short.

## Accessibility
TalkBack, large text, high contrast, reduced motion, semantic labels and non-gesture alternatives.

## Beginner editor hierarchy
Preview > primary action > timeline > contextual controls.

## Studio hierarchy
Preview + timeline > inspector > secondary tools.

## Beginner rule
Normally:
- one question;
- 3–5 choices;
- one primary action.

## Expert rule
Studio can be dense, but labels and grouping remain clear.
