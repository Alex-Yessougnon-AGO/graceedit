# Avancement — GraceEdit V1

Légende : ☐ non commencé · ◐ en cours · ✔ fait et contrôles passés · ⚠ fait avec écarts (voir DECISIONS) · ✖ bloqué (voir BLOQUE)

## Jalons
| Jalon | Contenu | État | Étiquette git | Date |
|---|---|---|---|---|
| M0 | Socle : jetons, thèmes clair/sombre, i18n fr/en, navigation et routes, base locale, services stockage et sauvegarde, utilitaire d'espaces insécables | ✔ | m0 | 2026-10-24 |
| M1 | Entrée (ENT-01, ENT-02), accueil (HOM-01), import (IMP-02, IMP-03) | ✔ | m1 | 2026-10-24 |
| M2 | Éditeur de base (EDT-01, EDT-08) : aperçu, timeline, lecture, sélection, annuler/rétablir, sauvegarde (SYS-01, SYS-02) | ⚠ | m2 | 2026-10-24 |
| M3 | Outils : EDT-02 rogner/scinder, EDT-03 texte, EDT-04 audio, EDT-05 ajuster/format/cadrer, EDT-07 couverture | ⚠ | m3 | 2026-10-24 |
| M4 | Export : EXP-01 à EXP-04, SYS-05, SYS-04 | ⚠ | m4 | 2026-10-24 |
| M5 | Projets : PRJ-01/02/03/06, PRJ-05, CMP-01 | ✔ | m5 | 2026-10-24 |
| M6 | Réglages et système : SET-01 à SET-03, SYS-03 | ✔ | m6 | 2026-10-24 |
| M7 | Accessibilité, performance, finitions, rapport final | ⚠ | m7 | 2026-10-24 |

Les jalons marqués ⚠ sont **écrits et contrôlés en analyse et tests** mais n'ont **pas pu être exercés sur appareil** : le rendu vidéo (aperçu, export, couverture) passe par les API natives Android, donc l'écriture est complète alors que l'exécution réelle reste à valider sur téléphone. Voir « Non vérifié ».

## Écrans (27)
| N° | ID | Écran | État | Contrôles (analyse, tests, accessibilité, clair/sombre, 200 %) | Notes |
|---|---|---|---|---|---|
| 01 | ENT-01 | Splash | ✔ | analyse ✔ · tests de l'écran ✔ (géométrie, message à 5 s, mouvement réduit, erreur, a11y, 200 %) · pixels vérifiés sur émulateur | Symbole de 120 dp (encre 96 dp) centré ; bbox mesurée 290 px contre 288 px sur la maquette (anti-aliasing du splash système). |
| 02 | ENT-02 | Bienvenue | ✔ | analyse ✔ · a11y ✔ · clair/sombre ✔ · 200 % ✔ | Trois garanties empilées ; la police à 200 % a forcé le passage en défilement. |
| 03 | HOM-01 | Accueil | ✔ | analyse ✔ · a11y ✔ · clair/sombre ✔ · 200 % ✔ | Testé vide et avec un projet. |
| 04 | IMP-02 | Nouveau projet | ✔ | analyse ✔ · a11y ✔ · clair/sombre ✔ · 200 % ✔ | |
| 05 | EDT-01 | Éditeur | ⚠ | analyse ✔ · tests du contrôleur ✔ · rendu non vérifié | Aperçu vidéo : plugin natif absent de l'environnement de test. |
| 06 | EDT-02 | Rogner et scinder | ⚠ | analyse ✔ · tests du contrôleur ✔ (scinder, rogner, bornes) | |
| 07 | EDT-03 | Texte | ✔ | analyse ✔ · tests du contrôleur ✔ (ajout, modification, suppression, duplication) | |
| 08 | EDT-04 | Audio | ✔ | analyse ✔ · tests du contrôleur ✔ | |
| 09 | EDT-05 | Ajuster, format, cadrer | ✔ | analyse ✔ · tests du contrôleur ✔ (format, ajustements) | Radio du format migré vers `RadioGroup` (API Flutter 3.32+). |
| 10 | EDT-07 | Couverture | ✔ | analyse ✔ · tests du modèle ✔ | |
| 11 | EXP-01 | Réglages d'export | ✔ | analyse ✔ · a11y ✔ · clair/sombre ✔ · 200 % ✔ · tests du service ✔ (matrice de configuration) | |
| 12 | EXP-02 | Progression | ⚠ | analyse ✔ · tests du service ✔ | Progression pollée côté natif : non exercée. |
| 13 | EXP-03 | Réussite | ⚠ | analyse ✔ | Partage et ouverture de la galerie : API natives. |
| 14 | EXP-04 | Échec / annulation | ✔ | analyse ✔ · a11y ✔ · clair/sombre ✔ · 200 % ✔ (rendu, galerie, stockage) | Un gabarit, plusieurs causes (rendu, galerie, stockage, interrompu, non pris en charge). |
| 15 | PRJ-01/02/03/06 | Projets, sélection, corbeille | ✔ | analyse ✔ · a11y ✔ · clair/sombre ✔ · 200 % ✔ (liste, grille, corbeille) · tests du store ✔ | Tri, duplication, suppression, restauration, purge à 30 jours testés. |
| 16 | PRJ-05 | Média manquant | ✔ | analyse ✔ · a11y ✔ · clair/sombre ✔ · 200 % ✔ | |
| 17 | SET-01 | Réglages | ✔ | analyse ✔ · a11y ✔ · clair/sombre ✔ · 200 % ✔ | |
| 18 | SET-02 | Stockage et cache | ✔ | analyse ✔ · a11y ✔ · clair/sombre ✔ · 200 % ✔ · tests du store ✔ (cache, stats) | |
| 19 | SET-03 | Aide, diagnostic | ✔ | analyse ✔ · a11y ✔ · clair/sombre ✔ · 200 % ✔ | Rapport généré dans `didChangeDependencies` (traductions indisponibles dans `initState`). |
| 20 | SYS-01 | Récupération | ✔ | analyse ✔ · tests du store ✔ (session, démarrage) | |
| 21 | SYS-02 | Échec de sauvegarde | ✔ | analyse ✔ · tests du contrôleur ✔ (état `failed` + relance) | |
| 22 | SYS-03 | Stockage faible/plein | ✔ | analyse ✔ · a11y ✔ · clair/sombre ✔ · 200 % ✔ | |
| 23 | SYS-04 | Non pris en charge | ✔ | analyse ✔ · tests du service ✔ (`unsupported_platform`) | |
| 24 | SYS-05 | Autorisation notification | ✔ | analyse ✔ | Feuille non bloquante, une seule fois avant la demande système. |
| 25 | IMP-03 | Autorisation médias (conditionnel) | ✔ | analyse ✔ · a11y ✔ · clair/sombre ✔ · 200 ✔ (normal et refusé) | Affiché seulement si le sélecteur système n'est pas utilisable. |
| 26 | EDT-08 | États de l'éditeur | ⚠ | analyse ✔ · tests du contrôleur ✔ | États de lecture et de sauvegarde testés ; état « vidéo manquante » sur appareil. |
| 27 | CMP-01 | Composants communs | ✔ | analyse ✔ · tous les écrans montés passent les trois lignes d'accessibilité | |

## Contrôles
| Contrôle | Commande | Résultat |
|---|---|---|
| Formatage | `dart format --set-exit-if-changed .` | ✔ aucun fichier modifié |
| Analyse statique | `flutter analyze` | ✔ 0 problème |
| Tests | `flutter test` | ✔ 158 tests, 0 échec |
| Accessibilité | inclus dans `flutter test` | ✔ 18 écrans × (clair, sombre) sur les trois lignes Android (`androidTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`) |
| Police à 200 % | inclus dans `flutter test` | ✔ aucun débordement sur les 18 écrans testés |
| Chaînes en dur | recherche automatisée des littéraux contenant des lettres et une espace dans `lib/` | ✔ seuls restent des motifs techniques (expression régulière, puce `•`, préfixe `≈`, nom de fichier `.mp4`, code d'erreur `export_not_started`) |

## Non vérifié (à lancer plus tard par un humain)
| Ce qui n'a pas pu être vérifié | Pourquoi | Commande ou procédure |
|---|---|---|
| Lecture vidéo réelle dans l'éditeur (`video_player`) | L'environnement de test n'a ni émulateur ni appareil ; le plugin Android n'est pas chargé | `flutter run` sur un appareil Android, ouvrir un projet avec une vidéo |
| Rendu d'export réel et enregistrement en galerie | Passe par `MediaCodec` / `MediaStore` via `SystemPlugin` | Ouvrir un projet → Exporter → Exporter ; vérifier que le film apparaît dans la galerie |
| Récupération après interruption (`SYS-01`) | Dépend du processus Android qui tue l'application | Forcer l'arrêt de l'application pendant un export, puis la relancer |
| Verrouillage de l'écran allumé pendant `EXP-02` | Aucune dépendance de verrouillage écran n'est installée (règle de licence) | Si nécessaire : ajouter `wakelock_plus` (licence MIT) après validation, ou appeler la vue Android native depuis `SystemPlugin` |
| Aperçu de couverture (`EDT-07`) sur fichier réel | Extraction d'image native | Choisir une couverture dans l'éditeur, vérifier le rendu |
| Comportement sur appareil modeste | Aucun appareil réel disponible | Tester au moins un appareil Android 6/7 avec 2 Go de RAM |
| Police à 200 % par l'utilisateur | Le test simule `TextScaler.linear(2)` | Réglages Android → Affichage → Taille du texte |

## Journal
| Date | Jalon | Ce qui a été fait | Contrôles |
|---|---|---|---|
| 2026-10-24 | M0–M6 | Routes et écrans de la V1 (19 routes, 15 fichiers d'écran), modèle `Project`, `AppStore` JSON, contrôleur d'éditeur (annuler/rétablir, scinder, rognage, texte), `ExportService`, formateurs et typographie | `flutter analyze` 0 · `flutter test` 92 |
| 2026-10-24 | M4 | Écrans d'export `EXP-01` à `EXP-04` : réglages, progression pollée, résultat avec vérification et galerie, échec décliné par cause | `flutter analyze` 0 · tests du service |
| 2026-10-24 | M7 | Harnais de tests d'écran (stockage temporaire, capacités fixes, thème clair/sombre, échelle de police) ; 18 écrans montés sur 360 × 800 dp | `flutter test` 146 · les trois lignes d'accessibilité et l'absence de débordement à 200 % passent |
| 2026-10-24 | M7 | Corrections révélées par les tests : hauteur fixe → hauteur minimale sur les lignes, boutons et la barre de navigation ; zones tactiles portées à 48 dp (bouton de tri, bouton de menu de grille, barre de navigation) ; libellés en texte fluide ; diagnostic déplacé dans `didChangeDependencies` | `flutter analyze` 0 · `flutter test` 146 |
| 2026-10-24 | M7 | Aucune chaîne en dur restante : textes du splash déplacés vers `app_fr.arb`/`app_en.arb`, « min »/« s »/« h » et « il y a N min » externalisés, suffixe de duplication passé depuis l'écran (libellé traduit) | recherche automatisée sur `lib/` |
| 2026-10-26 | Design | Passe de fidélité aux maquettes. Icônes : 42 SVG fournis branchés via `flutter_svg` derrière `GraceIcons`. Logo : géométrie exacte du SVG source. Splash système et Flutter alignés à 96 dp d'encre. Correction du `ProviderScope` manquant qui empêchait l'application de démarrer. | `flutter analyze` 0 · `flutter test` 158 · capture framebuffer de l'émulateur : fond, encre et accent conformes, logo centré à 0,5 px près |
| 2026-10-26 | Design | Écran 01 terminé : tests dédiés `test/core/brand_mark_test.dart` (mesure pixel du symbole) et `test/screens/splash_test.dart` (centrage, message à 5 s, glissement de 400 ms, mouvement réduit, navigation, erreur, accessibilité et 200 % dans les deux thèmes) | `flutter test` 158 · `dart format` ✔ · `flutter analyze` 0 |
