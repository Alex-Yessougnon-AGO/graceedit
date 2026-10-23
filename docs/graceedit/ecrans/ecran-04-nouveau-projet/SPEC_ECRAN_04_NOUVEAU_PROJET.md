# Écran 04 — Nouveau projet (préparation des médias)

**ID** : `IMP-02` · **Phase** : V1 · **Précédents** : `ENT-02` ou `HOM-01`, puis le sélecteur de médias du système (`IMP-01`) · **Suivant** : `EDT-01` (éditeur)
**Fichiers** : `imp02-pret-*.png` (état prêt), `imp02-problemes-*.png` (état avec problèmes), clair et sombre, plus les `.svg` (1080 × 2400 px = 360 × 800 dp à 3x).

> Les miniatures, dates et durées sont des **exemples**.

## Rôle
Après la sélection dans le sélecteur du système, permettre à l'utilisateur de **vérifier, ordonner et nettoyer** ses médias avant d'ouvrir l'éditeur, et rendre visibles les médias inutilisables et les préparations en cours. C'est l'écran des exigences « aperçu avant import », « sélection multiple », « miniatures en chargement ou en échec » et « média non pris en charge ».

## Règle de saut (premier succès rapide)
L'écran n'est **pas affiché** quand exactement **une** vidéo est choisie et qu'elle est utilisable immédiatement : le projet est créé avec un nom par défaut et l'éditeur s'ouvre. Dans tous les autres cas (plusieurs médias, média en préparation, média inutilisable), l'écran s'affiche. Le nom se change ensuite depuis l'éditeur ou la liste des projets.

## Contenu

| Zone | Contenu | Règle |
|---|---|---|
| Barre supérieure | Flèche de retour + « Nouveau projet » | Retour = annuler. Rien n'a été enregistré : aucune confirmation demandée. |
| Nom du projet | Champ prérempli « Projet du 19 oct. » avec icône de modification | Le nom par défaut est valide : l'utilisateur n'est pas obligé d'y toucher. |
| Résumé | « 3 vidéos · durée totale 4:10 » ou « 3 sélectionnés · 1 ignoré » | Mis à jour en direct. |
| Liste des médias | Ligne de 72 dp : poignée, miniature 96 × 54 dp avec durée, titre, durée et poids, bouton retirer | Voir « Lignes » ci-dessous. |
| « Ajouter des médias » | Ouvre de nouveau le sélecteur du système | Les nouveaux médias s'ajoutent à la fin de la liste. |
| Légende | Message court selon l'état | Voir « Messages ». |
| Bouton principal | « Commencer le montage » (56 dp) | Voir « Règle du bouton ». |

## Lignes
- **Titre** : date et heure de prise de vue lues dans les métadonnées (« 18 oct., 14:32 »). Si elles n'existent pas, le nom du fichier. Le nom du fichier complet est consultable dans les détails du média.
- **Ordre** : l'ordre de la liste est l'ordre initial sur la timeline. La poignée à gauche permet de glisser. Voir « Accessibilité » pour l'alternative sans glisser.
- **Retirer** : retire le média de **ce projet**, jamais du téléphone. Pas de confirmation (l'action est réversible en rajoutant le média).

| État de la ligne | Miniature | Texte | Remarque |
|---|---|---|---|
| Prêt | Image + durée | Titre · durée · poids | |
| En préparation (dessiné) | Bloc de surface avec « … » | « Préparation… 45 % » + barre de progression | Le pourcentage est réel, jamais simulé. |
| **Non pris en charge** (dessiné) | Bloc de surface + icône d'avertissement | Nom du fichier, « Format non pris en charge » avec icône, sur deux lignes | Ignoré automatiquement, mais reste listé pour être compris. |
| Illisible ou corrompu (non dessiné) | Idem | « Fichier illisible » | Même traitement. |
| Espace insuffisant (non dessiné) | Idem | « Espace insuffisant » | Voir « Points ouverts ». |

## Règle du bouton
- Le bouton est actif dès qu'**au moins un média utilisable** existe. Un média encore en préparation compte comme utilisable : la préparation continue dans l'éditeur, où elle est signalée.
- Libellé : « Commencer le montage » quand tous les médias sont utilisables ; « Commencer avec **N** médias » quand certains sont ignorés (N = nombre de médias utilisables).
- S'il n'y a plus aucun média utilisable, le bouton est désactivé et la légende explique pourquoi et propose « Ajouter des médias ».

## Messages (légende sous la liste)
- Tout va bien : « Vos fichiers d’origine ne sont pas modifiés. »
- Média ignoré : « Le média non pris en charge sera ignoré. » (avec icône d'information)
- Aucun média utilisable : « Aucun de ces médias ne peut être utilisé. Ajoutez-en d’autres pour continuer. »

## Valeurs de design
Mêmes valeurs que `ENT-02` et `HOM-01`. Ajouts : champ de saisie contour 1,5 dp (`#9A968D` clair, `#6B6D75` sombre), barre de progression piste `#D9D2C3` / `#3A3C45` et remplissage couleur du texte. Ce n'est pas une destination de la barre de navigation : l'écran est **plein écran**, sans barre du bas.

## Accessibilité
- Lecture d'une ligne : « 18 octobre, 14 h 32, 48 secondes, 38 mégaoctets, position 1 sur 3 ».
- **Réorganisation sans glisser** : actions d'accessibilité « Monter » et « Descendre » sur chaque ligne (obligatoire, le glisser seul n'est pas accessible à tous).
- Zones cliquables : poignée et bouton retirer d'au moins 48 × 48 dp, bien que les icônes fassent 24 dp.
- L'erreur est portée par l'icône et le texte, pas par la couleur seule.
- Grandes polices : titres de ligne sur deux lignes, la liste défile, le bouton principal reste fixé en bas.

## Confidentialité et permissions
- Les médias sont choisis dans le **sélecteur du système** : l'application ne reçoit que les fichiers choisis, sans demander l'accès à toute la galerie. À confirmer dans la documentation Android pour les versions plus anciennes, où un écran d'explication de permission (`IMP-03`) sera nécessaire.
- La mention « Vos fichiers d’origine ne sont pas modifiés » est exacte si le montage est non destructif. Si l'application **copie** les fichiers dans son espace, il faut en plus vérifier l'espace disponible avant et adapter le texte.

## Performance
- Ne pas copier ni transcoder de gros fichiers avant que l'utilisateur ait confirmé.
- Miniatures générées à la taille d'affichage, une par une, sans bloquer l'écran.
- Aucun effet de flou ni d'ombre.

## Points ouverts
- **Nombre maximal de médias** par projet : à définir avec l'équipe technique.
- **Copie ou référence des fichiers** : décision d'architecture qui change le texte rassurant et le contrôle d'espace.
- **Format de la vidéo (vertical, horizontal, carré)** : volontairement absent. Par défaut, il suit le premier média et se change dans l'éditeur.
- **Formats pris en charge** : dépendent de l'appareil. La liste exacte est à établir.
