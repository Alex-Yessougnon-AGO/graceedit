# Écran 27 — Composants communs : tri, renommer, messages temporaires, typographie

**ID** `CMP-01` · **Phase** V1 · **Fichiers** `cmp01-tri-*`, `cmp01-renommer-*`, `cmp01-messages-*`

## Menu de tri (`cmp01-tri-*`)
Feuille de bas d'écran « Trier par » : **Récents** (par défaut), **Plus anciens**, **Nom (A à Z)**. Choix unique, bouton radio, application **immédiate**, fermeture automatique. Valeur mémorisée.

## Fenêtre « Renommer » (`cmp01-renommer-*`)
Titre « Renommer le projet » ; champ prérempli avec le nom actuel (étiquette « Nom du projet », compteur « 16/60 ») ; « Enregistrer » (principal) et « Annuler » (texte).
- Longueur maximale **60** caractères ; espaces de début et de fin supprimés ; **nom vide interdit** (le bouton est désactivé).
- Deux projets peuvent porter le même nom.
- Le clavier du système s'ouvre avec le focus dans le champ ; la touche de validation du clavier équivaut à « Enregistrer ».

## Messages temporaires (`cmp01-messages-*`)
Trois variantes, barre de 48 dp, rayon 8 dp, marges 16 dp, couleurs inversées du thème :
- **Information** : texte seul (« Projet dupliqué »).
- **Avec action** : texte + action à droite (« 2 projets déplacés dans la corbeille · **Annuler** »).
- **Erreur** : icône d'avertissement + texte + action (« Impossible d'enregistrer · **Réessayer** »).
Règles : affichés **4 à 6 secondes** (plus longtemps avec un lecteur d'écran), **un seul à la fois**, en bas au-dessus de la barre d'outils, jamais en recouvrant un bouton principal. Un nouveau message remplace l'ancien. Le texte est annoncé en zone vivante polie (assertive pour les erreurs).

## Règles de typographie (tout le produit)
- **Espace insécable** : entre un nombre et son unité (« 120 Mo »), avant `%`, `?`, `!`, `:`, `;`, et dans les guillemets français (« Titre »).
- Apostrophe typographique `’` ; points de suspension `…` ; moins `−`.
- Pluriels corrects (« 1 projet », « 2 projets »).
- Ne jamais couper une chaîne au milieu d'un nombre et de son unité.

## Accessibilité
Cibles tactiles d'au moins 48 dp ; états annoncés par le texte et par la forme, jamais par la couleur seule ; grandes polices (200 %) : le contenu défile, les boutons principaux restent fixés en bas ; contrastes à mesurer sur les valeurs finales.

## Notes d'implémentation
Fournir ces éléments comme **composants réutilisables** du système de conception (feuille de choix, fenêtre de saisie, service de messages `SnackbarService`) et une fonction utilitaire de formatage qui insère les espaces insécables.

## Points ouverts
Durée exacte des messages ; accessibilité des messages pour les utilisateurs de lecteurs d'écran (durée prolongée).
