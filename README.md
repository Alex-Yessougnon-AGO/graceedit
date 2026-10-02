# GraceEdit

Plateforme de création assistée par IA — montage vidéo simple + Studio pro,
Creative Studio (affiches, thumbnails, campagnes), direction artistique,
Brand Kit, génération média via providers abstraits, orchestration Jev.

> V1 cible (cf `docs/GRACEEDIT_MASTER_AUTONOMOUS_TASKS.md`) : éditeur vidéo
> utilisable de bout en bout — import → montage → sauvegarde/recovery →
> export réel — FR/EN, dark/light, offline-first.

## Stack

- Flutter 3.47 / Dart 3.13, Material 3
- Riverpod (state), GoRouter (navigation)
- Android natif à venir : Media3 Transformer, CameraX
- Architecture : `lib/core` (modèle projet, commandes undoable, stockage
  atomique, capabilities, providers IA/Jev) + `lib/features` (home, editor,
  export, settings) + `lib/theme` (tokens dark/light)

## Démarrer

```bash
flutter pub get
flutter test
flutter run
```

## Installer l'app (Android)

- **Depuis GitHub** : page Releases → télécharge `app-release.apk` → ouvre le
  fichier sur le téléphone → autorise l'installation → c'est tout.
- **En dev** : branche le téléphone (débogage USB ou sans fil), puis
  `flutter run -d <device-id>`.

Chaque tag `v*` poussé sur GitHub déclenche le workflow `.github/workflows/release.yml`
qui build et attache l'APK à la release automatiquement.

## Modèle projet

`GraceProject` (schema v1) : metadata, canvas, assets, clips vidéo,
textes, sous-titres. Mutations uniquement via `ProjectCommand`
(`AddClip`, `TrimClip`, `SplitClip`, `MoveClip`, `RemoveClip`) avec
undo/redo — voir `lib/core/commands/commands.dart`.

Stockage : écritures atomiques (tmp + rename), marker `.recovery` pour
reprise après crash — voir `lib/core/storage/project_repository.dart`.

## Jev / IA

`DecisionProvider` + `LocalFallbackDecisions` (offline, déterministe).
Clés API uniquement côté serveur. `MockGenerationProvider` clairement
identifié comme mock — jamais présenté comme réel.

## Docs

- `docs/00_README.md` → `22_*.md` : brief produit, archi, design system…
- `docs/GRACEEDIT_MASTER_AUTONOMOUS_TASKS.md` : plan maître d'exécution
- `docs/IMPLEMENTATION_AUDIT.md`, `docs/IMPLEMENTATION_STATUS.md` : suivi

## État

Fondation (Phase 0–1) en place. Voir `.opencode/graceedit-execution-state.md`.
