# Implementation Status

## Completed
- [x] Git init (branche `main`) + commit fondation `feat(core)`
- [x] Scaffold Flutter (Android/iOS/Web/Desktop)
- [x] Modèle GraceProject schema v1 + JSON roundtrip
- [x] Commandes undoables + CommandStack
- [x] Stockage atomique + recovery marker
- [x] Capabilities + profils export V1
- [x] Jev DecisionProvider + fallback local + mock labellisé
- [x] i18n FR/EN de base, thèmes dark/light, tokens
- [x] Navigation GoRouter (splash → onboarding → permissions → home)
- [x] Phase 2 : Splash + Onboarding 3 pages + préférences + Permissions (avec mode invité)
- [x] Phase 2 : Import réel (galerie/caméra, vidéo/photo, durée probée) + lecture vidéo dans l'aperçu
- [x] Phase 2 : Thumbnails natifs (MediaMetadataRetriever via MethodChannel, cache invalidable)
- [x] Phase 2 : Bibliothèque d'assets (recherche, preview, suppression + invalidation)
- [x] Tests unitaires core + Phase 2 (11/11)
- [x] Docs AUDIT + README

## In progress
- [ ] Build APK release (lancé, en cours) puis installation sur TECNO BG6i
- [ ] Vérification `flutter analyze` 0 erreur (dernier état connu : 0 erreur, 2 warnings mineurs)

## Blocked
- [ ] Export réel Media3 — code natif Kotlin prévu Phase 3 (non bloquant)
- [ ] Téléphone déconnecté après restart serveur — à rebrancher pour installer/tester

## External dependencies
- [ ] Aucune clé/service externe requis (offline-first OK)

## Known limitations
- Export = simulation de progression (câblage Media3 Phase 3)
- Authentification : non implémentée (mode invité = défaut, décision documentée : pas de backend en V1)
- Pas de CI ni build release vérifié sur device (en cours)

## Next autonomous task
1. Finir build APK + installer sur device + test fumée (import → montage → save → reopen)
2. Puis Phase 3 : trim UI, volume/vitesse, sous-titres édition, réglages image, partage système, export natif Media3
3. Gate V1 → STOP, attendre instruction humaine avant Phases 4+
