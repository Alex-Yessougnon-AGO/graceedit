# Écran 13 — Export réussi et partage

**ID** : `EXP-03` · **Phase** : V1 · **Précédent** : `EXP-02` · **Suivant** : `EXP-04` (échec ou annulation)
**Fichiers** : `exp03-reussite-*.png` (écran), `exp03-notification-*.png` (notification de fin), clair et sombre, plus les `.svg` (1080 × 2400 px = 360 × 800 dp à 3x pour l'écran).

> Titres, durées et tailles sont des **exemples**.

## Rôle
Confirmer que la vidéo **existe vraiment**, dire **où elle est**, permettre de la **partager** tout de suite et de revenir à l'édition. C'est le moment de « première création réussie » : l'écran reste calme, précis et sans fioritures, conformément à l'exigence de résultats sobres et professionnels du projet.

## Quand l'écran apparaît
Le contexte du projet décrit la fin du pipeline : *vérifier la sortie → enregistrer le résultat → montrer la vignette et les options de partage*. L'écran n'est donc affiché **qu'après** la vérification du fichier **et** son enregistrement dans la galerie. Il n'annonce jamais une réussite qui n'est pas confirmée.

## Contenu (de haut en bas)

| Zone | Contenu | Règle |
|---|---|---|
| Barre supérieure | Fermer (✕), « Export terminé » | ✕ et le geste Retour ramènent à l'**accueil**, jamais à l'écran de progression. |
| Aperçu | Vignette de la vidéo, bouton lecture, durée | Toucher lance la lecture dans l'application. |
| Statut | Pastille avec coche, « Vidéo enregistrée », « Dans la galerie de votre téléphone » | La coche et le texte portent le message (pas seulement la couleur). |
| Détails | Nom du fichier ; dimensions, durée et **taille réelle** | Plus de « ≈ » : le fichier existe, la taille est exacte. |
| « Partager » | Bouton principal, 56 dp | Ouvre le panneau de partage du système avec le fichier. |
| « Voir dans la galerie » | Bouton avec contour, 48 dp | Ouvre la vidéo dans la galerie ou l'application vidéo du téléphone. |
| « Continuer à modifier » | Bouton texte | Retourne à l'éditeur, le projet est déverrouillé. |

## Comportements
- **Lecture** : la vignette ouvre un lecteur simple (lecture, pause, barre de temps, sortie). Cela permet de **vérifier le résultat** sans quitter l'application.
- **Partager** : le fichier est transmis par le **panneau de partage du système**. L'application n'envoie rien en ligne elle-même et ne sait pas où l'utilisateur partage. Aucun filigrane n'est ajouté.
- **Voir dans la galerie** : si aucune application ne peut ouvrir la vidéo, message clair et repli sur le lecteur interne.
- **Nom du fichier** : par défaut le titre du projet (« Visite du marché.mp4 »). Sa modification est un point ouvert de `EXP-01`.
- **Aucune** demande de note, publicité, offre ou incitation à s'abonner sur cet écran en V1.

## Notification de fin (`exp03-notification-*`)
- La notification de progression (`EXP-02`) devient « **Export terminé** », avec le nom du projet, la durée et la taille.
- Actions : **Partager** et **Ouvrir**. Toucher la notification ouvre cet écran.
- Elle disparaît d'elle-même quand l'utilisateur ouvre l'écran de résultat.
- Si l'autorisation de notification a été refusée, le résultat reste accessible par un **bandeau** dans l'accueil et la liste des projets, jusqu'à ce que l'utilisateur l'ouvre.

## États et cas limites (non dessinés)
- **Fichier créé mais non enregistré dans la galerie** : message précis (« La vidéo est créée, mais n'a pas pu être ajoutée à la galerie ») avec l'action « Enregistrer sous… ». Traité dans `EXP-04`.
- **Fichier supprimé depuis la galerie** : en rouvrant le résultat, message « La vidéo est introuvable, elle a peut-être été supprimée » et action « Exporter de nouveau ».
- **Aucune application de partage disponible** : le panneau du système l'indique, l'écran reste inchangé.
- **Retour dans l'application après un long délai** : l'écran se recharge depuis le résultat enregistré, pas depuis la mémoire.

## Valeurs de design
- Vignette : 312 × 176 dp, rayon 16 dp ; disque de lecture de 56 dp, fond noir à 60 %, triangle ivoire ; badge de durée.
- Pastille de statut : disque de 28 dp couleur du texte principal, coche inversée ; titre 20 sp semi-gras, détail 14 sp couleur secondaire.
- Boutons : 56 dp (principal), 48 dp (contour), bouton texte avec zone de 48 dp au moins.
- Mêmes tokens de couleur que les écrans précédents. Pas d'accent vermillon sur cet écran.

## Accessibilité
- À l'ouverture, annonce en zone vivante : « Export terminé. Vidéo enregistrée dans la galerie. » Le focus se place sur le titre.
- Le bouton de lecture a un nom explicite : « Lire la vidéo exportée, 4 minutes 10 ».
- Les actions sont dans l'ordre de lecture : lecture, partager, voir dans la galerie, continuer à modifier.
- La coche n'est pas le seul signal : le texte « Vidéo enregistrée » le dit.
- Grandes polices : le nom du fichier et les détails passent sur plusieurs lignes, la page défile, les boutons restent fixés en bas.
- Contrastes : à mesurer sur les valeurs finales (texte secondaire, badge de durée).

## Performance et confidentialité
- La vignette vient de la **couverture déjà en cache** : aucun décodage de la vidéo exportée tant que l'utilisateur ne touche pas « Lire ».
- Aucune donnée n'est envoyée en ligne. La mesure d'usage éventuelle est à définir séparément et doit être locale ou soumise à consentement.

## Points ouverts
- **Lecteur interne ou ouverture directe dans la galerie** pour la vignette : j'ai choisi le lecteur interne pour vérifier sans quitter l'application.
- **« Enregistrer sous… »** (choix du dossier) : utile mais non prévu en V1 hors cas d'échec.
- **Partage direct** vers des applications fréquentes : non prévu ; le panneau du système suffit.
- **Raccourci « Nouveau projet »** sur cet écran : volontairement absent, pour ne pas distraire.
- **Historique des exports** d'un projet (dernier export, date) : à étudier dans les détails du projet (`PRJ-02`).
- **Demandes de note ou d'avis** : exclues en V1 ; à réexaminer plus tard avec soin.
