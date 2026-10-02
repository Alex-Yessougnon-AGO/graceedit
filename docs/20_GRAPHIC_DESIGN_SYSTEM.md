# 20 — AI Graphic Design System

## Objective
Enable non-designers to create professional posters, flyers, thumbnails and social graphics without requiring them to understand every design principle.

## Template-first strategy
The system should first determine whether a structured template can satisfy the request. If yes, recommend several directions and customize them. Generation from scratch is used when it provides a meaningful advantage.

## Design primitives
- Grid
- Margins
- Safe zones
- Containers
- Alignment
- Spacing scale
- Typography hierarchy
- Color roles
- Image crops
- Shape language
- Iconography
- Motion rules

## Semantic typography
Templates should define roles such as:
- Display
- Headline
- Subheadline
- Body
- Metadata
- CTA

The system chooses size/weight/line-height from a design system rather than arbitrary values.

## Anti-AI quality rules
A design should be reviewed for:
- unnecessary visual noise;
- generic decorative elements;
- excessive glow/3D effects;
- poor type pairing;
- inconsistent spacing;
- weak alignment;
- unreadable text over imagery;
- overuse of gradients;
- fake-looking imagery when realism is required;
- unclear focal point;
- too many competing CTAs.

## Professional adaptation
One master design can produce platform variants while preserving hierarchy:
- 1:1
- 4:5
- 9:16
- 16:9
- print dimensions where supported

## Editable output
Every generated design should preserve layers and semantic roles whenever possible. Users can replace images, edit text, change colors and resize without regenerating the whole design.
