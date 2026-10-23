# Écran 01 — Splash (page de lancement)

**ID** : `ENT-01` · **Phase** : V1 · **Fichiers** : `splash-clair.png`, `splash-sombre.png` (1080 × 2400 px = 360 × 800 dp à 3x)

## Rôle
Masquer le temps d'initialisation de l'application (base locale, thème, état de la session) et ouvrir l'application à la marque sans friction. L'utilisateur ne fait rien sur cet écran.

## Contenu
- Le symbole GraceEdit seul, centré exactement (horizontalement et verticalement), 120 dp de large.
- Rien d'autre : ni nom, ni texte, ni barre de progression, ni numéro de version.

## Valeurs de design

| Élément | Thème clair | Thème sombre |
|---|---|---|
| Fond | `#F6F2EA` (ivoire) | `#14151A` (noir profond) |
| Anneau et barre du « G » | `#14151A` | `#F6F2EA` |
| Bloc d'accent | `#E2542B` | `#E2542B` |

Le thème suit le réglage du système au premier lancement, puis le choix de l'utilisateur dans les réglages. Les deux thèmes sont dessinés séparément, pas inversés automatiquement.

## Comportement
- **Durée** : exactement le temps d'initialisation réel. Aucun délai artificiel. Si l'initialisation dure moins de 300 ms, ne pas afficher de transition longue.
- **Destination** : premier lancement → onboarding ; sinon → accueil.
- **Mouvement (proposition)** : le bloc d'accent glisse de 8 dp vers sa position finale en 400 ms (courbe de décélération), puis l'écran reste fixe. Si l'utilisateur a activé « Réduire les animations », l'écran est statique.
- **Transition de sortie** : fondu de 200 ms vers l'écran suivant.

## États et cas limites
- **Initialisation échouée** (base locale illisible, stockage plein) : ne pas rester bloqué sur le splash. Passer à un écran d'erreur de récupération avec une action claire (réessayer). Cet écran est à concevoir dans le lot des états système.
- **Initialisation anormalement longue (> 5 s)** : afficher sous le symbole un court message statique, par exemple « Préparation en cours… ». Pas avant.
- **Appareil entrée de gamme** : aucun effet coûteux (flou, ombre portée, animation de particules). Le symbole est un tracé vectoriel simple.

## Accessibilité
- Libellé pour lecteur d'écran : « GraceEdit, chargement ». Annoncer une seule fois.
- Contraste fond/symbole : supérieur à 15:1 dans les deux thèmes.
- L'accent vermillon est décoratif : aucune information ne passe par cette couleur seule.

## Implémentation Android et Flutter
- Android 12 et suivants affichent déjà un splash système : le configurer avec **le même symbole et les mêmes couleurs de fond** (clair et sombre), pour éviter un double splash visible. Les dimensions exactes de la zone sûre de l'icône sont à vérifier dans la documentation Android avant de produire les fichiers.
- Android 11 et précédents : même rendu via un thème de lancement.
- Le splash Flutter ne doit s'afficher que si le splash système ne suffit pas (initialisation asynchrone). L'idéal est de n'avoir qu'un seul splash perçu.
- Le symbole est fourni en SVG (`splash-*.svg`) pour être converti en `VectorDrawable` côté Android et en `CustomPainter` ou en asset SVG côté Flutter.

## Points ouverts
- Le mouvement du bloc est une proposition, à valider en conditions réelles sur un appareil modeste.
- L'icône d'application adaptative n'est pas encore produite.
