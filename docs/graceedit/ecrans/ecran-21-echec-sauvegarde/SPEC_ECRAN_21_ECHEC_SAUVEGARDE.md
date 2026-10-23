# Écran 21 — Échec de sauvegarde (état « Non enregistré »)

**ID** `SYS-02` (complète `EDT-06`) · **Phase** V1 · **Route** feuille par-dessus `/editor/:id` · **Déclencheur** échec d'écriture de la sauvegarde automatique · **Fichier** `sys02-echec_save-*`

## Rôle
Prévenir sans paniquer, empêcher la perte de travail, proposer une sortie.

## Contenu
- **État dans la barre supérieure** : sous le titre, « Enregistré » devient **« Non enregistré »** avec icône d'avertissement, en couleur d'erreur (texte + icône).
- **Feuille** (une seule fois par échec) : titre « Vos modifications ne sont pas enregistrées » ; texte « Le téléphone n'a pas pu enregistrer le projet : il manque de l'espace. Ne fermez pas l'application avant d'avoir résolu le problème. » ; actions **« Réessayer »** (principal) et **« Libérer de l'espace »** → `/settings/storage`.
- Fermer la feuille ne cache **pas** l'état « Non enregistré » : il reste dans la barre jusqu'à réussite.

## Règles
- La cause est dite en mots simples (espace insuffisant, fichier verrouillé, autre).
- **Nouvelle tentative automatique** toutes les 10 secondes (maximum 6 fois), puis à chaque modification.
- Réussite : retour à « Enregistré » avec message « Projet enregistré ».
- **Sortie de l'éditeur** pendant l'échec : fenêtre « Quitter sans enregistrer ? » avec « Réessayer » (par défaut) et « Quitter ». Les modifications en mémoire sont conservées dans le journal de récupération (`SYS-01`) tant que possible.

## Accessibilité
Cibles tactiles d'au moins 48 dp ; états annoncés par le texte et par la forme, jamais par la couleur seule ; grandes polices (200 %) : le contenu défile, les boutons principaux restent fixés en bas ; contrastes à mesurer sur les valeurs finales. L'apparition de « Non enregistré » est annoncée (zone vivante assertive).

## Notes d'implémentation
États de sauvegarde : `saved`, `saving`, `failed(reason)`, `recovered`. L'indicateur de la barre supérieure observe cet état. File d'écriture avec réessai exponentiel.

## Points ouverts
Nombre de réessais automatiques ; « Enregistrer une copie » dans un autre dossier (non prévu en V1).
