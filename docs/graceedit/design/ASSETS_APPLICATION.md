# Ressources de l'application : icône, notification, splash, polices

Toutes les ressources sont dans `design/`. Les dimensions de plateforme citées ici sont **à vérifier dans la documentation Android** de la version visée avant intégration.

## Icône d'application (`design/icone-application/`)
| Fichier | Usage |
|---|---|
| `icone_avant-plan.svg` / `_avant-plan_432.png` | Couche **avant-plan** de l'icône adaptative : symbole ivoire + bloc d'accent, sur fond transparent |
| `icone_arriere-plan.svg` / `_arriere-plan_432.png` | Couche **arrière-plan** : aplat encre `#14151A` |
| `icone_monochrome.svg` / `_monochrome_432.png` | Couche **monochrome** pour les icônes thématiques (Android 13 et suivants) |
| `icone_composite.svg` | Assemblage de contrôle |
| `icone_boutique_512.png` | Icône de la fiche de la boutique (512 × 512 px, plein cadre, sans arrondi) |
| `icone_ronde_192.png`, `mipmap-*/ic_launcher.png` | Icônes de repli pour les anciennes versions (48 à 192 px) |
| `splash_symbole_clair.svg`, `splash_symbole_sombre.svg` | Symbole du splash système (zone de 288 dp, symbole de 120 dp) |
| `_apercu-masques.png` | Contrôle visuel dans quatre masques (rond, carré arrondi, carré, arrondi) |

**Construction** : toile de 108 dp ; le symbole (anneau) fait **56 dp de large**, centré, donc dans la zone de sécurité de 66 dp ; **aucun texte** dans l'icône ; **aucun dégradé**. Exemple de déclaration (à vérifier) :
```xml
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background"/>
  <foreground android:drawable="@drawable/ic_launcher_foreground"/>
  <monochrome android:drawable="@drawable/ic_launcher_monochrome"/>
</adaptive-icon>
```
Avec Flutter, un outil de génération d'icônes (par exemple `flutter_launcher_icons`) peut produire les densités à partir de ces fichiers ; **vérifier** qu'il prend bien en charge la couche monochrome dans la version choisie.

## Icône de notification (`design/icone-notification/`)
Silhouette **blanche** sur fond transparent, 24 dp (`drawable-*/ic_stat_graceedit.png` de 24 à 96 px). Android n'affiche que la forme (une seule couleur). **Contrôler visuellement à 24 dp** : si la fente entre le bloc et l'anneau disparaît, produire une variante où le bloc est plein.

## Splash
Le symbole fait 120 dp au centre d'une zone de 288 dp ; fond encre (sombre) ou ivoire (clair), identique à celui du splash dans l'application pour éviter un double splash. Les dimensions de la zone sûre du splash système sont à vérifier.

## Jeu d'icônes (`design/icones/`)
42 icônes SVG, grille de 24 dp, trait de 2 dp, extrémités arrondies, couleur `currentColor` (à teinter). Planche d'aperçu : `_planche-icones.png`. Noms en français (`ajouter`, `fermer`, `supprimer`, `partager`…). Elles peuvent être utilisées telles quelles ou remplacées par une bibliothèque libre de style équivalent (vérifier la licence).

## Polices
- **Interface** : **Inter** (SIL OFL). Poids 400, 500, 600. Embarquer les fichiers dans l'application (aucun téléchargement).
- **Polices proposées pour le texte de la vidéo** (onglet Police de `EDT-03`) : Inter, Playfair Display, Bebas Neue, Caveat, Lora, Pacifico. Toutes proviennent du dépôt public Google Fonts sous licence SIL OFL 1.1. **À valider avant publication** : licence de chaque fichier, présence des caractères accentués du français, couverture des autres alphabets, rendu des emoji, et poids des fichiers (garder l'application légère).

## Logo
`design/logo/` : symbole, version principale, monochromes noir et blanc (SVG) et planche de présentation. Taille minimale du symbole : 16 px.
