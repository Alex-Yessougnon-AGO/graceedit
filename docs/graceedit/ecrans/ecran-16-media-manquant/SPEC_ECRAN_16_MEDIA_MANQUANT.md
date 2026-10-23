# Écran 16 — Reconnecter un média manquant

**ID** : `PRJ-05` · **Phase** : V1 · **Précédents** : `HOM-01`, `PRJ-01` (ligne « Média manquant »), `EXP-01` (contrôle avant export), `EDT-01` (clip avec avertissement) · **Suivant** : `EDT-01`
**Fichiers** : `prj05-manquants-*.png` (un média reste à reconnecter), `prj05-different-*.png` (fichier différent), `prj05-termine-*.png` (tout est reconnecté), clair et sombre, plus les `.svg` (1080 × 2400 px = 360 × 800 dp à 3x).

> Noms de fichiers, durées et poids sont des **exemples**.

## Rôle
Quand un projet référence un média que l'application ne retrouve plus (déplacé, renommé, supprimé, carte mémoire absente, autorisation perdue), permettre de le **reconnecter** à un fichier, ou de le **retirer** du projet, sans perdre le montage.

## Entrées
- Toucher un projet marqué « Média manquant » (accueil, liste des projets).
- Action « Reconnecter » du contrôle avant export (`EXP-01`).
- Action « Reconnecter » sur un clip marqué d'un avertissement dans l'éditeur (`EDT-01`).

## Contenu

| Zone | Contenu | Règle |
|---|---|---|
| Barre supérieure | Retour, « Médias manquants », nom du projet en dessous | Retour = quitter sans rien changer. |
| Texte | « 1 média est introuvable. Il a peut-être été déplacé, renommé ou supprimé. Choisissez le fichier à utiliser à sa place. » | Le compte et le pluriel suivent l'état réel. |
| Carte d'un média manquant | Vignette d'avertissement, nom du fichier (coupé au milieu si long), durée et poids d'origine, « Utilisé dans 3 clips » | Voir « Actions ». |
| Carte d'un média reconnecté | Vignette réelle, nom du nouveau fichier, coche et « Reconnecté », « Changer de fichier » | La coche et le texte portent l'état. |
| Caption | « 1 média reste à reconnecter. » | Disparaît quand tout est traité. |
| Actions du bas | « Ouvrir le projet » (principal, 56 dp) et « Ouvrir sans ces médias » (texte) | Voir « Règles du bas ». |

## Actions d'une carte
- **Reconnecter** : ouvre le **sélecteur de fichiers du système**, limité au type du média (vidéo, audio ou image). L'application ne parcourt **pas** le stockage du téléphone pour chercher le fichier toute seule.
- Après le choix, l'application **vérifie** le fichier : lisible ? type compatible ? durée et dimensions proches de l'original ?
  - Compatible : la carte passe en « Reconnecté ».
  - **Différent** (durée ou dimensions éloignées) : fenêtre « Ce fichier est différent » (voir ci-dessous).
  - Illisible ou non pris en charge : message sur la carte (« Ce fichier ne peut pas être lu »), la carte reste « manquante ».
- **Retirer du projet** : supprime ce média **et les clips qui l'utilisent**. Pas de fenêtre de confirmation : message « Média retiré · **Annuler** » (6 secondes).
- **Changer de fichier** (carte reconnectée) : rouvre le sélecteur.

## Fichier différent (`prj05-different-*`)
Fenêtre : « Ce fichier est différent. Le fichier choisi dure 1:52, l'original durait 2:15. Les coupes et les textes de ce clip risquent d'être décalés. » Actions : **« Choisir un autre fichier »** (plein, action par défaut, la plus sûre) et **« Utiliser quand même »** (texte). Si l'utilisateur insiste, les coupes sont conservées en valeur de temps et limitées à la durée du nouveau fichier.

## Règles du bas
- **« Ouvrir le projet »** est actif seulement quand tous les médias sont reconnectés ou retirés. Désactivé, il garde son libellé et la caption explique pourquoi.
- **« Ouvrir sans ces médias »** ouvre l'éditeur avec les clips concernés affichés en avertissement (« Média manquant ») et un aperçu vide avec « Reconnecter ». Cette sortie reste toujours disponible : l'utilisateur n'est jamais bloqué.
- **Tout reconnecté** (`prj05-termine-*`) : « Tous les médias sont reconnectés. », « Ouvrir le projet » actif, plus de lien « sans ces médias ».

## États (non dessinés)
- **Vérification en cours** : texte « Vérification… » avec barre indéterminée sur la carte.
- **Carte mémoire absente** : texte « Si ce fichier est sur une carte mémoire, insérez-la puis réessayez. »
- **Autorisation d'accès perdue** : même parcours (le sélecteur du système redonne l'accès).
- **Beaucoup de médias manquants** : la liste défile ; un en-tête fixe donne le compte.

## Valeurs de design
Cartes de 148 dp (manquant) et 120 dp (reconnecté), rayon 16 dp, fond de surface ; vignette 72 × 40 dp ; bouton « Reconnecter » à contour, 44 dp de haut ; bouton principal 56 dp ; couleur d'erreur seulement pour l'icône et les messages d'erreur. Mêmes tokens que les écrans précédents.

## Accessibilité
- Chaque carte est lue : « VID 2026 10 03 12 10, vidéo, 2 minutes 15, utilisée dans 3 clips, introuvable ». Les actions sont des boutons nommés.
- L'état « Reconnecté » est annoncé quand il change (zone vivante polie).
- Fenêtre : le focus va au titre puis à « Choisir un autre fichier ».
- Cibles ≥ 48 dp ; grandes polices : les cartes grandissent, la page défile, les boutons du bas restent fixes.
- Contrastes à mesurer sur les valeurs finales.

## Performance et confidentialité
- Aucun balayage de la mémoire du téléphone : seul le fichier choisi par l'utilisateur est lu.
- La vérification lit les métadonnées, pas tout le fichier.

## Points ouverts
- **Reconnecter plusieurs médias d'un coup** en choisissant un **dossier** (l'application rapproche les noms de fichiers) : utile, à étudier ensuite.
- **Détection automatique** quand le fichier réapparaît (carte mémoire réinsérée) : message discret et reconnexion proposée.
- Seuil d'écart de durée qui déclenche l'avertissement « Ce fichier est différent » (ici : plus de 5 %).
