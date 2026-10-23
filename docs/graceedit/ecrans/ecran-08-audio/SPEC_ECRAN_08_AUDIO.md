# Écran 08 — Audio : musique, volume et fondus

**ID** : `EDT-04` · **Phase** : V1 (commandes audio de base) · **Précédent** : `EDT-03` · **Suivant** : `EDT-05` (ajustements visuels)
**Fichiers** : `edt04-mixage-*.png`, `edt04-selection-*.png`, `edt04-fondus-*.png`, clair et sombre, plus les `.svg` (1080 × 2400 px = 360 × 800 dp à 3x).

> Trois **situations de l'éditeur** (`EDT-01`). Les titres, durées et formes d'onde sont des **exemples**.

## Périmètre de la V1
Le brief demande des « commandes audio de base » en V1 : ajouter de la musique, régler les volumes, quelques réglages simples.
- **La musique vient des fichiers de l'appareil.** Il n'y a pas de catalogue de musique en V1 : un catalogue pose des questions de droits et de licence (section 12 du contexte du projet) qui relèvent d'une phase ultérieure.
- **La voix off n'est pas dans cette fiche.** Elle figure dans le périmètre général de l'éditeur mais pas dans la liste explicite de la Phase 1. Je l'ai laissée en Phase 2 en attendant ta décision (voir « Points ouverts »).

## Situation 1 — Mixage (`edt04-mixage-*`)
Ouvert par l'outil **Audio** de la barre d'outils générale (`EDT-01`, aucun clip sélectionné). Une feuille non modale laisse l'aperçu et la timeline visibles.

| Ligne | Contenu | Règle |
|---|---|---|
| Son de la vidéo | Icône haut-parleur (coupe le son au toucher), curseur 0 à 100 %, valeur | Règle le son d'origine de **tous** les clips. |
| Musique · titre | Même principe, avec le nom du morceau | Une ligne par élément audio ajouté. |
| Ajouter de la musique | Bouton avec contour, 48 dp | Ouvre le sélecteur de fichiers du système, filtré sur l'audio. |

- **Ajout** : l'élément audio démarre à la **tête de lecture**. Il est coupé à la fin du projet s'il est plus long, et jamais répété en boucle.
- **Icône haut-parleur** : sert de bouton « couper le son ». Quand le son est coupé, l'icône change de forme (haut-parleur barré) et la valeur passe à « Coupé ».
- **Volume propre à un clip** : il se règle avec l'outil « Volume » de la barre d'outils du clip. Si les volumes des clips diffèrent, la ligne « Son de la vidéo » affiche « Personnalisé » au lieu d'une valeur.
- **Sans musique** : la ligne « Musique » n'apparaît pas, il reste la ligne « Son de la vidéo » et le bouton d'ajout.

## Situation 2 — Musique sélectionnée (`edt04-selection-*`)
- L'élément audio est sur la **voie audio** de la timeline : forme d'onde, contour épais et poignées de durée, durée indiquée à droite (« 1:30 »). La sélection est portée par la forme (contour, poignées), pas par la couleur seule.
- **Barre d'outils de l'audio** : un chevron de retour, puis **Volume**, **Fondu**, **Scinder**, **Supprimer**, **Plus**. « Volume » et « Fondu » ouvrent la même feuille (situation 3), positionnée sur la partie demandée. « Plus » contient Dupliquer.
- **Gestes** : glisser l'élément le déplace dans le temps, glisser une poignée le rogne. Ce sont les mêmes règles qu'en `EDT-02` (aimantation à la tête de lecture et aux bords des clips, zone tactile d'au moins 48 dp, poignées à l'extérieur si l'élément fait moins de 40 dp).

## Situation 3 — Volume et fondus (`edt04-fondus-*`)
Feuille non modale avec :
- un **petit aperçu de l'élément** (forme d'onde) montrant les rampes d'entrée et de sortie : le fondu se voit autant qu'il se règle ;
- trois curseurs : **Volume** (0 à 100 %), **Fondu en entrée** (0 à 10 s), **Fondu en sortie** (0 à 10 s), chacun avec sa valeur écrite à droite (« 5,0 s »).

Règles :
- La somme des deux fondus ne peut pas dépasser la durée de l'élément.
- Les valeurs s'affichent avec une virgule décimale en français.
- Chaque glissement de curseur est une **seule** action d'annulation, enregistrée au relâchement.
- Pendant le glissement, l'aperçu audio joue un court extrait (si la lecture est active) afin que l'utilisateur entende le réglage.

## États de la forme d'onde (non dessinés)
- **En préparation** : ligne plate et texte « Préparation de l'audio… », sans animation de scintillement.
- **Échec** : icône d'avertissement et « Audio illisible », l'élément reste supprimable.
- **Fichier introuvable** (déplacé ou supprimé) : même traitement que le média manquant, avec l'action « Reconnecter » (`PRJ-05`).

## Valeurs de design
- Voie audio : fond de surface, forme d'onde en couleur secondaire. Élément sélectionné : contour de 3 dp couleur du texte et poignées de 14 dp.
- Curseurs : piste de 4 dp, curseur de 20 dp, zone tactile d'au moins 48 dp de haut. Libellé et valeur sur la ligne au-dessus.
- Lignes du mixage : 72 dp de haut. Bouton d'ajout : 48 dp, contour de 2 dp, pleine largeur.
- Aperçu des fondus : 48 dp de haut, rayon 8 dp, rampes tracées en 2 dp.

## Accessibilité
- Tous les curseurs sont ajustables au clavier et par action d'accessibilité, par pas de 5 % pour le volume et de 0,5 s pour les fondus. La valeur est annoncée à chaque pas.
- L'état « coupé » est annoncé : « Son de la vidéo, coupé ». Il est aussi montré par la forme de l'icône et par le texte, pas par la couleur.
- La forme d'onde est décorative pour les lecteurs d'écran. Le nom et la durée de l'élément sont lus : « Musique, Ambiance douce, 1 minute 30 ».
- Les rampes de l'aperçu ne sont pas le seul signal : les durées de fondu sont écrites en toutes lettres.
- Grandes polices : les libellés passent sur deux lignes, la feuille défile.

## Performance (appareils modestes)
- La forme d'onde est calculée **une seule fois** en arrière-plan, mise en cache sous forme réduite, et jamais recalculée à chaque zoom.
- Le décodage des longs fichiers audio se fait par morceaux, sans bloquer l'écran.
- Les formats audio pris en charge dépendent de l'appareil. Un format non pris en charge est signalé à l'ajout, comme pour les médias de `IMP-02`.

## Droits et responsabilité
L'application ne fournit aucune musique en V1. Le message d'information sur les droits d'auteur des fichiers ajoutés (par exemple lors de l'ajout ou de l'export) est à valider avec un conseil juridique. Je n'ai prévu aucun écran de mise en garde bloquant.

## Points ouverts
- **Voix off** : à décider. Si elle entre en V1, il faut en plus : explication de permission du micro, écran d'enregistrement (compte à rebours, niveau d'entrée, pause), écran de relecture. Proposition actuelle : Phase 2.
- **Volume au-dessus de 100 %** : utile pour un son d'origine faible, mais risque de saturation. Non prévu en V1.
- **Plusieurs éléments audio** : une seule voie en V1, ou empilement automatique (même question que pour le texte).
- **« Détacher l'audio »** d'un clip vidéo (action de « Plus » dans `EDT-01`) : crée un élément audio et coupe le son du clip. À confirmer.
- **Égalisation, réduction de bruit** : non prévues en V1.
- **Mixage global ou par clip** : j'ai prévu les deux (global dans le panneau, par clip dans la barre du clip). À valider en test pour qu'il reste simple.
