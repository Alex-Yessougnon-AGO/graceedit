# Écran 09 — Ajustements visuels, format et recadrage

**ID** : `EDT-05` · **Phase** : V1 (ajustements visuels de base) · **Précédent** : `EDT-04` · **Suivant** : `EDT-07` (couverture)
**Fichiers** : `edt05-ajuster-*.png`, `edt05-format-*.png`, `edt05-cadrer-*.png`, clair et sombre, plus les `.svg` (1080 × 2400 px = 360 × 800 dp à 3x).

> Trois situations de l'éditeur (`EDT-01`). Images et valeurs sont des **exemples**. Les filtres, transitions et effets (Phase 2) ne sont pas couverts ici.

## Les trois outils et la différence entre eux
| Outil | Question à laquelle il répond | Entrée |
|---|---|---|
| **Ajuster** | « À quoi ressemblent les couleurs ? » | Barre générale (`EDT-01`), outil « Ajuster » |
| **Format** | « Quelle est la forme de ma vidéo finale ? » | Barre générale, outil « Format » |
| **Cadrer** | « Quelle partie de l'image de ce clip je garde ? » (recadrer, pivoter, miroir, redresser) | Barre d'un clip sélectionné, outil « Cadrer » |

Cette distinction est le principal risque de compréhension de l'écran (voir « Points ouverts »).

## Situation 1 — Ajuster (`edt05-ajuster-*`)
Feuille non modale : l'aperçu et la timeline restent visibles.

| Zone | Contenu | Règle |
|---|---|---|
| En-tête | « Ajuster », « Réinitialiser », fermer | « Réinitialiser » remet les trois valeurs à 0 pour la portée choisie. |
| Portée | Choix « **Ce clip** » / « Tout le projet » | Par défaut « Ce clip » si un clip est sélectionné, sinon « Tout le projet ». Le choix actif porte une coche, pas seulement une couleur. |
| Curseurs | Luminosité, Contraste, Saturation, de −100 à +100 | Une marque au centre repère le zéro. Valeur écrite à droite, avec « − » typographique. |
| **Comparer** | Bouton sur l'aperçu | **Appui long** : montre l'original tant qu'on appuie. **Appui simple** : bascule l'affichage de l'original (alternative pour ceux qui ne peuvent pas maintenir). |

- « Tout le projet » **copie** les valeurs dans chaque clip, en remplaçant leurs réglages propres, en une seule action annulable, avec la barre « Appliqué à 3 clips · Annuler ».
- Le rendu de l'aperçu est en basse résolution ; l'export utilise la pleine qualité. Ce que l'on voit doit correspondre à l'export (à tester).
- Un petit repère sur le clip dans la timeline indique qu'un réglage est appliqué (à dessiner avec les composants de la timeline).

## Situation 2 — Format (`edt05-format-*`)
- **Quatre formats** : Vertical 9:16, Carré 1:1, Horizontal 16:9, Portrait 4:5. Chaque carte montre la forme réelle du format, son rapport et son nom. Le format actif porte une coche et un contour.
- **Par défaut**, le format est celui du premier média (règle de `IMP-02`).
- **Mode d'adaptation** : « Remplir » (l'image est recadrée pour couvrir tout le cadre) ou « Ajuster » (l'image entière est gardée, avec des bandes). L'explication change selon le choix. Les bandes sont **noires** en V1.
- **Aperçu** : la région d'aperçu garde sa hauteur fixe de 260 dp ; la vidéo s'y centre, avec des bandes sombres. La mise en page ne saute pas.
- **Effet sur les textes** : les éléments texte gardent leur position relative et sont mis à l'échelle. Une aide pour les replacer est à étudier.

## Situation 3 — Cadrer (`edt05-cadrer-*`)
Mode plein écran, qui remplace temporairement la barre d'outils.

| Zone | Contenu |
|---|---|
| Barre supérieure | Fermer (annule les changements, sans confirmation), « Cadrer », « Terminé » |
| Zone de travail | Image, cadre de recadrage avec grille des tiers, zones extérieures assombries (62 %), poignées d'angle en L de 22 dp |
| Rapports | Libre, 1:1, 4:5, 9:16 |
| Actions | **Pivoter** (par pas de 90°), **Miroir** (horizontal) |
| Redresser | Curseur −45° à +45°, avec repère à 0° et léger retour haptique à 0° |
| Réinitialiser | Remet le cadrage, la rotation et le miroir à leur état d'origine |

- **Gestes** : glisser un angle redimensionne le cadre ; glisser à l'intérieur déplace l'image ; pincer zoome ; double appui réinitialise.
- **Terminé** : applique en **une seule** action annulable.
- **Photos** : même outil, appliqué à une image fixe.

## Valeurs de design
- Segments : conteneur 40 dp de haut ; l'élément actif est plein (couleur du texte) avec coche et texte inversé.
- Curseurs bipolaires : piste de 4 dp, remplissage du centre vers le curseur, marque centrale de 2 × 14 dp.
- Cartes de format : 72 × 100 dp, rayon 14 dp, pastille de coche sur l'angle.
- Bouton « Comparer » : 32 dp de haut, fond noir à 70 %, texte ivoire.
- Cadre de recadrage : trait de 1,5 dp, grille de 1 dp à 50 %, poignées de 4 dp d'épaisseur.

## Accessibilité
- Tous les curseurs sont ajustables par pas (5 pour les réglages, 1° pour le redressement) et annoncent leur valeur.
- **Cadre de recadrage sans glisser** : actions « Déplacer le cadre vers la gauche, la droite, le haut, le bas » (pas de 1 %), « Agrandir » et « Réduire le cadre », en plus des rapports prédéfinis, de Pivoter et de Miroir.
- « Comparer » fonctionne par appui simple (bascule) comme par appui long.
- Les formats et la portée sont annoncés par leur nom (« Vertical, 9 sur 16, sélectionné »).
- Les poignées du cadre ont une zone tactile d'au moins 48 dp. Elles sont blanches sur une zone assombrie : lisibles sur toute image.
- Grandes polices : les cartes de format passent à deux lignes, la feuille défile.

## Performance (appareils modestes)
- Les ajustements de couleur sont calculés par la **carte graphique**, jamais pixel par pixel par le processeur.
- Aperçu en basse résolution pendant le glissement d'un curseur, image nette au relâchement.
- Aucun flou : les bandes du mode « Ajuster » sont unies.

## Points ouverts
- **Cadrer et Format se recoupent.** Un débutant peut confondre « choisir le format » et « recadrer ». Proposition de simplification à tester : en V1, supprimer les rapports « Libre, 1:1, 4:5, 9:16 » de Cadrer et ne garder que Pivoter, Miroir, Redresser et le cadrage **dans le format du projet**. Je l'ai dessiné avec les rapports pour que tu puisses juger.
- **Portée « Tout le projet »** : copie ou calque global ? J'ai choisi la copie (modèle mental plus simple). À valider.
- **Bandes floues** (comme certains éditeurs) : coûteuses sur un appareil modeste. Absentes en V1.
- **Réglages supplémentaires** (température, netteté, vignette) et **filtres** : Phase 2, non classés dans le plan.
- **Saisie d'une valeur au clavier** en touchant le chiffre d'un curseur : utile pour la précision et l'accessibilité, à ajouter si le test le confirme.
- **Replacement des textes** après un changement de format : à étudier.
