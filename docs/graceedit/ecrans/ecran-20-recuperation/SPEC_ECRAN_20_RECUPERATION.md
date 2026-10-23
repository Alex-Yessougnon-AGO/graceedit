# Écran 20 — Récupération après fermeture inattendue

**ID** `SYS-01` · **Phase** V1 · **Route** modal au lancement (par-dessus `/home`) · **Déclencheur** au démarrage, si un projet a été ouvert et que l'application s'est fermée sans sortie normale · **Fichier** `sys01-recup-*`

## Rôle
Rassurer et proposer de **reprendre exactement** où l'on s'était arrêté.

## Contenu
Feuille de bas d'écran par-dessus l'accueil (assombri) :
- Titre « Reprendre où vous en étiez ? »
- Miniature + titre du projet + « Dernière sauvegarde il y a 2 min » (date réelle de la dernière sauvegarde).
- Ligne avec coche : « GraceEdit s'est fermé de façon inattendue. Votre travail a été récupéré. »
- **« Reprendre le projet »** (principal) → `/editor/:id` à l'état récupéré.
- **« Plus tard »** (texte) → ferme la feuille ; le projet apparaît dans « Reprendre » avec l'indication « Brouillon récupéré ».

## Règles
- Affichée **une seule fois** par incident, avant toute autre fenêtre.
- Si **aucune** donnée récupérée n'est plus récente que la dernière sauvegarde normale, **ne rien afficher**.
- Si la récupération est impossible (fichier illisible) : même gabarit que `EXP-04`, texte « Nous n'avons pas pu récupérer les dernières modifications. La dernière version enregistrée est conservée. »
- Un export interrompu relève de `EXP-04`, pas de cet écran.

## Accessibilité
Cibles tactiles d'au moins 48 dp ; états annoncés par le texte et par la forme, jamais par la couleur seule ; grandes polices (200 %) : le contenu défile, les boutons principaux restent fixés en bas ; contrastes à mesurer sur les valeurs finales. À l'ouverture : annonce « Récupération. Votre travail a été récupéré. » ; focus sur le titre.

## Notes d'implémentation
Écriture d'un **journal de récupération** à chaque modification (court délai) ; drapeau « sortie propre » enregistré à la fermeture normale ; au démarrage, comparer et proposer. Ne jamais écraser la dernière sauvegarde valide avant confirmation.

## Points ouverts
Délai d'écriture du journal ; conservation de plusieurs versions récupérées (non prévu en V1).
