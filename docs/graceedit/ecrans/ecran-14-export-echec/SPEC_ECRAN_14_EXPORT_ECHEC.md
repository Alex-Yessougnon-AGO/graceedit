# Écran 14 — Échec et annulation de l'export

**ID** : `EXP-04` · **Phase** : V1 · **Précédents** : `EXP-02`, `EXP-03` · **Suivants** : `EXP-01` (nouvel essai), `SET-02` (stockage), `SET-03` (diagnostic)
**Fichiers** : `exp04-echec-*.png`, `exp04-espace-*.png`, `exp04-galerie-*.png`, `exp04-annule-*.png`, clair et sombre, plus les `.svg` (1080 × 2400 px = 360 × 800 dp à 3x).

> Un seul **gabarit**, plusieurs **causes**. Tous les textes sont des exemples à valider en test.

## Principe
Chaque cas répond à trois questions, dans cet ordre :
1. **Ce qui est sûr** : « Votre projet est intact. » (ligne avec coche, toujours en premier).
2. **Ce qui s'est passé**, en une ou deux phrases simples, sans jargon ni code en premier plan.
3. **Ce qu'on peut faire**, avec une action principale claire.

Le contexte du projet demande une gestion claire des erreurs, avec des états d'échec et d'annulation conçus. L'utilisateur ne doit jamais se demander s'il a perdu son travail.

## Gabarit
| Zone | Contenu |
|---|---|
| Barre supérieure | Fermer (✕), « Export ». ✕ et Retour ramènent à l'accueil, le projet est enregistré. |
| Pastille | Disque de 56 dp avec icône d'avertissement. Pas d'illustration alarmante, pas de ton dramatique. |
| Titre | 24 sp, la cause en quelques mots. |
| Rassurance | Coche + ce qui est conservé. |
| Explication | Texte de 15 sp, couleur secondaire. |
| Actions | Principale (56 dp), secondaire avec contour (48 dp), « Continuer à modifier » (bouton texte). |

## Cas 1 — Échec de rendu (`exp04-echec-*`)
- **Cause** : le rendu s'est arrêté pour une raison que l'application ne sait pas expliquer plus finement.
- **Texte** : « L'export n'a pas abouti. Un problème est survenu pendant la création de la vidéo. Rien n'a été enregistré dans votre galerie. »
- **Actions** : « Réessayer » (mêmes réglages) ; « Essayer en Standard · 720p » (affiché **seulement** si l'export échoué était en Haute) ; « Continuer à modifier ».
- **Détails techniques** : ligne repliée. Ouverte, elle donne un **code d'erreur** et l'étape concernée, avec « Copier » et un lien vers le diagnostic local (`SET-03`). Rien n'est envoyé automatiquement.
- Après **deux échecs de suite**, le texte suggère de redémarrer l'appareil ou de libérer de la mémoire.

## Cas 2 — Espace épuisé (`exp04-espace-*`)
- **Cause** : l'espace disque a manqué **pendant** le rendu (le contrôle de `EXP-01` n'a pas suffi : d'autres applications ont pu consommer l'espace).
- **Rassurance** : « Le fichier incomplet a été supprimé » : l'application doit réellement le supprimer, pour ne pas laisser de fichiers inutiles.
- **Texte** : indique combien libérer (« environ 120 Mo »). La valeur est calculée à partir de ce qui manquait.
- **Actions** : « Libérer de l'espace » (ouvre `SET-02`) ; « Exporter en Standard · 720p » (affiché seulement si l'espace actuel le permet) ; « Continuer à modifier ».

## Cas 3 — Vidéo créée mais non ajoutée à la galerie (`exp04-galerie-*`)
- **Cause** : le fichier est prêt mais le système a refusé de l'enregistrer dans la galerie.
- **Rassurance** : « Votre vidéo n'est pas perdue. » Une carte montre le fichier (nom, taille, « conservé dans GraceEdit »).
- **Actions** : « Réessayer l'ajout » ; « Enregistrer sous… » (sélecteur de dossier du système) ; « Continuer à modifier ».
- **Durée de conservation** du fichier dans l'espace de l'application : à fixer (point ouvert). L'utilisateur est averti avant toute suppression.

## Cas 4 — Annulation volontaire (`exp04-annule-*`)
- **Ce n'est pas un écran** : après la confirmation de `EXP-02`, l'utilisateur revient directement aux **réglages d'export** (`EXP-01`) avec ses choix conservés.
- Un **message temporaire** (barre en bas, couleurs inversées) dit : « Export annulé. Votre projet n'est pas modifié. » Il n'y a aucune action dedans : « Exporter » est juste en dessous.
- Les fichiers temporaires sont supprimés.

## Cas 5 — Export interrompu (non dessiné)
- **Cause** : l'application a été fermée par le système, l'appareil a redémarré ou la batterie s'est vidée pendant l'export.
- **Quand** : à la réouverture, l'écran apparaît **une seule fois**, avant l'accueil ou par-dessus.
- **Texte** : « Export interrompu. L'application a été fermée avant la fin. Votre projet est intact. » Même gabarit que le cas 1, avec l'action principale « Recommencer l'export ». Une reprise au milieu n'est pas prévue en V1.

## Autres causes possibles (même gabarit)
Média introuvable ou illisible pendant le rendu (renvoie à `PRJ-05`) · format non pris en charge sur cet appareil · mémoire insuffisante. Chacune garde les trois mêmes éléments : ce qui est sûr, ce qui s'est passé, quoi faire.

## Règles de langue et de typographie (valables pour tout le produit)
- **Espace insécable** entre un nombre et son unité (« 120 Mo », « 42 % », « 1080 p ») et avant « ? », « ! », « : », « ; » en français. Sans cela, « 120 » et « Mo » peuvent se retrouver sur deux lignes, comme je l'ai constaté en dessinant ce cas.
- Pas de jargon (« codec », « transcodage ») dans le texte principal. Il reste réservé aux détails techniques.
- Ne jamais blâmer l'utilisateur (« vous avez… »). Décrire la situation.

## Valeurs de design
- Pastille : disque de 56 dp, fond de surface, icône d'avertissement de 28 dp en couleur d'erreur (`#B3261E` clair, `#F2B8B5` sombre).
- La couleur d'erreur est utilisée **seulement pour l'icône** : le titre et le texte gardent leurs couleurs normales, pour que l'écran reste calme.
- Carte de fichier (cas 3) : 64 dp de haut, rayon 14 dp, fond de surface.
- Ligne « Détails techniques » : 56 dp, séparateurs de 1 dp, flèche de 20 dp.
- Message d'annulation : 48 dp de haut, rayon 8 dp, marges de 16 dp, couleurs inversées du thème.

## Accessibilité
- À l'ouverture, annonce en zone vivante : titre + rassurance (« L'export n'a pas abouti. Votre projet est intact. »). Le focus va au titre.
- L'avertissement est porté par l'icône **et** le texte, jamais par la couleur seule.
- L'ordre de lecture suit l'ordre visuel : titre, rassurance, explication, détails, actions.
- Cibles : 56 dp, 48 dp, lignes de 56 dp. « Détails techniques » a un état annoncé (« replié » ou « déplié »).
- Le message d'annulation est une zone vivante polie, lisible au moins 5 secondes.
- Grandes polices : le titre passe sur plus de lignes, la page défile, les boutons restent fixés en bas.

## Performance et confidentialité
- Les causes sont détectées par le code de retour du rendu : aucun journal n'est créé de façon permanente sans l'action de l'utilisateur.
- Le **rapport de diagnostic** n'est jamais envoyé automatiquement. L'utilisateur le copie ou le partage lui-même (`SET-03`).

## Points ouverts
- **Durée de conservation** d'une vidéo non ajoutée à la galerie (cas 3).
- **Reprise d'un export interrompu** : non prévue en V1.
- **Contenu exact du code d'erreur** et de l'écran de diagnostic (`SET-03`).
- **Seuil de suggestion** après échecs répétés (ici deux).
- **Cas « mémoire insuffisante »** : message distinct de l'espace disque, à rédiger.
