# Écran 15 — Projets : liste, grille, recherche, sélection, suppression, corbeille

**IDs** : `PRJ-01` (liste, grille, recherche, tri), `PRJ-02` (actions sur un projet), `PRJ-03` (suppression : corbeille ou définitive, un projet ou plusieurs), `PRJ-06` (corbeille) · **Phase** : V1
**Précédents** : `HOM-01` (« Tout voir »), barre de navigation · **Suivants** : `EDT-01` (ouvrir un projet), `EXP-01` (exporter), `PRJ-05` (média manquant)
**Fichiers** : `prj01-liste-*`, `prj01-grille-*`, `prj01-menu-*`, `prj01-actions-*`, `prj01-selection-*`, `prj01-choix-*`, `prj01-definitive-*`, `prj01-corbeille-*`, `prj01-recherche-*` (clair et sombre, 1080 × 2400 px = 360 × 800 dp à 3x), plus les `.svg`.

> Miniatures, titres et dates sont des **exemples**. Les chaînes utilisent l'espace insécable (voir « Règles de langue »).

## Rôle
Retrouver, ouvrir et gérer ses projets ; en supprimer un ou plusieurs, avec le choix entre la **corbeille** (récupérable) et la **suppression définitive**.

## Structure de l'écran principal

| Zone | Contenu | Règle |
|---|---|---|
| Titre | « Projets » (24 sp) | |
| Barre d'actions | **Recherche**, **bascule liste/grille**, **menu « ⋮ »** | Le menu contient « Sélectionner » et « Corbeille (3) » avec le nombre d'éléments. La bascule montre l'icône de l'affichage **vers lequel on va**, différente de l'icône de l'onglet « Projets ». Le choix est mémorisé. |
| Ligne de tri | Puce « Récents », compteur « 6 projets » | Tri : Récents (défaut), Plus anciens, Nom (A à Z). Menu de tri non dessiné. Mémorisé. |
| Contenu | Liste ou grille | Voir ci-dessous. |
| Bouton flottant | « Nouveau projet » | Masqué pendant la recherche et la sélection. |
| Barre de navigation | « Projets » actif | Masquée pendant la sélection (remplacée par la barre d'actions). |

### Liste (`prj01-liste-*`)
Ligne de 80 dp : miniature 96 × 54 dp avec durée, titre (16 sp, une ligne, coupé par « … » en fin), date, bouton « ⋮ » de 48 dp. Toucher la ligne ouvre l'éditeur à l'état enregistré. **Média manquant** : surface avec icône d'avertissement, texte « Média manquant » en couleur d'erreur avec icône ; toucher la ligne ouvre `PRJ-05`.

### Grille (`prj01-grille-*`)
Deux colonnes de 152 dp, miniature 16:9, titre 14 sp, date 13 sp, bouton « ⋮ » en disque sur l'angle de la miniature (zone tactile ≥ 48 dp). Sur grand écran ou en paysage : 3 à 4 colonnes. En grande police : une colonne.

### Menu « ⋮ » (`prj01-menu-*`)
Deux lignes : **Sélectionner** (entre en mode sélection) et **Corbeille** (avec le nombre de projets qu'elle contient).

### Recherche (`prj01-recherche-*`)
Champ qui remplace la barre de titre ; recherche sur les titres, en direct, sans accent ni casse. Aucun résultat : « Aucun résultat pour « mariage » » + conseil. La flèche de retour ferme la recherche.

## Actions sur un projet — `PRJ-02` (`prj01-actions-*`)
Feuille modale ouverte par « ⋮ » ou par une action d'accessibilité. En-tête : miniature, titre, date (on sait sur quoi on agit). Lignes de 56 dp :
- **Renommer** : petite fenêtre avec champ prérempli (non dessinée).
- **Dupliquer** : crée aussitôt « Titre (copie) » en tête de liste, message « Projet dupliqué ». Les médias sont partagés par référence, pas copiés.
- **Exporter** : ouvre `EXP-01`.
- **Sélectionner** : entre en mode sélection avec ce projet coché.
- **Supprimer** (couleur d'erreur + icône) : ouvre `PRJ-03`.
Fermeture : glisser vers le bas, toucher le voile ou Retour. **Archiver** : non prévu en V1 (la corbeille le remplace).

## Sélection multiple (`prj01-selection-*`)
- **Entrée** : appui long sur une ligne ou une carte ; « Sélectionner » dans le menu « ⋮ » ou dans la feuille d'actions (alternative découvrable et accessible).
- **Barre supérieure** : ✕ (quitter), « 2 sélectionnés » (se met à jour), « Tout sélectionner » (devient « Tout désélectionner » quand tout est coché).
- **Lignes** : case ronde à gauche (cochée = disque plein avec coche ; non cochée = cercle vide). Ligne cochée : **fond différent** en plus de la coche (pas de couleur seule). Les projets avec média manquant sont sélectionnables.
- **Barre d'actions en bas** (remplace la navigation) : **Dupliquer** et **Supprimer**. Désactivées si rien n'est coché ; le mode reste actif.
- **Dupliquer** plusieurs : crée N copies, message « 2 projets dupliqués ».
- Retour (geste ou ✕) : quitte la sélection sans rien changer. La sélection survit au défilement et fonctionne aussi dans les résultats de recherche.
- Un projet en cours d'export ne peut pas être supprimé : il est grisé avec « Export en cours ».

## Suppression : corbeille ou définitive — `PRJ-03`
### Choix (`prj01-choix-*`)
Fenêtre « Supprimer 2 projets ? » (ou « Supprimer ce projet ? ») :
1. **Mettre à la corbeille** (bouton plein, **action par défaut et la plus sûre**) : les projets restent **30 jours** et peuvent être restaurés.
2. **Supprimer définitivement** (bouton à contour, couleur d'erreur) : mène à une **seconde confirmation**.
3. **Annuler** (bouton texte). Retour = annuler.
Le texte précise que les vidéos d'origine et les vidéos exportées ne sont **jamais** supprimées.

### Confirmation définitive (`prj01-definitive-*`)
« Supprimer définitivement ? » ; « 2 projets seront supprimés pour toujours. Cette action est irréversible. … ». « Annuler » est le bouton plein (action sûre) ; « Supprimer définitivement » est un bouton texte en couleur d'erreur. Après suppression : message « 2 projets supprimés » (sans annulation possible).

### Après « Mettre à la corbeille »
Message « 2 projets déplacés dans la corbeille · **Annuler** » pendant 6 secondes. « Annuler » les rétablit immédiatement.

### Réglage de comportement (point ouvert)
Par défaut la fenêtre de choix s'affiche à chaque fois. Un réglage « Suppression : demander à chaque fois / toujours mettre à la corbeille » est proposé en `SET-01`.

## Corbeille — `PRJ-06` (`prj01-corbeille-*`)
- **Accès** : menu « ⋮ » de Projets ; lien dans `SET-02` (stockage).
- **Barre** : retour, « Corbeille », « Vider ».
- **Information** : « Les projets restent 30 jours dans la corbeille, puis sont supprimés définitivement. »
- **Ligne** : miniature, titre, « Supprimé il y a 3 j », « Suppression dans 27 j ». Quand il reste **un jour ou moins**, la ligne passe en avertissement avec icône : « Suppression demain ».
- **Actions d'une ligne** (« ⋮ », ou toucher la ligne) : **Restaurer** (retour dans Projets, message « Projet restauré ») et **Supprimer définitivement** (confirmation comme ci-dessus). Un projet de la corbeille ne peut pas être ouvert ni modifié.
- **Vider** : fenêtre « Vider la corbeille ? » ; « N projets seront supprimés pour toujours. » ; « Annuler » plein, « Vider » en couleur d'erreur.
- **Sélection multiple** dans la corbeille : mêmes règles, avec « Restaurer » et « Supprimer définitivement ».
- **Corbeille vide** (`prj01-corbeille-vide-*`) : icône, « La corbeille est vide. », « Les projets supprimés apparaissent ici pendant 30 jours. » ; le bouton « Vider » n'est pas affiché.
- **Purge automatique** : les projets de plus de 30 jours sont supprimés à l'ouverture de l'application et par une tâche en arrière-plan.
- **Stockage** : un projet ne contient que les réglages de montage ; les médias ne sont pas copiés. À la mise à la corbeille, les **miniatures et caches** du projet peuvent être supprimés pour libérer de l'espace ; ils sont régénérés à la restauration.

## États (non dessinés)
Aucun projet (même état vide que `HOM-01B`) · chargement (liste immédiate, miniatures ensuite, blocs unis) · miniature non générée (surface neutre, différente de « Média manquant ») · stockage faible (bandeau avec « Gérer », `SET-02`) · projet en cours d'export (badge, lecture seule) · tablette et pliables.

## Règles de langue et de typographie
Espace insécable entre le nombre et l'unité (« 3 j », « 4 min », « 248 Mo »), avant les signes doubles et dans les guillemets français ; pluriels corrects (« 1 projet », « 2 projets »).

## Valeurs de design
Mêmes tokens que les écrans précédents. Ligne 80 dp ; case de sélection 22 dp (zone tactile ≥ 48 dp) ; fond de ligne cochée = teinte « indicateur actif » ; barre d'actions de sélection 80 dp, icônes 24 dp, libellés 12 sp ; fenêtres 312 dp de large, rayon 28 dp, voile 45 % ; bouton plein 52 dp, bouton à contour 48 dp ; ligne de corbeille 96 dp.

## Accessibilité
- Lecture d'une ligne : « Visite du marché, 4 minutes 10, modifié il y a 2 heures ». Les actions (renommer, dupliquer, exporter, sélectionner, supprimer) sont aussi des **actions d'accessibilité** sur la ligne.
- Mode sélection : cases annoncées « case à cocher, cochée » ; changement annoncé « 2 sélectionnés ».
- Fenêtres : le focus va au titre puis à l'action **sûre**, et reste dans la fenêtre.
- Bascule : « Passer en affichage en grille » / « … en liste ». Puce de tri : « Trier, Récents ».
- Aucune information portée par la couleur seule : l'erreur a une icône, la sélection a une coche et un fond, l'urgence de la corbeille a une icône et un texte.
- Contrastes à mesurer sur les valeurs finales.

## Performance
Liste paresseuse, miniatures en cache à la taille d'affichage, prévue pour des centaines de projets. Aucune animation hors feuille, fenêtres et message.

## Points ouverts
- Durée de **30 jours** de la corbeille : valeur de départ.
- Réglage « demander à chaque fois / toujours corbeille » (`SET-01`).
- Suppression des caches à l'entrée en corbeille : à confirmer.
- Options de tri supplémentaires (durée, taille, date de création) ; édition en place de « Renommer » ; libellé « (copie) » à localiser.
