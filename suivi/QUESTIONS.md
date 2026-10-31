# Questions pour le propriétaire du produit

À valider **plus tard** : l'agent a déjà avancé avec la valeur de départ indiquée. Ne bloque rien.

| N° | Date | Écran / sujet | Question | Valeur retenue en attendant | [IMPORTANT] ? | Réponse |
|---|---|---|---|---|---|---|
| 1 | 2026-10-24 | Export (tous) | Faut-il verrouiller l'écran allumé pendant l'export (`EXP-02`) ? La fiche le décrit, mais cela impose une dépendance supplémentaire à valider en licence (AGENTS.md §3.10). | Aucun verrouillage : l'export fonctionne sans, l'écran peut s'éteindre pendant le rendu. | [IMPORTANT] | |
| 2 | 2026-10-24 | Export | La fiche demande une marge sur la taille estimée pour le fichier temporaire de rendu (« valeur à fixer avec l'équipe technique »). Quelle marge ? | 8 % au-dessus du calcul (durée × débit du profil). | [IMPORTANT] | |
| 3 | 2026-10-24 | Lecture vidéo | Faut-il passer à la lecture 100 % native (Media3 ExoPlayer côté Kotlin) plutôt que `video_player` ? Media3 est déjà présent pour l'export. | `video_player` pour l'éditeur ; Media3 pour l'export. Unification possible, non faite pour limiter le périmètre. | | |
| 4 | 2026-10-24 | IMP-03 | Quelle version minimale d'Android viser ? `minSdk` suit aujourd'hui `flutter.minSdkVersion` (API 21). | API 21 ; l'écran `IMP-03` n'apparaît que si le sélecteur système échoue. | | |
| 5 | 2026-10-24 | Thème | L'application suit le thème du système par défaut (`AppThemeMode.system`). Faut-il forcer un thème au premier lancement ? | Thème système, modifiable dans `SET-01`. | | |
| 6 | 2026-10-30 | Lecture | Faut-il plafonner les médias à l'import (4K/HEVC refusé ou transcodé en proxy) ? Aujourd'hui tout `video/*` passe et l'aperçu lit l'original, ce qui rame sur les appareils modestes. | Aucun plafond : lecture de l'original via ExoPlayer, échec visible via « média manquant ». | [IMPORTANT] | |
| 7 | 2026-10-30 | Docs | `docs/graceedit/` (lecture seule) a été modifié par des sessions précédentes (9 fichiers + `RESTE_A_FAIRE.md` supprimé). Faut-il restaurer l'état `de1c8fa` ? | Laissé en l'état, écart consigné dans DECISIONS.md. | [IMPORTANT] | |
| 8 | 2026-10-30 | SaaS | Le demandeur évoque un SaaS rentable (comptes, synchronisation). Les règles §2bis/§3 l'interdisent en V1 (local, hors connexion, sans compte, aucun accès réseau). Confirmez-vous le périmètre V1 ? | Périmètre V1 inchangé : aucune fonction réseau, compte ou mesure ajoutée. | [IMPORTANT] | |
