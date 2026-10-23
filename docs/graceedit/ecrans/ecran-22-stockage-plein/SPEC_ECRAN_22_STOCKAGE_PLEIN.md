# Écran 22 — Stockage faible et stockage plein

**ID** `SYS-03` · **Phase** V1 · **Routes** bandeau dans `/home`, `/projects` ; écran `/system/storage-full` · **Fichiers** `sys03-bandeau-*`, `sys03-plein-*`

## Deux niveaux
1. **Stockage faible** (reste moins de 300 Mo, valeur de départ) : **bandeau** sous la barre de titre de l'accueil et des projets : icône d'avertissement + « Espace faible : il reste 180 Mo » + lien **« Gérer »** → `/settings/storage`. Il disparaît dès que l'espace repasse au-dessus du seuil. Le contenu de la page est décalé vers le bas (le bandeau ne recouvre rien).
2. **Stockage plein** (impossible d'écrire) : **écran** déclenché par une tentative d'importer, de créer un projet ou d'enregistrer.
   - Titre « Plus assez d'espace sur le téléphone » ; ligne avec coche « Vos projets sont intacts. » ; texte « GraceEdit ne peut plus enregistrer ni importer. Libérez de l'espace pour continuer. »
   - Actions : **« Libérer de l'espace »** (principal) → `/settings/storage` ; **« Voir la corbeille »** → `/projects/trash` ; **« Plus tard »** (retour).

## Règles
- Le bandeau est **non bloquant** et non répété une fois fermé pendant la session (réapparaît au lancement suivant si le problème persiste).
- L'écran « plein » ne s'affiche qu'au moment où une action échoue, jamais au lancement.
- Les contrôles avant export (`EXP-01`) restent séparés et plus précis.

## Accessibilité
Cibles tactiles d'au moins 48 dp ; états annoncés par le texte et par la forme, jamais par la couleur seule ; grandes polices (200 %) : le contenu défile, les boutons principaux restent fixés en bas ; contrastes à mesurer sur les valeurs finales. Le bandeau est annoncé comme alerte ; le lien « Gérer » a un nom explicite : « Gérer le stockage ».

## Notes d'implémentation
Observateur d'espace libre (au lancement, au retour dans l'application, avant toute écriture lourde). Seuils configurables.

## Points ouverts
Valeur des seuils (300 Mo et 50 Mo proposés) ; texte différent si l'espace est insuffisant **pendant** un export (traité dans `EXP-04`).
