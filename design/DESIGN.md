# GraceEdit — DESIGN.md (source of truth, formalized from shipped Flutter UI)

Brief confirmé : Product UI · formalize existing UI · foundations + core components.

## Foundations

### Color — light
| Token | Value | Usage |
|---|---|---|
| `background` | #FAF8F4 | app backdrop (warm paper) |
| `surface` | #FFFFFF | cards, bars |
| `elevated` | #F3EFE8 | pressed / grouped surfaces |
| `textPrimary` | #1C1A17 | headings, body |
| `textSecondary` | #6E675E | captions, hints |
| `border` | #E5DFD5 | hairlines, card outlines |
| `primary` | #2F5D3A | primary actions, selection |
| `onPrimary` | #FFFFFF | text on primary |
| `success` | #2F7D4F | confirmations |
| `warning` | #B7791F | cautions |
| `destructive` | #B3261E | delete, errors |
| `info` | #2B6CB0 | neutral notices |

### Color — dark (designed, not inverted)
| Token | Value |
|---|---|
| `background` | #141210 |
| `surface` | #1E1B18 |
| `elevated` | #2A2521 |
| `textPrimary` | #F5F1EA |
| `textSecondary` | #A8A094 |
| `border` | #38322C |
| `primary` | #8FBC8F |
| `onPrimary` | #142114 |
| `success` | #7FBF8E |
| `warning` | #D9A441 |
| `destructive` | #E57373 |
| `info` | #7FB3E0 |

### Typography (system sans, optical discipline)
- Display 26–32 / tight leading 1.1 / tracking −0.01em, w700 — screen titles, hero numbers
- Title 20 / 1.2 / 0, w700 — section headers, dialog titles
- Body 16 / 1.5 / 0, w400–600 — primary content
- Caption 13–15 / 1.4 / 0, secondary color — metadata, hints
- Never fixed letter-spacing across sizes; body scales with system text size (rem-based).

### Spacing / radius / elevation
- Spacing scale: 4 · 8 · 16 · 24 · 32 · 48
- Radius: 8 (chips, small) · 12 (buttons, tiles) · 16 (cards, sheets content) · 24 (hero surfaces)
- Elevation: flat-first. Borders over shadows. One shadow level for floating sheets only.

### Motion (Emil + Apple house style)
- `:active` press feedback `scale(0.97)`, 100–160ms, `cubic-bezier(0.23,1,0.32,1)`
- Enter: ease-out 150–250ms from `scale(0.95)+opacity 0` — never from `scale(0)`
- Sheets/modals: 250–400ms, symmetric enter/exit path, scrim for modal tasks
- Stagger list entrances 30–80ms; never block interaction during stagger
- `prefers-reduced-motion`: cross-fade/static only, no slide/spring/parallax
- Touch: hover states gated behind `@media (hover:hover) and (pointer:fine)`

## Core components & rules
- **Buttons**: one dominant primary per screen (min 48×52). Destructive explicit, never disguised.
- **Inputs**: 12px radius, 16/14 padding, visible border, real labels (no placeholder-only).
- **Chips**: contextual editor actions; disabled state visible, never silently dead.
- **Cards**: 1px border, 0 elevation; media cards carry duration badge + representative thumbnail.
- **Sheets**: contextual tools (trim/speed/filters); one question, one primary action.
- **Dialogs**: confirm only destructive/irreversible; everything else undoable inline.
- **Bottom nav**: 5 destinations max, labels always visible.
- **Timeline**: 110px clips, selected = 2px primary ring; thumbnails = representative frame (never first frame by default); density adapts to zoom; reorder with velocity-aware drag.
- **States**: every async surface ships loading / empty / error / offline / denied variants. Errors name the cause + offer retry. Nothing fails silently.
- **Accessibility**: 48dp targets (52–56 preferred for primary), contrast AA, TalkBack labels on icon-only controls, logical focus order, color never the only signal.
- **Anti-patterns**: purple gradients, star-sprinkled "AI" buttons, floating decorative cards, glow effects, lorem ipsum, dead buttons.

## Screen hierarchy
- Beginner: Preview > primary action > timeline > contextual controls.
- Studio: Preview + timeline > inspector > secondary tools.
- Editor is a dedicated workspace, not an app page.
