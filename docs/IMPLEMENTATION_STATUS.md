# Implementation Status

## Completed
- [x] Git init (branche `main`)
- [x] Scaffold Flutter (Android/iOS/Web/Desktop)
- [x] Modèle GraceProject schema v1 + JSON roundtrip
- [x] Commandes undoables + CommandStack
- [x] Stockage atomique + recovery marker
- [x] Capabilities + profils export V1
- [x] Jev DecisionProvider + fallback local + mock labellisé
- [x] i18n FR/EN de base, thèmes dark/light, tokens
- [x] Navigation GoRouter + écrans Home/Editor/Export/Settings
- [x] Tests unitaires core (8/8) + analyse 0 erreur
- [x] Docs AUDIT + README

## In progress
- [ ] Import média réel (galerie/caméra) branché à l'éditeur
- [ ] Lecture vidéo réelle dans l'aperçu

## Blocked
- [ ] Export réel Media3 — nécessite code natif Kotlin (pas de blocage, prévu Phase 3)

## External dependencies
- [ ] Aucune clé/service externe requis pour la fondation (offline-first OK)

## Known limitations
- Export = simulation de progression (câblage Media3 à venir)
- Asset clip démo local au lieu d'un import galerie
- Pas de CI ni build release vérifié sur device

## Next autonomous task
- Brancher l'import réel (image_picker vidéo/image) + video_player dans l'éditeur,
  puis trim UI, puis sous-titres, puis export natif — dans cet ordre.
