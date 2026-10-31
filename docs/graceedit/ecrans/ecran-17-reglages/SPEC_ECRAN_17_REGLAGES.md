# Écran 17 — Réglages

**ID** `SET-01` · **Phase** V1 · **Route suggérée** `/settings` · **Accès** barre de navigation, onglet « Réglages » · **Fichiers** `set01-liste-*`, `set01-theme-*` (clair et sombre, 1080 × 2400 px)

## Rôle
Régler l'apparence, la langue, l'accessibilité et la suppression, et donner accès au stockage et à l'aide. Aucun compte, aucun réglage en ligne en V1.

## Contenu (liste défilante, sections)
| Section | Ligne | Valeur / contrôle | Destination |
|---|---|---|---|
| Apparence | Thème | « Système » (défaut), « Clair », « Sombre » | Feuille de choix (`set01-theme-*`) |
| Apparence | Langue | « Français » (suit la langue de l'appareil par défaut) | Feuille de choix : Français, English |
| Accessibilité | Réduire les animations | Interrupteur, **suit le réglage de l'appareil** par défaut | — |
| Accessibilité | Retour haptique | Interrupteur, activé par défaut | — |
| Projets | Suppression | « Demander à chaque fois » (défaut) ou « Toujours mettre à la corbeille » | Feuille de choix |
| Projets | Corbeille | Nombre de projets | `/projects/trash` (`PRJ-06`) |
| Stockage et aide | Stockage et cache | Espace utilisé par GraceEdit | `/settings/storage` (`SET-02`) |
| Stockage et aide | Aide et à propos | — | `/settings/help` (`SET-03`) |

## Comportements
- **Thème** : le changement est **immédiat** et enregistré localement. « Système » suit le mode clair/sombre de l'appareil en continu.
- **Langue** : le changement s'applique immédiatement, sans redémarrage. Toutes les chaînes viennent des fichiers de traduction (français = langue source, anglais = première traduction).
- **Interrupteur** : état **activé** = piste pleine + coche dans le curseur ; **désactivé** = contour + curseur plein. L'état est aussi annoncé aux lecteurs d'écran.
- **Suppression** : si « Toujours mettre à la corbeille », la fenêtre de choix de `PRJ-03` n'est plus affichée ; la suppression définitive reste accessible depuis la corbeille.
- La barre de navigation reste visible ; « Réglages » est l'onglet actif.

## États
Liste normale · feuille de thème (`set01-theme-*`) · feuille de langue (`set01-langue-*` : « Langue de l'appareil » (défaut, avec la langue actuelle), « Français », « English ») · feuille de suppression (`set01-suppression-*` : « Demander à chaque fois » (défaut) ou « Toujours mettre à la corbeille »). Même gabarit : choix unique, bouton radio, valeur actuelle cochée, application immédiate.

## Règles de langue
Espace insécable entre nombre et unité (« 1,8 Go »), avant `? ! : ; %`, et dans les guillemets français.

## Accessibilité
Cibles tactiles d'au moins 48 dp ; états annoncés par le texte et par la forme, jamais par la couleur seule ; grandes polices (200 %) : le contenu défile, les boutons principaux restent fixés en bas ; contrastes à mesurer sur les valeurs finales. Chaque ligne est un seul élément annoncé (« Thème, Système, bouton »). Les interrupteurs annoncent « activé » ou « désactivé ».

## Notes d'implémentation
Préférences stockées localement (par exemple `shared_preferences` ou la base locale). Le thème et la langue sont des états globaux observés par toute l'application. Aucune requête réseau.

## Points ouverts
Liste exacte des langues au lancement (FR et EN prévues) ; réglage de qualité d'export par défaut (non prévu en V1).
