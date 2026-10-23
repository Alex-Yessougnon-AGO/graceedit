# Écran 06 — Rogner et scinder

**ID** : `EDT-02` · **Phase** : V1 · **Précédent** : `EDT-01` · **Suivants** : `EDT-03` (texte), `EDT-04` (audio)
**Fichiers** : `edt02-rognage-*.png`, `edt02-scission-*.png`, `edt02-precis-*.png`, clair et sombre, plus les `.svg` (1080 × 2400 px = 360 × 800 dp à 3x).

> Cet écran n'est pas une nouvelle page : ce sont trois **situations de l'éditeur** (`EDT-01`) qui détaillent le geste le plus fréquent du montage. L'ossature de l'écran reste identique. Images, durées et titres sont des **exemples**.

## Situation 1 — Rognage en cours (`edt02-rognage-*`)
L'utilisateur fait glisser la poignée de **fin** du deuxième clip vers la gauche.

- **Poignée active** : plus large (18 dp au lieu de 14) et en accent vermillon. Dans l'éditeur, l'accent désigne une position de travail (tête de lecture, poignée active).
- **Partie retirée** : affichée atténuée et cernée de pointillés, à sa place d'origine. L'utilisateur voit ce qu'il enlève et peut le récupérer en revenant en arrière sans lâcher.
- **Bulle d'information** au-dessus de la poignée : « −0:58 » (durée retirée) et « Durée 1:17 » (nouvelle durée du clip). La bulle est placée **au-dessus** du doigt pour ne pas être masquée.
- **Aimantation** : la ligne en pointillés verticale montre que la poignée s'est accrochée à la fin de l'élément texte. Un léger retour haptique accompagne l'accroche.
- **Aperçu** : il montre l'**image à la poignée** (ici, la dernière image conservée), avec l'étiquette « Fin du clip », et non l'image sous la tête de lecture. Le temps affiché (« 2:05 / 3:12 ») suit la poignée et la durée totale reflète déjà le rognage.
- **Tête de lecture** : masquée pendant le geste, car elle n'a plus de sens tant que l'aperçu suit la poignée.
- **Clip suivant** : reste à sa place pendant le geste (l'écart montre ce qui va se refermer). À la fin du geste, il avance et ferme l'espace.
- **Barre d'outils du clip** : inchangée.

## Situation 2 — Après une scission (`edt02-scission-*`)
L'utilisateur a touché « Scinder » avec la tête de lecture à 1:50.

- Le clip se coupe **en deux clips indépendants**, séparés par un petit écart visible à la position de la tête de lecture.
- **La sélection reste sur la partie de gauche** (l'original), avec son badge de durée (« 1:02 »). La barre d'outils du clip reste affichée, de sorte que l'utilisateur peut enchaîner (par exemple « Supprimer »).
- La **barre d'annulation** « Clip scindé · Annuler » apparaît pendant quelques secondes, au-dessus de la barre d'outils. Il n'y a pas de fenêtre de confirmation : une scission est réversible.
- **Scinder sans clip sélectionné** : l'outil « Scinder » n'est visible que lorsqu'un clip est sélectionné. Si la tête de lecture est sur la limite exacte de deux clips, ou hors de tout clip, l'action est désactivée avec une explication (« Placez la tête de lecture à l'intérieur du clip »).
- **Éléments liés** : les éléments texte et audio ne sont pas coupés en deux. Seuls les clips vidéo ou image le sont.

## Situation 3 — Rognage précis (`edt02-precis-*`)
Une feuille de bas d'écran non modale permet de régler **Début** et **Fin** au pas de **0,1 seconde**, avec des boutons « − » et « + ».

- **Pourquoi** : c'est l'alternative au glisser pour les personnes qui ne peuvent pas glisser, et l'outil de précision pour tous. Le brief exige une alternative accessible aux gestes de glissement.
- **Accès** : depuis le menu « Plus » de la barre d'outils du clip, et via l'action d'accessibilité « Rogner précisément » sur les poignées.
- **Non modale** : l'aperçu et la voie vidéo restent visibles et utilisables au-dessus de la feuille, et se mettent à jour à chaque pas.
- **Valeurs** : format « m:ss,d » avec la virgule décimale en français. Un appui long sur « − » ou « + » répète le pas.
- **Limites** : le début ne peut pas dépasser la fin moins une image, la fin ne peut pas dépasser la durée du média. Un bouton qui atteint sa limite est désactivé (atténué et annoncé comme désactivé).
- **Fermeture** : « Terminé ». L'ensemble des réglages est **une seule action d'annulation**.

## Règles communes
- **Précision** : la poignée avance par image (selon le débit de la vidéo) pendant le geste. Un zoom fort de la timeline augmente la précision du doigt.
- **Annulation** : chaque rognage, scission ou réglage précis est une action annulable. Annuler une scission réunit les deux clips en un.
- **Zone tactile des poignées** : 48 dp de large au minimum, étendue au-delà du clip, même si la poignée visible fait 14 dp.
- **Clips très courts** : si un clip fait moins de 40 dp à l'écran, les poignées passent à l'extérieur de ses bords au lieu de se chevaucher. L'utilisateur peut aussi zoomer.
- **Durée minimale** : un clip ne peut pas être rogné en dessous de 0,1 s (ou d'une image).
- **Éléments texte et audio** : les modifier de durée suit les mêmes principes, détaillés dans `EDT-03` et `EDT-04`.

## Valeurs de design
Mêmes valeurs que `EDT-01`. Ajouts :
- Poignée active : accent `#E2542B`, largeur 18 dp, grip clair.
- Partie retirée : fond de l'écran à 72 % d'opacité par-dessus les miniatures, contour de 1,5 dp en pointillés (5 dp / 4 dp).
- Bulle : fond couleur du texte principal, texte couleur du fond, rayon 10 dp, pointe vers la poignée.
- Ligne d'aimantation : 1,5 dp en pointillés (4 dp / 4 dp), couleur du texte principal à 70 %.
- Barre d'annulation : 48 dp de haut, rayon 8 dp, marges de 16 dp, couleurs inversées du thème.
- Feuille de rognage précis : rayon de 28 dp en haut, boutons ronds de 44 dp, valeur 16 sp semi-gras.

## Accessibilité
- Actions sur les poignées : « Rogner le début de 0,1 s », « Rogner la fin de 0,1 s », « Rogner précisément ».
- Pendant un rognage, annoncer la nouvelle durée à chaque palier (par exemple toutes les secondes), pas à chaque image.
- La partie retirée n'est pas signalée par la couleur seule : elle a un contour en pointillés et la bulle donne la durée retirée.
- Après une scission, annoncer « Clip scindé, deux clips ». La barre d'annulation reste lisible au moins 5 secondes (plus longtemps avec un lecteur d'écran).
- Contrastes : à mesurer sur les valeurs finales (texte de la bulle, étiquette « Fin du clip » sur l'aperçu).

## Performance
- Pendant le rognage, l'aperçu affiche une image fixe à la poignée, sans lecture vidéo.
- Les miniatures de la partie retirée sont déjà en cache : aucun nouveau calcul pendant le geste.
- Aucun flou ni ombre.

## Points ouverts
- **Sélection après scission** : j'ai choisi la partie de gauche. À valider en test : l'usage le plus courant (garder la fin et supprimer le début, ou l'inverse) peut justifier l'autre choix.
- **Fermeture automatique de l'espace** : à confirmer avec le comportement de suppression de `EDT-01`.
- **Pas de rognage de 0,1 s** : une valeur par image pourrait être plus juste pour les vidéos à débit variable.
- **Rognage du début** : même comportement que la fin, vu ici seulement pour la fin. À vérifier en test que la bulle et l'aperçu restent lisibles.
- **Paysage et tablette** : non dessinés ici.
