# Implementation Audit — GraceEdit (2026-10-02)

## État actuel
- Repo initialisé le 2026-10-02 (`main`). Avant : uniquement `docs/` (23 docs produit).
- Scaffold Flutter 3.47 créé (Android, iOS, Web, Linux, Windows, macOS).
- Fondation implémentée en une passe (Phase 0–1) :
  - `lib/core/models/grace_project.dart` : GraceProject schema v1, canvas presets,
    assets, clips, textes, sous-titres, sérialisation JSON roundtrip testée.
  - `lib/core/commands/commands.dart` : Add/Remove/Trim/Split/Move + CommandStack
    undo/redo, testés.
  - `lib/core/storage/project_repository.dart` : save atomique, load, list,
    delete, marker recovery, fichiers corrompus ignorés.
  - `lib/core/platform/capabilities.dart` : DeviceCapabilities + ExportProfile
    (720p/1080p/vertical/carré) filtrés par capacité réelle.
  - `lib/core/ai/decision_provider.dart` : DecisionProvider, LocalFallbackDecisions
    (offline), GenerationProvider + MockGenerationProvider labellisé mock.
  - `lib/core/l10n/strings.dart` : FR/EN, aucun texte UI en dur dans les widgets.
  - `lib/core/state/providers.dart` : Riverpod (projects, editor session, theme, locale).
  - `lib/theme/tokens.dart` : tokens dark/light conçus séparément.
  - `lib/app.dart` + GoRouter : `/`, `/settings`, `/editor/:id`, `/export/:id`.
  - Écrans : Home (récents + création), Editor simple (preview, timeline
    réordonnable, split/trim-ready, texte, undo/redo, autosave, choix profil
    export), Export (validation + progression + retry), Settings (thème, langue).
- Tests : `test/core_test.dart` — 8 tests OK (modèle, commandes, capabilities, Jev fallback).
- Analyse : 0 erreur (1 warning mineur + infos).

## Risques
- Export = simulation de progression ; câblage Media3 Transformer natif restant (Phase 3).
- Import réel (galerie/caméra via image_picker) non encore branché à l'éditeur
  (asset démo local utilisé pour valider la timeline).
- Pas de CI, pas de build release testé sur device.

## Fonctionnalités terminées / partielles / absentes
- Terminé : fondation produit (Phase 1 du master, sauf i18n date/heure complète).
- Partiel : Phase 2 core (onboarding/permissions/caméra/asset library/thumbnails
  manquants) ; Phase 3 V1 (lecture vidéo réelle, trim UI, audio, sous-titres,
  réglages image, partage système manquants).
- Absent : Phases 4–12 (Studio avancé, templates, Creative Studio, AI, campaign,
  brand, UX/UI Studio, pro export, hardening).

## Ordre recommandé (prochaine session)
1. Import réel (image_picker + file_picker vidéo/image) + lecture vidéo
   (video_player) dans l'éditeur.
2. Trim UI + volume/vitesse + suppression bruit de fond éditeur.
3. Sous-titres (modèle déjà là → édition + styles + export incrusté/séparé).
4. Câblage Android Media3 Transformer (export réel) + partage système.
5. Onboarding + permissions + autosave/recovery vérifié de bout en bout.
6. Gate V1 : parcours import→montage→save→reopen→export, dark/light, release build.
