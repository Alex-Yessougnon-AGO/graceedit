# Écran 12 — Progression de l'export

**ID** : `EXP-02` · **Phase** : V1 · **Précédent** : `EXP-01` · **Suivants** : `EXP-03` (réussite et partage), `EXP-04` (échec ou annulation)
**Fichiers** : `exp02-progression-*.png`, `exp02-annulation-*.png`, `exp02-notification-*.png` (la notification est une carte seule), clair et sombre, plus les `.svg` (1080 × 2400 px = 360 × 800 dp à 3x pour les écrans).

> Titres, durées et pourcentages sont des **exemples**.

## Principe
Un export est un calcul long. L'écran doit rester **honnête** (une vraie progression, jamais une animation simulée), **annulable** avec confirmation (le brief l'exige) et **non bloquant** : l'utilisateur doit pouvoir faire autre chose.

## Situation 1 — Progression (`exp02-progression-*`)

| Zone | Contenu | Règle |
|---|---|---|
| Barre supérieure | Flèche vers le bas (réduire), « Export en cours » | La flèche équivaut à « Continuer en arrière-plan ». |
| Récapitulatif | Couverture, titre, qualité et format | Rappelle ce qui est exporté. |
| Étape et progression | Nom de l'étape, pourcentage, barre de 8 dp | Voir « Étapes et progression ». |
| Détails | « Étape 2 sur 3 », « Écoulé : 1 min 12 s » | Le temps écoulé est un fait. |
| Information | « Vous pouvez quitter cet écran : l'export continue en arrière-plan… » | Vraie seulement si l'export tourne en arrière-plan (voir « Arrière-plan »). |
| Actions | « Continuer en arrière-plan » (principal, 56 dp), « Annuler l'export » (bouton texte, 48 dp) | L'annulation est visible mais discrète, pour éviter l'appui accidentel. |

### Étapes et progression
1. **Préparation** : vérification des médias, plan de rendu. Barre **indéterminée**, sans pourcentage.
2. **Création de la vidéo** : rendu. Pourcentage **réel**, calculé à partir des images déjà produites.
3. **Vérification** : contrôle du fichier et enregistrement dans la galerie. Barre indéterminée.

Règles : le pourcentage ne **recule jamais** ; il n'affiche **jamais 100 %** avant la fin de la vérification ; on n'invente pas de pourcentage pour une étape qu'on ne peut pas mesurer.
Le **temps restant** n'est pas affiché : il varie trop selon l'appareil. Si un test montre un besoin, on l'affichera avec « environ » et seulement quand l'estimation est stable.

## Situation 2 — Confirmation d'annulation (`exp02-annulation-*`)
- Le brief demande explicitement une confirmation d'annulation. C'est la seule fenêtre de ce parcours.
- Titre « Annuler l'export ? ». Texte : l'export en cours (42 %) sera perdu, **le projet n'est pas modifié**, on peut exporter de nouveau.
- **Action par défaut, la plus sûre** : « Continuer l'export » (bouton plein). « Annuler l'export » est en couleur d'erreur. Le geste Retour sur la fenêtre = continuer l'export.
- Après annulation : retour aux réglages `EXP-01` avec les mêmes choix, fichiers temporaires supprimés, message « Export annulé » (voir `EXP-04`).

## Situation 3 — Notification (`exp02-notification-*`)
- Carte de notification avec le nom du projet, l'étape et le pourcentage, une barre de progression et l'action **Annuler**.
- Toucher la notification ouvre cet écran. L'action « Annuler » demande la même confirmation (ouverture de l'application sur la fenêtre de confirmation).
- À la fin, la notification devient « Export terminé » avec l'action « Partager » (`EXP-03`).
- Canal de notification de faible importance : pas de son pendant la progression.
- Sur les versions d'Android qui demandent l'autorisation d'envoyer des notifications, l'export **doit fonctionner même si elle est refusée** ; la progression reste alors visible dans l'application (bandeau d'accueil et d'éditeur). Les contraintes exactes d'un service d'exécution en avant-plan sont à vérifier dans la documentation Android.

## Arrière-plan et édition pendant l'export
- **Continuer en arrière-plan** (ou la flèche) ramène à l'accueil. Un **bandeau « Export en cours »** reste visible dans l'accueil, la liste des projets et l'éditeur ; le toucher rouvre cet écran.
- **Pendant l'export, le projet exporté est verrouillé** (lecture seule) et le bandeau l'explique. Les autres projets restent modifiables. Alternative à étudier : exporter une copie figée du projet pour permettre de continuer à le modifier, au prix de la mémoire et du stockage (voir « Points ouverts »).
- L'écran garde l'écran **allumé** tant qu'il est affiché.

## Interruptions (non dessinées)
- **Application fermée par le système, redémarrage, batterie à plat** : à la réouverture, le projet n'est pas perdu ; `EXP-04` explique que l'export a été interrompu et propose « Recommencer ».
- **Espace disque épuisé en cours de rendu** : échec géré par `EXP-04`, avec la cause.
- **Appareil qui chauffe, économiseur de batterie** : le rendu ralentit. Message non bloquant sous la barre : « L'export est plus lent car l'appareil chauffe. »
- **Retour dans l'application** : l'écran se resynchronise avec l'état réel, sans recommencer.

## Valeurs de design
- Couverture : 312 × 176 dp, rayon 16 dp, badge de durée.
- Barre de progression : 8 dp de haut, piste arrondie, remplissage couleur du texte principal. Pas d'accent vermillon (l'accent désigne une position de travail dans l'éditeur).
- Titre d'étape et pourcentage : 16 sp semi-gras. Détails : 14 sp couleur secondaire.
- Fenêtre : 312 dp de large, rayon 28 dp, voile de 45 %, titre 22 sp, texte 15 sp, bouton plein de 52 dp, action destructive en bouton texte.
- Notification : carte du système ; icône de l'application sur disque, titre 14 sp, détail 13 sp, barre de 4 dp.

## Accessibilité
- La barre est un **indicateur de progression** avec sa valeur. La progression est annoncée par **paliers de 10 %** (zone vivante polie), jamais en continu. Les changements d'étape sont annoncés : « Étape 2 sur 3, création de la vidéo ».
- Le pourcentage est écrit en texte : l'avancement ne dépend pas de la couleur.
- Dans la fenêtre de confirmation, le focus va d'abord à « Continuer l'export » ; le focus reste dans la fenêtre.
- Cibles : 56 dp et 48 dp. La flèche de réduction a une zone de 48 dp et un nom explicite : « Continuer en arrière-plan ».
- Grandes polices : les lignes de détail passent sur deux lignes, la page défile, les boutons restent fixés en bas.

## Performance
- Le rendu utilise l'encodeur matériel de l'appareil quand il existe.
- L'interface se met à jour **au plus une fois par seconde** ; la barre n'a pas d'animation décorative.
- Aucun flou, aucune ombre.

## Points ouverts
- **Verrouiller le projet pendant l'export, ou exporter une copie figée.** Le verrou est plus simple et plus léger ; la copie est plus confortable. Recommandation V1 : le verrou.
- **Reprise après interruption** : recommencer à zéro en V1 ; la reprise au milieu est un objectif ultérieur.
- **Autorisation de notification** : moment et formulation de la demande (par exemple au premier export, avec une explication courte). Écran d'explication non dessiné.
- **Temps restant estimé** : non affiché ; à réexaminer après tests sur appareils modestes.
- **Plusieurs exports en parallèle** : non prévus en V1 (un seul export à la fois).
