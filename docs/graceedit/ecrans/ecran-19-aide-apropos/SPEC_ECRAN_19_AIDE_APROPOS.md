# Écran 19 — Aide, diagnostic et à propos

**ID** `SET-03` · **Phase** V1 · **Routes suggérées** `/settings/help`, `/settings/help/diagnostic` · **Accès** `SET-01` ; lien « Détails techniques » d'un échec d'export (`EXP-04`) · **Fichiers** `set03-liste-*`, `set03-diag-*`

## Contenu de la liste
| Section | Ligne | Destination |
|---|---|---|
| Aide | Revoir la présentation | Rejoue `ENT-02` (bouton « Monter une vidéo » inchangé) |
| Aide | Questions fréquentes | Page d'aide **intégrée à l'application**, lisible hors connexion |
| Aide | Rapport de diagnostic (« Rien n'est envoyé automatiquement ») | `/settings/help/diagnostic` |
| À propos | Version (« 1.0.0 (1) ») | — (un appui long copie la version) |
| À propos | Licences libres | Liste des composants libres et de leurs licences (dont la police Inter, licence OFL) |
| À propos | Conditions d'utilisation, Confidentialité | Texte intégré ou page web ; **si web et hors connexion**, message « Connexion nécessaire » |

## Rapport de diagnostic (`set03-diag-*`)
- **Ce qu'il contient** (coche) : modèle de l'appareil et version d'Android, version de GraceEdit, espace libre et mémoire, derniers événements d'erreur.
- **Ce qu'il ne contient pas** (croix) : vidéos, photos, projets, nom, position.
- Aperçu du texte du rapport dans un encadré à chasse fixe.
- Actions : **« Copier le rapport »** (principal) et **« Partager »** (par le panneau de partage du système).
- **Aucun envoi automatique.** L'utilisateur copie ou partage lui-même.

## Comportements
Le rapport est généré **à l'ouverture de l'écran**, sur l'appareil. Les événements d'erreur sont limités aux 20 derniers, sans contenu utilisateur. Après « Copier » : message « Rapport copié ».

## Accessibilité
Cibles tactiles d'au moins 48 dp ; états annoncés par le texte et par la forme, jamais par la couleur seule ; grandes polices (200 %) : le contenu défile, les boutons principaux restent fixés en bas ; contrastes à mesurer sur les valeurs finales. Les listes « contient / ne contient pas » sont lues avec « inclus » et « non inclus » (la coche et la croix ne sont pas les seuls signaux).

## Notes d'implémentation
Journal local d'erreurs borné (anneau de 20 entrées), sans données personnelles. Générateur de rapport pur et testable. Licences générées par l'outil de gestion des dépendances.

## Points ouverts
Texte juridique final (conditions, confidentialité) ; contenu de la page « Questions fréquentes ».
