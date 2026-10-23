# Écran 18 — Stockage et cache

**ID** `SET-02` · **Phase** V1 · **Route suggérée** `/settings/storage` · **Accès** `SET-01` ; bandeau « Espace faible » (`SYS-03`) ; échec d'export par manque d'espace (`EXP-04`) · **Fichiers** `set02-liste-*`, `set02-vider-*`

## Rôle
Montrer ce que GraceEdit occupe et permettre de libérer de l'espace **sans jamais toucher aux vidéos de l'utilisateur**.

## Contenu
- **Total** « GraceEdit utilise 1,8 Go » (32 sp) + **barre segmentée** de 4 parts (cache et miniatures, projets, exports non enregistrés, corbeille).
- **Légende** : une ligne par part avec carré (4 niveaux d'opacité) **et** libellé **et** taille. L'information ne repose pas sur la couleur.
- Lignes d'action :
  - **Cache et miniatures** + bouton « Vider » → fenêtre de confirmation (`set02-vider-*`).
  - **Exports non enregistrés** (vidéos créées mais refusées par la galerie, voir `EXP-04`) + « Gérer » → liste des fichiers avec « Enregistrer sous… » et « Supprimer ».
  - **Corbeille** « 3 projets » → `/projects/trash`.
- **Espace libre sur le téléphone** : valeur + barre.

## Comportements
- **Vider le cache** : supprime miniatures, aperçus et fichiers temporaires **recréables**. Les projets, les médias d'origine et les exports ne sont **jamais** supprimés. Après l'action : message « Cache vidé » et le total est recalculé.
- La fenêtre de confirmation a « Vider le cache » en bouton principal (action non destructive pour le travail de l'utilisateur) et « Annuler » en bouton texte.
- Les tailles se recalculent à l'ouverture et au retour dans l'application (calcul asynchrone ; afficher un état « Calcul… » sans scintillement).

## États
Normal · confirmation · calcul en cours · cache déjà vide (bouton désactivé « Vider », texte « Rien à vider ») · espace libre critique (bandeau d'alerte en haut, même style que `SYS-03`).

## Accessibilité
Cibles tactiles d'au moins 48 dp ; états annoncés par le texte et par la forme, jamais par la couleur seule ; grandes polices (200 %) : le contenu défile, les boutons principaux restent fixés en bas ; contrastes à mesurer sur les valeurs finales. La barre segmentée est décorative ; la légende textuelle porte l'information.

## Notes d'implémentation
Calcul des tailles par parcours des dossiers de l'application, hors thread d'interface. Prévoir une API `StorageRepository` (taille du cache, des projets, des exports en attente, de la corbeille).

## Points ouverts
Seuil de « stockage faible » ; durée de conservation des exports non enregistrés.
