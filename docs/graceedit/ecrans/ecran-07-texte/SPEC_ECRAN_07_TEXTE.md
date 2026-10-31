# Écran 07 — Texte et titres

**ID** : `EDT-03` · **Phase** : V1 · **Précédent** : `EDT-02` · **Suivant** : `EDT-04` (audio)
**Fichiers** : `edt03-saisie-*.png`, `edt03-selection-*.png`, `edt03-style-*.png`, clair et sombre, plus les `.svg` (1080 × 2400 px = 360 × 800 dp à 3x).

> Comme `EDT-02`, ce sont trois **situations de l'éditeur** (`EDT-01`) et non une nouvelle page. Le clavier est celui du système, dessiné ici comme un simple repère. Textes, images et couleurs sont des **exemples**. Les sous-titres automatiques sont en Phase 2 : cet écran ne les couvre pas.

## Parcours
Outil « Texte » (`EDT-01`, aucun clip sélectionné) → un texte est ajouté à la tête de lecture et le clavier s'ouvre → **saisie** → « Terminé » → texte **sélectionné** sur l'aperçu → **style** si besoin.

Choix de conception : le texte est ajouté **tout de suite** avec un style par défaut, sans écran intermédiaire de choix de modèle. Le style se change ensuite. C'est le chemin le plus court vers un premier titre.

## Situation 1 — Saisie (`edt03-saisie-*`)

| Zone | Contenu | Règle |
|---|---|---|
| Barre supérieure | Fermer (✕) · « Ajouter du texte » (ou « Modifier le texte ») · « Terminé » | ✕ sur un **nouveau** texte le supprime ; sur un texte existant, il annule les changements. |
| Aperçu | Le texte s'affiche en direct dans son style | Le champ de saisie et l'aperçu sont synchronisés. |
| Champ de saisie | Zone de texte sur plusieurs lignes, étiquette « Texte » | Un vrai champ du système, pas une saisie directe sur l'aperçu : meilleur pour les claviers, les dictées, les langues et les lecteurs d'écran. |
| Style | Trois préréglages : Titre, Sous-titre, Légende | Le préréglage actif porte une **coche et un contour**, pas seulement une couleur. |
| Clavier | Clavier du système, langue du système | Non conçu par GraceEdit. |

- « Terminé » est **désactivé** tant que le texte est vide.
- Sur un écran de faible hauteur (par exemple 360 × 640 dp), l'aperçu se réduit pour que le champ et les préréglages restent visibles au-dessus du clavier.

## Situation 2 — Texte sélectionné (`edt03-selection-*`)
- **Sur l'aperçu** : un cadre avec quatre poignées d'angle (redimensionnement proportionnel) et une poignée de rotation au-dessus. Glisser le texte le déplace. Un double appui rouvre la saisie.
- **Zones tactiles** : les poignées font 12 dp à l'écran, mais leur zone tactile est d'au moins 48 dp.
- **Aimantation** : au centre et aux marges de l'image, avec un léger retour haptique et un trait de guidage pendant le geste.
- **Sur la timeline** : l'élément texte est sélectionné (contour épais, poignées de durée), son étiquette de durée est « 8 s ». La timeline s'est **agrandie automatiquement** pour que l'élément soit assez large pour être manipulé (voir « Règles »).
- **Barre d'outils du texte** : un chevron de retour, puis **Modifier**, **Style**, **Couleur**, **Supprimer**, **Plus**. « Plus » contient Dupliquer et Aligner. Aucune commande non disponible en V1 n'y figure.
- **Supprimer** : pas de confirmation, barre d'annulation (comme pour les clips).

## Situation 3 — Style (`edt03-style-*`)
Une feuille de bas d'écran **non modale** : l'aperçu et le texte sélectionné restent visibles et se mettent à jour en direct.

| Onglet | Contenu |
|---|---|
| Style (`edt03-onglet-style-*`) | Préréglages ; **alignement** (gauche, centré, droite) ; **position verticale** (haut, centre, bas) ; **rotation** par pas de 15° (boutons − et +) |
| Police (`edt03-onglet-police-*`) | Grille de six polices, chacune affichée dans son propre dessin avec son nom ; la police choisie porte une coche et un contour |
| **Couleur** (dessiné) | Six pastilles, curseur « Taille », curseur « Opacité » |
| Fond (`edt03-onglet-fond-*`) | Choix **Aucun / Léger / Plein**, six couleurs de fond, curseur « Opacité du fond » |

Les quatre onglets sont dessinés : Couleur (`edt03-style-*`), Style, Police et Fond (`edt03-onglet-*`). Polices proposées au départ (toutes sous licence libre SIL OFL, **à valider avant publication** : licence de chaque fichier, accents français, couverture des alphabets) : Inter, Playfair Display, Bebas Neue, Caveat, Lora, Pacifico.

- **Couleur** : six pastilles de 52 dp de large, de sorte que chaque cible atteigne les 48 dp. La couleur choisie porte une coche et un anneau.
- **Taille** : le curseur est l'**alternative accessible au pincement**. La valeur est affichée (« 28 »).
- **Opacité** : de 0 à 100 %.
- Les choix d'**alignement** et de **position verticale** (neuf positions possibles) et la **rotation par pas de 15°** (onglet Style) sont les alternatives accessibles au glisser et à la poignée de rotation.

## Règles
- **Durée par défaut** : 3 secondes, à la tête de lecture.
- **Zoom automatique** : à l'ajout d'un texte, la timeline s'agrandit pour que l'élément soit large d'au moins 64 dp. Un élément texte plus étroit que 40 dp à l'écran place ses poignées à l'extérieur de ses bords (même règle que pour les clips dans `EDT-02`).
- **Timeline** : déplacer et rogner un élément texte suit les gestes de `EDT-02`, avec aimantation à la tête de lecture et aux bords des clips.
- **Annulation** : chaque action est annulable. Un glissement de curseur compte comme **une seule** action, enregistrée au relâchement.
- **Saisie vide** : un texte jamais validé n'est pas conservé.

## Valeurs de design
- Texte de l'aperçu : 28 sp semi-gras, couleur ivoire `#F6F2EA`, fond noir `#0B0B0D` à 55 % d'opacité, rayon 10 dp (préréglage « Légende »).
- Cadre de sélection : 1,5 dp ivoire. Poignées : disques de 12 dp, ivoire avec contour noir de 1,5 dp. Poignée de rotation : disque de 24 dp.
- Pastilles de couleur : 32 dp visibles, 52 dp de pas, contour fin pour les couleurs proches du fond, anneau de 2,5 dp pour la sélection.
- Curseurs : piste de 4 dp, curseur de 20 dp, valeur à droite du libellé.
- Feuille : mêmes valeurs que la feuille de `EDT-02`.

## Accessibilité
- Le champ de saisie est un champ standard : dictée vocale, correcteur et lecteurs d'écran fonctionnent.
- Les gestes d'aperçu ont tous une alternative : taille (curseur), rotation (pas de 15°), position (grille), durée (actions « Allonger / Raccourcir de 0,1 s » comme dans `EDT-02`).
- Le préréglage et la couleur choisis sont annoncés par leur nom (« Légende, sélectionné », « Ivoire, sélectionné »), pas seulement montrés.
- **Lisibilité** : le fond semi-transparent du préréglage garantit un contraste suffisant sur la plupart des vidéos. Mesurer le contraste réel (texte, fond) sur les valeurs finales. Un avertissement est envisagé si la couleur du texte et celle du fond sont trop proches.
- Grandes polices : les onglets défilent, la feuille défile, les libellés d'outils passent sur deux lignes.

## Performance
- Le texte de l'aperçu est un tracé de texte léger, sans effet d'ombre ni de flou.
- Pas de rendu de la vidéo pendant la saisie : seule la région d'aperçu se met à jour.

## Points ouverts
- **Polices** : lesquelles inclure, avec une licence compatible avec un usage commercial et l'intégration à l'export. La couverture des caractères (accents, langues d'Afrique de l'Ouest, alphabets non latins, emoji) et l'écriture de droite à gauche sont à vérifier.
- **Textes qui se chevauchent** dans le temps : empilement automatique ou interdiction en mode Simple (déjà ouvert dans `EDT-01`).
- **Limite de longueur** d'un texte : à définir.
- **Zones de sécurité** des plateformes (interfaces superposées aux vidéos) : une aide visuelle est possible plus tard, absente de la V1.
- **Zoom automatique à l'ajout** : à valider en test (le saut de zoom peut désorienter).
- **Fond du texte** : arrondi du fond et marges ; non prévus en V1.
