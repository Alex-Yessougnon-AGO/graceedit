# Écran 05 — Éditeur vidéo, mode Simple

**ID** : `EDT-01` · **Phase** : V1 · **Précédents** : `IMP-02`, `HOM-01` · **Suivants** : `EDT-02` à `EDT-07`, `EXP-01`
**Fichiers** : `edt01-aucune-*.png` (aucun clip sélectionné), `edt01-selection-*.png` (un clip sélectionné), clair et sombre, plus les `.svg` (1080 × 2400 px = 360 × 800 dp à 3x).

> Les images, titres, durées et la musique sont des **exemples**. Les images sont des illustrations plates qui remplacent de vraies images de vidéos.

## Principe
Un **seul éditeur** pour le mode Simple et le mode Studio. Le mode Studio (Phase 2) ne change pas l'architecture de l'écran : il augmente la densité (plus de voies visibles, panneau de propriétés). Rien dans cet écran ne doit être jeté pour passer à Studio.

Trois idées structurent l'écran, inspirées de ce que font les éditeurs mobiles reconnus et de mes recherches précédentes :
1. **Aperçu en haut, timeline au milieu, outils en bas** : les outils sont à portée du pouce.
2. **Barre d'outils contextuelle** : peu d'outils quand rien n'est sélectionné, des outils propres au clip quand un clip l'est. Le brief demande de n'afficher que les commandes utiles à la tâche en cours.
3. **Tête de lecture fixe au centre** : la timeline défile sous elle, ce qui permet de cadrer précisément une image avec un doigt.

## Structure (de haut en bas)

| Zone | Contenu | Dimensions |
|---|---|---|
| Barre supérieure | Retour, nom du projet, **état de sauvegarde**, bouton « Exporter » | 56 dp |
| Aperçu | Vidéo au format du projet, centrée, bandes sombres si le format diffère | Région fixe de 260 dp de haut |
| Ligne de lecture | Temps courant / durée totale, lecture-pause, annuler, rétablir | 48 dp |
| Timeline | Règle, voie vidéo, voie texte, voie audio, tête de lecture | Règle 22 dp, voie vidéo 72 dp, autres voies 40 dp |
| Barre d'outils | Outils généraux ou outils du clip sélectionné | 80 dp, icône 24 dp, libellé 12 sp |

La région d'aperçu a une hauteur fixe : la mise en page ne saute pas quand on change de format (vertical, carré, horizontal).

## État A — aucun clip sélectionné
Barre d'outils défilante horizontalement. Le dernier outil est volontairement coupé à droite pour montrer qu'on peut défiler.

| Outil | Rôle | Écran |
|---|---|---|
| Ajouter | Ouvre le sélecteur de médias, ajoute à la fin (ou à la tête de lecture) | `IMP-01` |
| Audio | Musique, voix off, volume général | `EDT-04` |
| Texte | Ajoute un titre à la tête de lecture | `EDT-03` |
| Ajuster | Luminosité, contraste, saturation | `EDT-05` |
| Format | Vertical, carré, horizontal | `EDT-05` |

## État B — un clip sélectionné
La barre du bas **remplace** la barre générale. Un chevron à gauche permet de revenir aux outils généraux.

| Outil | Rôle |
|---|---|
| Scinder | Coupe le clip sélectionné à la tête de lecture |
| Volume | Volume du clip |
| Cadrer | Recadrer, pivoter, retourner |
| Supprimer | Retire le clip (voir « Suppression ») |
| Plus | Dupliquer et autres actions secondaires, à définir |

Le clip sélectionné reçoit un **contour épais et deux poignées** de rognage à ses extrémités, plus un badge de durée. La sélection est donc portée par la forme et pas par la couleur seule.

## Gestes
- **Toucher un clip** : le sélectionne. **Toucher une zone vide de la timeline** : désélectionne.
- **Faire glisser la timeline** : déplace la tête de lecture. **Pincer** : change le zoom.
- **Glisser une poignée** : rogne le clip. Pendant le rognage, l'aperçu montre l'image rognée (indépendante de la tête de lecture) et le temps change en direct.
- **Appui long puis glisser un clip** : le déplace. L'alternative sans glisser est l'action d'accessibilité « Déplacer vers la gauche / la droite ».
- **Aimantation** : la poignée ou le clip s'aimante à la tête de lecture et aux bords des autres clips, avec un léger retour haptique.
- **Zones tactiles** : les poignées font 14 dp de large à l'écran, mais leur zone tactile fait au moins 48 dp, étendue au-delà du clip.
- **Densité des miniatures** : elle s'adapte au zoom et à la durée du clip. Elle ne charge que les miniatures visibles.

## Suppression
- Pas de fenêtre de confirmation : une barre d'annulation « Clip supprimé · Annuler » apparaît quelques secondes. L'annulation est préférable aux boîtes de dialogue, que le brief déconseille.
- Par défaut, l'espace est refermé (les clips suivants avancent). Décision à confirmer.
- Supprimer le dernier clip laisse une timeline vide avec une invitation à ajouter des médias.

## Annuler et rétablir
- Deux boutons de 48 dp dans la ligne de lecture, donc à portée de la timeline.
- « Rétablir » est affiché atténué quand il n'y a rien à rétablir, et déclaré désactivé aux lecteurs d'écran. L'atténuation n'est pas le seul signal : l'état est aussi annoncé.

## Sauvegarde et sortie
- **Sauvegarde automatique** après chaque modification, à la mise en arrière-plan et à la sortie. L'utilisateur n'a aucune action à faire.
- Texte d'état sous le nom : « Enregistré » (coche) · « Enregistrement… » · « Non enregistré » (avertissement, avec action « Réessayer ») · « Brouillon récupéré ».
- **Retour** : revient à l'accueil sans confirmation si l'état est « Enregistré ». Si la dernière sauvegarde a échoué, une fenêtre explique le problème et propose « Réessayer » ou « Quitter sans enregistrer ».
- **Exporter** : toujours visible en haut à droite. Désactivé si la timeline est vide.

## Voies de la timeline
- La voie vidéo existe toujours. Les voies **texte** et **audio** n'apparaissent que lorsqu'elles contiennent un élément (divulgation progressive).
- Si plusieurs éléments texte se chevauchent dans le temps, l'éditeur Simple les empile sur une voie supplémentaire. Voir « Points ouverts ».

## Valeurs de design
- Fond de l'aperçu : `#0B0B0D` dans les deux thèmes (la vidéo est toujours vue sur fond neutre sombre).
- **Tête de lecture** : accent `#E2542B`, ligne de 2 dp et tête ronde de 10 dp. L'accent est réservé à la position de lecture dans cet écran.
- Éléments texte et audio : fond `#D9D2C3` (clair) ou `#3A3C45` (sombre). Voie audio : fond de surface, ondes en couleur secondaire.
- Barre d'outils : même fond que la barre de navigation de `HOM-01`.
- Poignées et contour de sélection : couleur du texte principal.
- Échelle de départ : 1,2 dp par seconde, avec zoom.

## Accessibilité
- **Timeline sans glisser** : actions d'accessibilité « Clip précédent », « Clip suivant », « Avancer d'une seconde », « Reculer d'une seconde », « Rogner le début de 0,1 s », « Rogner la fin de 0,1 s ».
- Le temps courant est une valeur ajustable avec incréments, annoncée « 1 minute 10 secondes sur 4 minutes 10 ».
- Cibles tactiles : boutons de la barre supérieure et de la ligne de lecture 48 dp, outils 64 à 76 dp de large.
- L'état de sauvegarde est lisible (texte), jamais seulement une couleur.
- Grandes polices : les libellés d'outils passent sur deux lignes, la barre d'outils défile. La timeline garde sa taille.
- Contrastes : à mesurer sur les valeurs finales, notamment le texte du titre sur son fond sombre semi-transparent.

## Performance (appareils modestes)
- Aperçu de modification à résolution réduite, rendu final uniquement à l'export.
- Miniatures de timeline générées à la demande, en cache, selon le niveau de zoom.
- Aucune ombre ni flou, pas d'animation de décor. Seuls la tête de lecture et la barre d'annulation s'animent.

## États non dessinés ici
Lecture en cours (le bouton devient pause, la barre d'outils reste) · timeline vide · rognage en cours · clip dont le média est manquant (le clip affiche l'avertissement, l'aperçu propose « Reconnecter ») · élément texte sélectionné · sauvegarde échouée · récupération après fermeture inattendue · paysage et tablette (aperçu à gauche, timeline en dessous).

## Points ouverts
- **Suppression avec fermeture de l'espace** : à confirmer (est-ce toujours le bon comportement ?).
- **Éléments texte qui se chevauchent** : empiler automatiquement ou l'interdire en mode Simple.
- **Annuler après réouverture** : conserver l'historique entre deux sessions, ou le limiter à la session en cours.
- **Contenu de « Plus »** : dupliquer, détacher l'audio, vitesse. Vitesse et filtres ne sont pas classés dans le plan.
- **Accès à Studio** : aucune bascule en V1 (une commande morte serait trompeuse). L'emplacement prévu est le menu de la barre supérieure, à ajouter en Phase 2.
- **Mise en page en paysage** : à dessiner dans le lot des états.
