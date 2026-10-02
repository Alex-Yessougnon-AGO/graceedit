# GraceEdit — execution state (reprise sans réexpliquer)

- Phase actuelle : Phase 2 core TERMINÉE (code) ; en attente = build APK + test device.
- Tâches terminées : fondation (commit bd3c395) + splash/onboarding/permissions,
  import réel galerie+caméra, lecture vidéo aperçu, thumbnails natifs Kotlin
  (MediaMetadataRetriever, plugin maison — video_thumbnail abandonné car
  incompatible AGP : utilisait jcenter()), bibliothèque assets, 11 tests OK.
- Tâches en cours : `flutter build apk` lancé en fond ; reste install + test fumée.
- Tâches bloquées : téléphone déconnecté (restart serveur) — l'utilisateur doit
  rebrancher/reconnecter adb ; export natif Media3 = Phase 3.
- Décisions : pas d'auth backend en V1 (mode invité par défaut) ; thumbnails
  natifs maison plutôt que plugin abandonné ; permissions avec mode dégradé,
  jamais d'échec silencieux.
- Tests exécutés : `flutter test` 11/11 OK ; `flutter analyze` dernier état 0 erreur.
- Bugs connus : aucun bloquant.
- Prochaines tâches : install APK → test fumée → Phase 3 (trim UI, audio,
  sous-titres, réglages image, partage, export Media3) → Gate V1 → STOP.
- Version/checkpoint : Phase 2 code v0.2.0 (pas encore installable vérifié).
- Migrations/actions manuelles : rebrancher le téléphone (`adb devices` vide au
  dernier check) puis `adb install` ou `flutter install -d <id>`.
