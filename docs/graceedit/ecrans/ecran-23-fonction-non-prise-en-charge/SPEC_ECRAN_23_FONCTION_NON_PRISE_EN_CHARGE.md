# Écran 23 — Fonction non prise en charge par l'appareil

**ID** `SYS-04` · **Phase** V1 · **Route** fenêtre modale par-dessus l'écran concerné · **Exemple dessiné** export en 1080p sur un appareil qui n'en est pas capable · **Fichier** `sys04-dialog-*`

## Principe
Le projet interdit de présenter comme garanti ce que l'appareil ne peut pas faire. **Première règle : ne pas afficher** l'option impossible (ex. `EXP-01` n'affiche pas « Haute · 1080p »). Cette fenêtre n'existe que si l'utilisateur **atteint** un cas non anticipé (ex. projet ouvert sur un autre appareil, réglage restauré).

## Contenu
Fenêtre « Option non disponible » ; texte « Votre téléphone ne peut pas exporter en 1080p. Choisissez Standard · 720p. » ; actions **« Choisir Standard · 720p »** (principal : applique le repli et revient à l'écran) et **« Fermer »**.

## Autres cas couverts par le même gabarit
| Cas | Titre | Repli proposé |
|---|---|---|
| Format vidéo non lisible | « Format non pris en charge » | « Choisir un autre fichier » |
| Effet non disponible | « Réglage non disponible » | « Continuer sans cet effet » |
| Mémoire insuffisante | « Mémoire insuffisante » | « Fermer d'autres applications » puis « Réessayer » |

## Règles
Toujours proposer **un repli concret**. Pas de jargon (« codec », « encodeur ») dans le texte principal. Le détail technique est dans le rapport de diagnostic.

## Accessibilité
Cibles tactiles d'au moins 48 dp ; états annoncés par le texte et par la forme, jamais par la couleur seule ; grandes polices (200 %) : le contenu défile, les boutons principaux restent fixés en bas ; contrastes à mesurer sur les valeurs finales. Focus sur le titre puis sur l'action de repli.

## Notes d'implémentation
Détection des capacités une seule fois, mise en cache (`DeviceCapabilities`), consultée avant d'afficher toute option dépendante du matériel.

## Points ouverts
Liste complète des capacités testées (résolutions, formats, effets).
