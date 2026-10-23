# Écran 03 — Accueil

**ID** : `HOM-01` · **Phase** : V1 · **Variantes** : `HOM-01A` (avec projets), `HOM-01B` (aucun projet) · **Précédent** : `ENT-02`
**Fichiers** : `hom01-recents-*.png`, `hom01-vide-*.png` (1080 × 2400 px = 360 × 800 dp à 3x), clair et sombre, plus les `.svg` correspondants.

> Les miniatures et les titres sont des **exemples** : les images sont des illustrations plates qui remplacent de vraies images de vidéos.

## Rôle
Permettre en un geste de reprendre le dernier travail ou d'en commencer un nouveau. L'utilisateur doit toujours voir où il est et ce qu'il peut faire.

## Décision de navigation (révision d'une proposition précédente)
J'avais proposé une barre « Accueil · Projets · Créer ». Je la remplace par **Accueil · Projets · Réglages**, pour deux raisons :
- Une barre de navigation contient des destinations, pas des actions. « Créer » est une action : elle devient le bouton **« Nouveau projet »**.
- Une barre doit avoir au moins trois destinations. Avec Accueil et Projets seulement, elle serait vide de sens.

Les destinations **Modèles** et **Bibliothèque** s'ajouteront à leur phase (maximum 5 destinations), sans refonte. L'écran de choix d'intention s'ouvrira depuis « Nouveau projet » quand plusieurs intentions existeront. En V1, « Nouveau projet » ouvre directement le sélecteur de médias du système, puis l'écran `IMP-02`.

## Variante HOM-01A — avec projets

| Zone | Contenu | Règle |
|---|---|---|
| Barre supérieure | Symbole + logotype, à gauche | Aucune action en V1 : pas de recherche globale, de notifications ni de profil tant que ces fonctions n'existent pas. |
| « Reprendre » | Le projet modifié le plus récemment, miniature 16:9 (312 × 176 dp), titre, date de modification | Toute la zone est cliquable. Ouvre l'éditeur **à l'état sauvegardé** : position de lecture, zoom de la timeline, élément sélectionné. |
| « Récents » | Liste de lignes de 68 dp : miniature 96 × 54 dp, titre, date | Jusqu'à 5 projets, hors celui du haut. « Tout voir » ouvre `PRJ-01`. Section absente s'il n'y a qu'un seul projet. |
| Bouton « Nouveau projet » | Bouton flottant étendu, 56 dp, en bas à droite | Reste au-dessus de la liste qui défile. |
| Barre de navigation | 80 dp, libellés toujours visibles | « Accueil » actif. |

**Gestion des projets** (renommer, dupliquer, supprimer) : pas sur cet écran. Elle se fait depuis Projets, avec des actions visibles. Un appui long sur une ligne n'est pas assez découvrable.

**Dates** : « il y a 2 h » pendant 24 h, « Hier », puis jour et mois selon la langue (« 12 oct. »).

## Variante HOM-01B — aucun projet
- Emplacement 16:9 en pointillés avec un « + » : il remplace la miniature du premier projet et est cliquable (même action que le bouton).
- Titre « Créez votre premier projet », une phrase d'explication.
- La mention « Vos projets sont enregistrés automatiquement sur ce téléphone » dépend de l'enregistrement automatique prévu par le contexte du projet.
- **Le bouton flottant est masqué** : le bouton « Monter une vidéo » en bas remplit ce rôle. Pas deux boutons pour la même action.
- Cette variante est celle où arrive l'utilisateur qui a choisi « Explorer d’abord » dans `ENT-02`.

## États d'une ligne de projet

| État | Miniature | Texte | Action |
|---|---|---|---|
| Normal | Image de la vidéo + durée en badge | Titre, date | Ouvre l'éditeur |
| Miniature en chargement | Bloc de surface uni, sans animation | Titre, date | Ouvre l'éditeur |
| Miniature non générée (média présent) | Bloc de surface neutre, icône neutre | Titre, date | Régénération automatique en arrière-plan |
| **Média manquant** (dessiné) | Bloc de surface + icône d'avertissement | Titre, « Média manquant » en couleur d'erreur **avec icône** | Ouvre l'écran de reconnexion du média (`PRJ-05`), pas l'éditeur |

Le badge de durée sert aussi à ne jamais confondre une miniature avec le fichier vidéo. Il faut distinguer un **média manquant** (erreur à corriger) d'une **miniature absente** (simple défaut d'affichage, sans alarme).

## États à traiter ailleurs (non dessinés ici)
- Espace de stockage faible : bandeau sous la barre supérieure, visible seulement sous le seuil défini, avec l'action « Gérer ».
- Projet récupéré après une fermeture inattendue : le projet du haut indique « Brouillon récupéré ».
- Hors connexion : aucun changement, l'accueil fonctionne hors ligne.
- Chargement de la liste : la mise en page est affichée immédiatement, les lignes arrivent sans écran de chargement séparé.

## Valeurs de design (ajouts au thème de `ENT-02`)

| Élément | Clair | Sombre |
|---|---|---|
| Fond de la barre de navigation | `#EDE7DB` | `#1D1F25` |
| Indicateur de l'onglet actif | `#D9D2C3` | `#3A3C45` |
| Erreur (texte et icône) | `#B3261E` | `#F2B8B5` |
| Pointillés de l'état vide | `#9A968D` | `#6B6D75` |

Texte : titre de section 20 sp semi-gras, titre de projet 16 à 18 sp semi-gras, date 14 sp, libellés de navigation 12 sp. Icônes sur une grille de 24 dp, trait de 2 dp. Grille 8 dp, marges latérales de 24 dp.

## Accessibilité
- Lecture d'une ligne : « Match de quartier, 2 minutes 15, modifié hier ». Le badge de durée fait partie de cette phrase, il n'est pas lu à part.
- L'erreur ne passe jamais par la couleur seule : icône + texte « Média manquant ».
- Cibles : ligne 68 dp, bouton flottant 56 dp, navigation 80 dp. « Tout voir » doit avoir une zone cliquable d'au moins 48 dp de haut, au-delà de la taille du texte.
- Grandes polices : les titres de ligne passent sur deux lignes, les miniatures gardent leur taille, la page défile. Le bouton flottant se réduit à son icône « + » (avec libellé pour lecteur d'écran) si le texte ne tient plus.
- Contrastes : à confirmer avec un outil de mesure sur les valeurs finales, en particulier le texte secondaire et la couleur d'erreur.

## Performance (appareils modestes)
- Miniatures mises en cache et chargées à la **taille d'affichage**, pas en pleine résolution.
- Pas de flou, d'ombre portée ni d'animation de chargement. Les blocs de chargement sont statiques.
- Liste paresseuse : seules les lignes visibles chargent leur miniature.

## Points ouverts
- **Seuil de stockage faible** : à fixer avec l'équipe technique.
- **Nombre de lignes de « Récents »** : 5 est une valeur de départ, à confirmer en test.
- **Illustrations de la maquette** : à remplacer par de vraies miniatures dans les tests utilisateur.
