# Écran 24 — Autorisation de notification (avant le premier export)

**ID** `SYS-05` · **Phase** V1 · **Route** feuille par-dessus `/export/:id` · **Déclencheur** premier appui sur « Exporter » dans `EXP-01`, **si** la version d'Android demande l'autorisation et qu'elle n'a pas encore été demandée · **Fichier** `sys05-notif-*`

## Contenu
Feuille de bas d'écran : titre « Être prévenu à la fin de l'export ? » ; texte « GraceEdit peut afficher la progression et vous prévenir quand la vidéo est prête. L'export fonctionne aussi sans notification. » ; actions **« Autoriser les notifications »** (principal → demande système) et **« Pas maintenant »** (texte).

## Règles
- **Demandée une seule fois** avant l'explication ; si l'utilisateur répond « Pas maintenant », ne pas redemander avant l'export suivant (maximum 2 fois, puis jamais).
- **Dans tous les cas, l'export démarre ensuite.** Cette feuille ne bloque jamais l'export.
- Si l'autorisation est refusée : la progression reste visible dans l'application (bandeau d'accueil et d'éditeur) ; aucune relance insistante.
- Sur les versions d'Android qui n'exigent pas cette autorisation : la feuille n'est **jamais** affichée.

## Accessibilité
Cibles tactiles d'au moins 48 dp ; états annoncés par le texte et par la forme, jamais par la couleur seule ; grandes polices (200 %) : le contenu défile, les boutons principaux restent fixés en bas ; contrastes à mesurer sur les valeurs finales.

## Notes d'implémentation
Vérifier l'état de l'autorisation avant d'afficher la feuille. Les contraintes des services d'exécution en avant-plan (obligation d'afficher une notification pendant un export long) sont **à vérifier dans la documentation Android** de la version visée.

## Points ouverts
Texte final ; nombre maximal de demandes.
