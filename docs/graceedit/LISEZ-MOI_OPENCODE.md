# GraceEdit V1 — Dossier de remise pour opencode

**À lire en premier.** Ce dossier contient tout ce qu'il faut pour réaliser la **V1** de GraceEdit : un éditeur vidéo mobile **Android d'abord**, qui fonctionne **hors connexion**, sans compte. Il décrit 27 écrans (dossiers), leur ordre, leur enchaînement et leur comportement.

## Contenu
| Fichier ou dossier | À quoi il sert |
|---|---|
| `LISEZ-MOI_OPENCODE.md` | Ce fichier : règles de travail |
| `AGENTS.md` | **Règles permanentes** à copier à la racine du dépôt (opencode les relit à chaque session) |
| `PROMPT_DEMARRAGE_OPENCODE.md` | **Le message à coller** pour lancer opencode, et la mise en place |
| `suivi/` | Modèles de suivi : `AVANCEMENT.md`, `DECISIONS.md`, `QUESTIONS.md`, `RAPPORT_FINAL.md` |
| `RESTE_A_FAIRE.md` | Ce qui reste à faire par un humain avant publication |
| `FLUX_V1.md` | **L'ordre des écrans, la navigation, le fonctionnement et les actions attendues**, machines d'états, modèle de données, ordre de réalisation |
| `INVENTAIRE_ECRANS_V1.md` | Liste des écrans, identifiants, dossiers, état |
| `design/DESIGN_TOKENS.md` et `design/tokens.json` | Couleurs, typographie, dimensions, règles visuelles (valeurs exactes) |
| `design/ASSETS_APPLICATION.md` | Icône d'application (couches adaptatives), icône de notification, splash, polices, jeu d'icônes |
| `design/icones/` · `design/icone-application/` · `design/icone-notification/` · `design/logo/` | Les fichiers correspondants (SVG et PNG) |
| `PHASE2_PLAN.md` | La version **suivante** (à ne pas implémenter ; seulement les points d'extension de §4) |
| `ecrans/NN-nom/` | Pour chaque écran : `SPEC_*.md` (comportement) et les images (`*-planche.png` = clair et sombre côte à côte ; `*-clair.png`, `*-sombre.png` = taille réelle 1080 × 2400 px, soit 360 × 800 dp à 3x) |

## Règles de travail (à suivre à la lettre)
1. **Suivre l'ordre de `FLUX_V1.md` §9** (jalons M0 à M7). Ne pas commencer un jalon avant que le précédent soit fonctionnel.
2. **Pour chaque écran, lire la fiche `SPEC_*.md` en entier avant de coder.** Elle décrit : le rôle, d'où l'on vient, où mène chaque action, les états, l'accessibilité et les points ouverts.
3. **Ne rien inventer.** Pas d'écran, de bouton, d'option ni de réglage qui ne figure pas dans les fiches. Si un cas n'est pas décrit : appliquer la **politique de décision autonome de `AGENTS.md` §4** (valeur de départ de la fiche, sinon option la plus simple conforme aux règles), la consigner dans `suivi/DECISIONS.md`, et **continuer** sans bloquer.
4. **Pas de fonction factice.** Un bouton visible doit faire ce que dit la fiche. Une fonction hors V1 n'apparaît pas du tout (pas de bouton désactivé « bientôt »).
5. **Les images fixent l'aspect, les fiches fixent le comportement, les jetons fixent les valeurs.** Les miniatures, titres, dates et durées des images sont des **exemples** ; les images de vidéo sont des illustrations.
6. **Aucun accès réseau.** Aucun compte, aucune statistique envoyée, aucun envoi automatique de rapport.
7. **Les médias d'origine ne sont jamais modifiés ni supprimés.** Les projets les référencent.
8. **Texte** : tout en fichiers de traduction (français source, anglais). Espaces insécables avant `? ! : ; %`, entre un nombre et son unité, et dans les guillemets français (`SPEC_ECRAN_27`). Apostrophe `’`.
9. **Accessibilité obligatoire** : zones tactiles ≥ 48 dp, jamais d'information par la couleur seule, alternative sans glisser à chaque geste, police jusqu'à 200 %, ordre de lecture logique, états annoncés.
10. **Appareils modestes** : pas de flou, d'ombres ni d'animations décoratives ; miniatures en cache, listes paresseuses, calculs lourds hors du fil d'interface, calcul des couleurs par la carte graphique.
11. **Thèmes** : clair et sombre sont **deux dessins**, pas une inversion automatique ; utiliser les valeurs de `design/tokens.json`.

## Pile technique recommandée (adaptable)
Flutter (Dart), Clean Architecture (couches présentation, domaine, données), **Riverpod 2.x** pour l'état, **GoRouter** pour la navigation, `fpdart` pour la gestion d'erreurs, `get_it`/`injectable` pour l'injection, base de données locale (par exemple Drift ou Isar), traitement vidéo par les API natives (encodeur matériel) via une couche d'abstraction. Chaque service externe (lecteur, rendu, stockage, notifications, sélecteur de fichiers) est **derrière une interface** pour être testable.

Si une autre pile est choisie, **conserver** : les routes de `FLUX_V1.md`, les états, le modèle de données et les règles ci-dessus.

## Définition de « terminé » pour un écran
- Fidèle à l'image, dans **les deux thèmes**.
- **Toutes** les actions de la fiche fonctionnent et mènent à la bonne destination.
- **Tous** les états listés dans la fiche sont atteignables et testés.
- Accessibilité vérifiée (lecteur d'écran, police à 200 %, cibles ≥ 48 dp).
- Aucune chaîne en dur ; aucune action non décrite.
- Tests : widgets pour les états, tests unitaires pour la logique (import, sauvegarde, export, corbeille, tri, formatage).

## Décisions déjà prises (ne pas rouvrir sans demande)
Aucun compte en V1 · suppression de projet : **corbeille de 30 jours et suppression définitive**, au choix · pas de voix off, pas d'enregistrement caméra, pas de filtres ni de vitesse, pas de sous-titres, pas de transitions en V1 · pas de catalogue de musique · export Haute 1080p et Standard 720p, 30 images/s · trois destinations de navigation : Accueil, Projets, Réglages.

## Points ouverts (valeurs de départ proposées dans chaque fiche)
Seuils de stockage faible · nombre maximal de médias par projet · polices et licences · durée exacte des messages · reprise d'un export interrompu (non prévue) · version minimale d'Android (détermine si `IMP-03` existe). Chaque fiche liste les siens en fin de document.

## Démarrage suggéré
« Lis `LISEZ-MOI_OPENCODE.md`, `FLUX_V1.md` et `design/DESIGN_TOKENS.md`. Réalise le jalon **M0** (socle) : thème clair/sombre avec les jetons, internationalisation fr/en, navigation GoRouter avec les routes de `FLUX_V1.md` §3 et la barre de navigation à trois destinations, base de données locale, services de stockage et de sauvegarde. Puis le jalon **M1**. Pour chaque écran, lis d'abord sa fiche dans `ecrans/`. En cas de doute, écris la question dans `QUESTIONS.md` plutôt que d'improviser. »
