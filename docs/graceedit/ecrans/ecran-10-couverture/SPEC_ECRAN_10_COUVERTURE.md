# Écran 10 — Choix de la couverture

**ID** : `EDT-07` · **Phase** : V1 · **Précédent** : `EDT-05` · **Suivant** : `EXP-01` (réglages d'export)
**Fichiers** : `edt07-image-*.png` (image de la vidéo), `edt07-galerie-*.png` (image de la galerie), clair et sombre, plus les `.svg` (1080 × 2400 px = 360 × 800 dp à 3x).

> Images, titres et durées sont des **exemples**.

## Rôle
Choisir l'image qui représente le projet. Elle sert de **miniature** dans l'accueil (`HOM-01`) et dans la liste des projets (`PRJ-01`). Le contexte du projet prévoit un sélecteur de couverture dans l'éditeur vidéo et l'usage de miniatures pour les projets.

## Entrée
- Outil **« Couverture »** de la barre d'outils générale de l'éditeur (`EDT-01`), placé après « Format ».
- Option : depuis les réglages d'export (`EXP-01`), voir « Points ouverts ».

## Règle par défaut
- Tant que l'utilisateur n'a rien choisi, la couverture est **automatique** : la première image de la vidéo. Elle se met à jour si le premier clip change.
- Dès qu'il valide un choix, la couverture devient **fixe**. Un lien « Revenir au choix automatique » est proposé dans le menu « Plus » de l'écran.
- L'utilisateur n'est **jamais obligé** d'ouvrir cet écran.

## Situation 1 — Image de la vidéo (`edt07-image-*`)

| Zone | Contenu | Règle |
|---|---|---|
| Barre supérieure | Fermer (annule, sans confirmation), « Couverture », « Terminé » | « Terminé » applique le choix en une seule action annulable. |
| Aperçu | L'image choisie, au format du projet, avec les textes affichés à cet instant | Ce que l'on voit est ce qu'on obtient (les titres sont inclus). |
| Choix de la source | « Image de la vidéo » / « Galerie » | La source active porte une coche, pas seulement une couleur. |
| Bande d'images | 8 vignettes réparties sur la durée du projet, avec un **cadre mobile** | Glisser le cadre ou toucher la bande déplace le choix. |
| Pastille de temps | « 1:10 » sous le cadre | Suit le cadre. |
| « Dans vos projets » | Miniature, titre et date, comme dans la liste réelle | Montre **l'usage réel** de la couverture, y compris son recadrage. |

- Le cadre mobile est en **accent vermillon** : dans l'éditeur, l'accent désigne une position de travail (comme la tête de lecture).
- Au relâchement du cadre, l'image exacte est extraite ; pendant le glissement, l'aperçu affiche l'image de vignette la plus proche, puis s'affine.

## Situation 2 — Image de la galerie (`edt07-galerie-*`)
- « Galerie » ouvre le **sélecteur d'images du système** (une image). L'application ne demande pas l'accès à toute la galerie.
- L'image remplit le format du projet. **Glisser** dans l'aperçu la déplace, **pincer** la zoome. Une étiquette « Glissez pour recadrer » l'indique.
- Ligne de résumé : miniature, « Image de la galerie », dimensions (« 1920 × 1080 »).
- Actions : « Choisir une autre image » (bouton avec contour, 48 dp) et « Utiliser une image de la vidéo » (bouton texte).
- L'image est **copiée dans le projet** (réduite à 1280 pixels de large au maximum) : la couverture ne peut donc jamais devenir un « média manquant ».

## États (non dessinés)
- **Vignettes en chargement** : blocs unis, sans animation de scintillement.
- **Échec d'extraction d'une image** : message « Impossible de lire cette image », avec « Réessayer ». La couverture précédente est conservée.
- **Image de galerie non prise en charge** : même traitement qu'à l'import (`IMP-02`), avec explication.
- **Vidéo très courte** : la bande est réduite au nombre de vignettes utiles.

## Valeurs de design
- Aperçu : région de 260 dp, fond `#0B0B0D`, image au format du projet centrée.
- Segments : conteneur 40 dp, actif plein avec coche (comme `EDT-05`).
- Bande d'images : 312 × 68 dp, rayon 8 dp ; cadre mobile 48 × 80 dp, trait de 3,5 dp en accent `#E2542B`, rayon 8 dp.
- Pastille de temps : 22 dp de haut, rayon 11 dp, couleur du texte principal avec texte inversé.
- Section « Dans vos projets » : même miniature (96 × 54 dp) et mêmes styles que `HOM-01`.

## Accessibilité
- Le cadre mobile est un **curseur ajustable** : « Image à 1 minute 10 secondes ». Actions « Avancer d'une seconde », « Reculer d'une seconde », « Image suivante », « Image précédente ».
- Zone tactile du cadre : au moins 48 dp de large (le cadre fait 48 dp).
- « Terminé », segments, boutons : au moins 48 dp de haut.
- L'aperçu a une description alternative (« Aperçu de la couverture à 1:10 »). La couleur d'accent n'est pas le seul signal : le cadre a une forme et la pastille donne le temps en toutes lettres.
- Contrastes : à mesurer sur les valeurs finales (étiquette sur l'aperçu, pastille de temps).
- Grandes polices : les libellés des segments passent sur deux lignes, l'écran défile.

## Performance (appareils modestes)
- Les 8 vignettes sont extraites **une seule fois**, en basse résolution, et mises en cache.
- L'image de couverture finale est générée en arrière-plan et enregistrée en 1280 px de large au maximum.
- Aucun effet d'ombre ni de flou.

## Points ouverts
- **Titre sur la couverture** (texte et mise en page) : non prévu en V1. Il relèverait plutôt d'un éditeur de miniatures plus riche (Phase 3). En V1, les textes de la vidéo visibles à l'instant choisi apparaissent déjà sur la couverture.
- **Enregistrer ou partager la couverture comme image** : utile pour publier. À décider avec `EXP-01` (pas dessiné).
- **Format de la miniature dans les listes** : j'ai gardé du 16:9 ; pour un projet vertical, la miniature recadre le centre de la couverture. L'aperçu « Dans vos projets » montre ce recadrage pour que l'utilisateur sache ce qui sera visible.
- **Nombre de vignettes** de la bande : 8 est une valeur de départ, à confirmer en test.
- **Mise à jour automatique** de la couverture lors de la modification du premier clip : à valider avec les utilisateurs.
