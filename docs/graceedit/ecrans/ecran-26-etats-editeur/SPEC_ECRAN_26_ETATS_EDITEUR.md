# Écran 26 — États de l'éditeur : timeline vide, lecture, média manquant, paysage

**ID** `EDT-08` · **Phase** V1 · **Route** `/editor/:id` · **Fichiers** `edt08-vide-*`, `edt08-lecture-*`, `edt08-manquant-*`, `edt08-paysage-*` (portrait : 1080 × 2400 px ; paysage : 2400 × 1080 px)

## Timeline vide (`edt08-vide-*`)
- Titre de la barre : « Nouveau projet » ; « Exporter » **désactivé**.
- Aperçu : icône, « Aucun média », « Ajoutez une vidéo pour commencer. »
- Timeline : emplacement en pointillés avec « + » et « Ajouter des médias » (même action que l'outil « Ajouter » : sélecteur système).
- Lecture, annuler, rétablir : désactivés (atténués **et** déclarés désactivés). Barre d'outils : seul « Ajouter » est actif.
- Atteint en supprimant le dernier clip, ou depuis un projet vide.

## Lecture en cours (`edt08-lecture-*`)
- Le bouton central devient **pause** (deux barres). Le temps courant avance ; la tête de lecture reste **fixe au centre**, la timeline défile sous elle.
- La barre d'outils reste visible. Toucher l'aperçu ou le bouton met en pause. La lecture s'arrête à la fin du projet, retour au début **sans** relancer.
- Pendant la lecture : pas de sélection de clip, pas de rognage ; un toucher sur la timeline met en pause puis déplace.
- Lecture suspendue automatiquement si l'application passe en arrière-plan ou si un appel arrive.

## Clip à média manquant (`edt08-manquant-*`)
- Le clip concerné affiche une **tuile d'avertissement** (icône + « Média manquant »). L'aperçu, quand la tête est dessus, montre l'icône, « Média manquant », « Ce clip utilise un fichier introuvable. » et le bouton **« Reconnecter »** → `/projects/:id/relink` (`PRJ-05`).
- Le projet reste **éditable** (couper, déplacer, supprimer le clip) mais « Exporter » mène au contrôle de `EXP-01` qui bloque tant qu'un média manque.

## Paysage (`edt08-paysage-*`)
- Aperçu à **gauche** (280 × 158 dp), timeline à **droite** (largeur restante), ligne de lecture sous l'aperçu (temps, lecture, annuler, rétablir).
- Barre d'outils **horizontale en bas**, 64 dp, six outils visibles (Ajouter, Audio, Texte, Ajuster, Format, Couverture).
- Les feuilles (style, audio, format…) s'ouvrent en **panneau à droite** de 320 dp au lieu d'une feuille de bas d'écran.
- **Tablette** : même disposition que le paysage ; contenu centré, largeur maximale 960 dp.

## Accessibilité
Cibles tactiles d'au moins 48 dp ; états annoncés par le texte et par la forme, jamais par la couleur seule ; grandes polices (200 %) : le contenu défile, les boutons principaux restent fixés en bas ; contrastes à mesurer sur les valeurs finales. L'état de lecture est annoncé (« Lecture », « Pause »).

## Notes d'implémentation
Un seul widget d'éditeur avec une mise en page adaptative (`LayoutBuilder`) ; états `empty`, `ready`, `playing`, `missingMedia`. Le lecteur est un service injecté.

## Points ouverts
Largeur minimale du paysage sur petits téléphones (< 360 dp de haut) ; mode plein écran de l'aperçu (non prévu en V1).
