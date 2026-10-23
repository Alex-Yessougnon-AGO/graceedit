# Écran 11 — Réglages d'export

**ID** : `EXP-01` · **Phase** : V1 · **Précédent** : `EDT-01` (bouton « Exporter ») · **Suivant** : `EXP-02` (progression)
**Fichiers** : `exp01-normal-*.png` (cas normal), `exp01-espace-*.png` (espace insuffisant), clair et sombre, plus les `.svg` (1080 × 2400 px = 360 × 800 dp à 3x).

> Titres, durées et tailles sont des **exemples**. Écran plein écran, sans barre de navigation du bas.

## Rôle
Permettre d'exporter en **deux gestes** pour un débutant (« Exporter » puis « Exporter »), tout en informant honnêtement de ce que l'appareil peut faire et de la place disponible. L'export ne dépend ni d'un compte ni d'une connexion.

## Contexte du pipeline
Le contexte du projet décrit l'enchaînement : valider les réglages → résoudre les médias → préparer le rendu → **vérifier les capacités de l'appareil** → rendre → vérifier la sortie → enregistrer le résultat. Cet écran porte la **validation des réglages** et la **vérification des capacités**. Le rendu et la suite sont dans `EXP-02` et `EXP-03`.

## Contenu (de haut en bas)

| Zone | Contenu | Règle |
|---|---|---|
| Barre supérieure | Retour, « Exporter » | Retour = revenir à l'éditeur, sans perte. |
| Récapitulatif | Couverture du projet, titre, format | Rappelle ce qui va être exporté. |
| **Qualité** | Deux options sélectionnables : « Haute · 1080p » et « Standard · 720p » | Voir « Qualité ». |
| Format | Valeur actuelle, avec flèche | Ouvre l'outil « Format » de l'éditeur (`EDT-05`), car changer de format modifie la composition. |
| Destination | « Galerie du téléphone » | Non modifiable en V1. |
| Espace | Ligne d'information ou encadré d'alerte | Voir « Espace disponible ». |
| Bouton principal | « Exporter » (56 dp) + « Taille estimée : environ 250 Mo » | Lance `EXP-02`. |

## Qualité
Les profils visés au départ : 720p, 1080p, vertical 1080 × 1920, carré 1080 × 1080, horizontal 1080p. Le **format** (vertical, carré, horizontal) vient du projet ; l'utilisateur ne choisit ici que la **qualité**.

| Format du projet | Haute | Standard |
|---|---|---|
| Horizontal 16:9 | 1920 × 1080 | 1280 × 720 |
| Vertical 9:16 | 1080 × 1920 | 720 × 1280 |
| Carré 1:1 | 1080 × 1080 | 720 × 720 |

- Chaque option affiche la **taille réelle** en pixels, la cadence (30 images/s) et la **taille estimée**.
- L'option choisie porte un **contour épais, une pastille pleine et un fond différent** : la sélection ne repose pas sur la couleur seule.
- **Selon les capacités de l'appareil** : les options qu'il ne peut pas produire ne sont **pas affichées comme garanties**. Si seul le 720p est possible, l'option « Haute » n'apparaît pas et une ligne explique : « Cet appareil exporte jusqu'en 720p. » (cas non dessiné).
- **Choix par défaut** : « Haute » si l'appareil et l'espace le permettent, sinon « Standard ». Le dernier choix est mémorisé pour le projet.
- Les profils 1080p à 60 images/s, 1440p, 4K, HEVC et HDR sont des **objectifs futurs** : ils n'apparaissent pas en V1.

## Espace disponible
- **Cas normal** : ligne discrète avec une coche : « Espace disponible suffisant (4,2 Go) ».
- **Espace insuffisant** (dessiné) :
  - l'option concernée est marquée d'une **icône d'avertissement** et sa taille passe en couleur d'erreur ;
  - un encadré explique en phrases simples **ce qu'il faut**, **ce qu'il reste** et **quoi faire** (« Choisissez Standard ou libérez de l'espace ») ;
  - le lien « Libérer de l'espace » ouvre la gestion du stockage (`SET-02`) ;
  - le bouton « Exporter » est **désactivé** et son état est expliqué par l'encadré. Si l'utilisateur choisit « Standard » et que la place suffit, l'encadré disparaît et le bouton s'active.
- Si **aucune** option ne tient : les deux options sont marquées, l'encadré ne propose que de libérer de l'espace.
- La taille est une **estimation** (durée × débit moyen du profil), toujours écrite « environ » ou « ≈ ». L'espace nécessaire inclut une marge pour le fichier temporaire du rendu (valeur à fixer avec l'équipe technique).
- La vérification se refait à l'ouverture de l'écran et au retour dans l'application.

## Autres contrôles avant export (non dessinés)
Affichés comme l'encadré d'espace insuffisant, avec une action claire :
- **Projet vide** : « Ajoutez au moins un clip. » → retour à l'éditeur.
- **Média manquant** : « Un média est introuvable. » → `PRJ-05` (reconnexion).
- **Batterie très faible** (moins de 15 %, hors charge) : avertissement **non bloquant**, car l'export est un calcul long.

## Valeurs de design
- Options de qualité : 76 dp de haut, rayon 14 dp, radio de 22 dp, titre 16 sp semi-gras, détail 13 sp, taille estimée 14 sp semi-gras alignée à droite.
- Lignes de réglage : 56 dp, séparateur de 1 dp, libellé 14 sp en couleur secondaire, valeur 16 sp.
- Encadré d'alerte : contour de 1,5 dp en couleur d'erreur (`#B3261E` clair, `#F2B8B5` sombre), rayon 12 dp.
- Bouton désactivé : fond de surface, texte en couleur secondaire.
- Mêmes tokens de couleur que les écrans précédents.

## Accessibilité
- Les options forment un **groupe de choix** : « Qualité, 2 options. Haute 1080p, environ 250 mégaoctets, sélectionné. »
- L'avertissement est porté par l'icône **et** le texte, jamais par la couleur seule.
- Le bouton désactivé est annoncé avec sa raison : « Exporter, indisponible : espace insuffisant ».
- Cibles : options de 76 dp, lignes de 56 dp, bouton de 56 dp, lien « Libérer de l'espace » avec une zone d'au moins 48 dp de haut.
- Grandes polices : les détails passent sur deux lignes, la taille estimée passe sous le titre, la page défile et le bouton reste fixé en bas.
- Contrastes : à mesurer sur les valeurs finales (couleur d'erreur sur le fond des deux thèmes).

## Performance et confidentialité
- Aucun calcul lourd sur cet écran : la taille estimée vient d'une formule, pas d'un rendu d'essai.
- Les capacités de l'appareil sont détectées **une fois** et mises en cache.
- Rien n'est envoyé en ligne.

## Points ouverts
- **Nom du fichier** : un champ modifiable (par défaut « GraceEdit_titre du projet ») est utile, mais ajoute une étape. À décider (aujourd'hui absent).
- **Couverture** : la changer depuis cet écran, ou l'enregistrer comme image (point ouvert de `EDT-07`).
- **Cadence** : 30 images/s fixe en V1 ; 60 images/s est un objectif futur.
- **Durée estimée** du rendu : non affichée, car trop variable selon l'appareil. À étudier si le test montre un besoin.
- **Marge d'espace** pour le fichier temporaire : à fixer avec l'équipe technique.
- **Avertissement de batterie faible** : seuil de 15 % à confirmer.
