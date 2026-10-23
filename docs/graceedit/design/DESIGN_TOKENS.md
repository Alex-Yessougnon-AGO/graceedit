# GraceEdit — Jetons de design (V1)

Source de vérité des **valeurs**. Le fichier `tokens.json` contient les mêmes valeurs lisibles par une machine. Écran de référence des maquettes : **360 × 800 dp**, rendu à 3x (1080 × 2400 px). Les dimensions sont en **dp**, les textes en **sp**.

## Couleurs de marque
| Nom | Valeur | Usage |
|---|---|---|
| Encre | `#14151A` | Texte clair, fond sombre |
| Ivoire | `#F6F2EA` | Fond clair, texte sombre |
| Accent vermillon | `#E2542B` | **Rare** : bloc du logo, **position de travail** (tête de lecture, poignée active, cadre de couverture). Jamais pour un état d'erreur ni un bouton. |
| Fond d'aperçu vidéo | `#0B0B0D` | Identique dans les deux thèmes |

## Thèmes (dessinés séparément, jamais inversés automatiquement)
| Rôle | Clair | Sombre |
|---|---|---|
| Fond | `#F6F2EA` | `#14151A` |
| Texte principal | `#14151A` | `#F6F2EA` |
| Texte secondaire | `#5E5C58` | `#B9B5AD` |
| Surface (cartes, puces, pistes) | `#E4DED2` | `#2A2C33` |
| Bouton principal (fond / texte) | `#14151A` / `#F6F2EA` | `#F6F2EA` / `#14151A` |
| Barre de navigation, feuilles | `#EDE7DB` | `#1D1F25` |
| Indicateur actif, élément coché | `#D9D2C3` | `#3A3C45` |
| Erreur (icône et texte d'erreur) | `#B3261E` | `#F2B8B5` |
| Pointillés, contours de champ | `#9A968D` | `#6B6D75` |
| Voile des fenêtres et feuilles | noir à 45 % | noir à 45 % |

**Règle** : la couleur d'erreur sert aux **icônes et aux messages d'erreur**, jamais comme seul signal. Toujours une icône **et** un texte.

## Typographie
Police **Inter** (licence SIL OFL, à confirmer avant publication). Poids : 400, 500, 600.

| Rôle | Taille / interligne |
|---|---|
| Affichage (bienvenue) | 34 / 40, semi-gras, léger resserrement |
| Titre d'écran | 24 / 30, semi-gras |
| Titre de fenêtre | 22 / 26, semi-gras |
| Titre de barre | 20, semi-gras |
| Sous-titre | 18, semi-gras |
| Corps | 16 / 24 et 15 / 22 |
| Secondaire | 14 / 20 |
| Légende | 13 / 18 |
| Petit | 12 |

Les **durées** (timecodes) utilisent des chiffres tabulaires. Les textes suivent la taille de police de l'appareil (jusqu'à 200 %).

## Espacement et formes
- Grille de **8 dp** ; marges latérales de **24 dp** ; écarts usuels 4, 6, 8, 12, 16, 24, 32.
- Rayons : miniature 8 · puce/carte petite 12 · carte 16 · puce 20 · bouton plein 28 · fenêtre et feuille 28.

## Dimensions des composants (dp)
| Composant | Valeur |
|---|---|
| Zone tactile minimale | **48** |
| Barre supérieure | 56 |
| Barre de navigation | 80 (trois destinations : Accueil, Projets, Réglages) |
| Bouton principal | 56 (pilule) ; bouton à contour 48 ; bouton de fenêtre 52 ; bouton flottant étendu 56 |
| Puce | 40 de haut |
| Ligne de projet | 80 ; miniature 96 × 54 |
| Carte de grille | 152 de large ; miniature 152 × 86 |
| Région d'aperçu de l'éditeur | 260 de haut, vidéo centrée, bandes sombres |
| Timeline | règle 22 · piste vidéo 72 · piste texte/audio 40 · poignée de rognage 14 (zone tactile ≥ 48) · tête de lecture 2 + tête de 10 |
| Barre d'outils de l'éditeur | 80, icône 24, libellé 12 sp |
| Fenêtre | 312 de large |
| Message temporaire | 48 de haut, marges 16 |

## Mouvement
Sobre. Respecter le réglage « Réduire les animations ». Fondu d'entrée d'écran 200 ms ; glissement du bloc d'accent du splash 400 ms ; messages temporaires 4 à 6 s. Aucune animation décorative sur appareil modeste.

## À ne jamais faire
Dégradés · ombres portées · effets 3D, verre dépoli, flou · lueurs · couleur d'accent comme bouton ou comme erreur · information portée par la couleur seule · bouton sans action · données factices présentées comme réelles.

## Icônes
Trait de 2 dp, extrémités arrondies, grille de 24 dp. Les maquettes en contiennent un jeu complet (retour, fermer, plus, recherche, liste, deux colonnes, ⋮, partager, galerie, lecture, pause, annuler, rétablir, scinder, volume, fondu, recadrer, texte, musique, curseurs, corbeille, copier, modifier, exporter, avertissement, information, coche). Utiliser un jeu d'icônes libre de droits de style équivalent ou redessiner ces formes.

## Logo
Fichiers dans `design/logo/` : symbole (« G » avec bloc détaché), version principale, versions monochromes noire et blanche. Taille minimale du symbole : 16 px. Voir `design/logo/`.
