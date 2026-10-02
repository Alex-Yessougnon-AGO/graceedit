# 18 — AI Creative Roles and Skill System

## Principle
GraceEdit can expose AI roles that behave like specialized members of a creative team. Each role is a structured competency profile rather than a single prompt.

## Initial role catalog
| Role | Main responsibility | Typical outputs |
|---|---|---|
| Creative Director | Objective, concept, creative direction | Creative brief/directions |
| Art Director | Visual language and composition | Moodboards/directions |
| Graphic Designer | Layout, typography, hierarchy | Posters/social graphics |
| Brand Designer | Brand consistency | Brand systems/variants |
| UX Designer | User flows and information architecture | Wireframes/flows |
| UI Designer | Interface visual design | Screens/components |
| Motion Designer | Motion language and timing | Animations/transitions |
| Video Editor | Rhythm and narrative assembly | Edited videos |
| Scriptwriter | Story, hooks and dialogue | Scripts/scenarios |
| Storyboard Artist | Visual planning | Storyboards/shot lists |
| Copywriter | Clear persuasive copy | Headlines/captions |
| Audio Designer | Voice, music, SFX direction | Audio plans |
| Thumbnail Designer | Attention + clarity without clickbait | Thumbnails |
| Social Content Strategist | Platform adaptation | Content variants |
| Quality Reviewer | Detect defects and weak decisions | Review report |

## Role package
Each role contains:
- mission;
- skills;
- principles;
- domain knowledge;
- tools;
- constraints;
- prompt/system instructions;
- output schemas;
- examples;
- anti-patterns;
- evaluation criteria;
- version.

## Example Graphic Designer competency
Skills: visual hierarchy, grid systems, typography, spacing, color roles, image cropping, composition, responsive adaptation and accessibility.

Anti-patterns: overcrowding, random gradients, excessive shadows, arbitrary font mixing, weak contrast, decorative elements with no purpose, misaligned objects and generic template repetition.

## Role orchestration
Roles communicate through structured artifacts:
Creative Director → Brief
Art Director → Direction
Graphic Designer → Composition
Copywriter → Copy
Quality Reviewer → Findings
Graphic Designer → Revision

This is preferable to unrestricted multi-agent conversation because outputs remain inspectable and testable.

## Custom roles
Advanced users may create a role with their own skills, prompt pack, examples and constraints. The system must validate role schemas and isolate permissions.
