# Rapport final — GraceEdit V1

## 1. Résumé

La V1 est écrite de bout en bout : 19 routes, 15 fichiers d'écran couvrant les 27 écrans des fiches, modèle de données, stockage local, contrôleur d'éditeur et service d'export. L'application n'a **ni compte, ni connexion, ni mesure d'usage** : les projets ne font que **référencer** les médias d'origine, qui ne sont jamais copiés ni modifiés. Les trois contrôles de qualité passent : `dart format` sans modification, `flutter analyze` à 0 alerte, `flutter test` à 146 tests verts. Les 18 écrans montés passent les trois lignes d'accessibilité Android et n'ont aucun débordement à 200 %. Ce qui **n'a pas pu être vérifié** est le rendu vidéo réel : l'environnement n'a ni émulateur ni appareil, donc la lecture, l'export et l'extraction de couverture sont écrites et testées en logique mais jamais exécutées sur Android. La V1 reste à exercer sur téléphone avant publication.

## 2. Écrans réalisés

Le tableau complet (27 écrans, état, contrôles par écran) est dans `suivi/AVANCEMENT.md`. Résumé : 24 écrans ✔, 3 écrans ⚠ (éditeur `EDT-01`, progression `EXP-02`, réussite `EXP-03`) et 2 cas d'état ⚠ (`EDT-08` état de lecture, `M2–M4` jalons) — tous écrits et contrôlés en analyse et en tests unitaires, mais non exercés sur appareil faute d'émulateur.

## 3. Écarts par rapport à la documentation

| Écran | Ce qui diffère | Pourquoi |
|---|---|---|
| `EDT-05` | Le choix du format utilise un ancêtre `RadioGroup` plutôt que `groupValue`/`onChanged` sur `RadioListTile` | Ces deux propriétés sont dépréciées depuis Flutter 3.32 ; la règle de qualité interdit de laisser une alerte d'analyse statique |
| `EXP-02` | Aucun verrouillage de l'écran pendant le rendu | Ajouter `wakelock_plus` serait une dépendance supplémentaire à valider en licence (règle §3.10). Consigné en DECISIONS, question n° 1 |
| `EXP-01` | La marge sur la taille estimée est fixée à 8 % | La fiche demande une « valeur à fixer avec l'équipe technique ». Consigné en DECISIONS, question n° 2 |
| `EXP-03` | L'écran de réussite ne s'affiche qu'après vérification du fichier **et** enregistrement en galerie | La fiche impose de n'annoncer qu'une réussite confirmée ; un export validé mais non enregistré en galerie est redirigé vers `EXP-04` (cause « galerie ») |
| Tous | Hauteurs fixes remplacées par des hauteurs minimales, libellés en texte fluide | Nécessaire pour la règle d'accessibilité « police jusqu'à 200 %, aucun texte coupé », vérifiée par les tests |

## 4. Décisions importantes à valider

Reprises de `suivi/DECISIONS.md` et `suivi/QUESTIONS.md`, marquées `[IMPORTANT]` :

1. **Verrouillage d'écran pendant l'export** — aucun pour l'instant (question n° 1).
2. **Marge de 8 %** sur la taille estimée de l'export (question n° 2).
3. **Media3 1.9.2** retenu pour le rendu, **FFmpeg écarté** (licence GPL, règle §3.10). Apache-2.0, donc compatible usage commercial.
4. **Pas de moteur de base de données** : un fichier JSON unique, écrit par fichier temporaire puis `rename` (écriture atomique).

Toutes les dépendances sont sous licence permissive (MIT, BSD-3-Clause, Apache-2.0) ; la police Inter est sous SIL OFL avec sa licence fournie dans `assets/fonts/Inter-LICENSE.txt`.

## 5. Résultats des contrôles

Chiffres réels, mesurés sur ce dépôt :

| Contrôle | Commande | Résultat |
|---|---|---|
| Formatage | `dart format --set-exit-if-changed .` | 0 fichier modifié (51 fichiers) |
| Analyse statique | `flutter analyze` | 0 problème |
| Tests | `flutter test` | 146 tests, 0 échec |
| Accessibilité | inclus dans `flutter test` | 18 écrans × (clair, sombre) passent `androidTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline` |
| Police à 200 % | inclus dans `flutter test` | 0 débordement sur 18 écrans |
| Chaînes en dur | recherche automatisée dans `lib/` | 0 chaîne affichable restante ; ne restent que des motifs techniques (expression régulière, puce `•`, préfixe `≈`, extension `.mp4`, code d'erreur) |

Taille du code hors traductions générées : ≈ 14 300 lignes Dart dans `lib/`. Traductions : 706 clés, en français et en anglais à égalité.

Tests répartis en 7 fichiers : `project_model_test` (19), `formatters_test` (20), `editor_controller_test` (18), `app_store_test` (15), `typography_test` (10), `export_service_test` (10), `screens_a11y_test` (harnais montant 18 écrans).

## 6. Non vérifié

Aucun émulateur ni appareil n'est disponible dans l'environnement de test. Ce qui n'a donc **pas** été exécuté, avec la procédure :

| Ce qui n'a pas pu être vérifié | Procédure |
|---|---|
| Lecture vidéo réelle dans l'éditeur | `flutter run` sur appareil Android, ouvrir un projet avec une vidéo |
| Rendu d'export et enregistrement en galerie | Ouvrir un projet → Exporter → Exporter ; vérifier le film dans la galerie |
| Récupération après interruption (`SYS-01`) | Forcer l'arrêt de l'application pendant un export, puis la relancer |
| Verrouillage de l'écran (`EXP-02`) | Voir la question n° 1 : à implémenter d'abord si jugé nécessaire |
| Extraction de couverture (`EDT-07`) | Choisir une couverture dans l'éditeur, vérifier le rendu |
| Comportement sur appareil d'entrée de gamme | Tester au moins un appareil Android 6/7 avec 2 Go de RAM |
| Police à 200 % réglée par l'utilisateur | Réglages Android → Affichage → Taille du texte (le test simule `TextScaler.linear(2)`) |

## 7. Problèmes connus

- L'écran `IMP-03` (autorisation des médias) n'apparaît que si le sélecteur du système échoue. Comme `minSdk` suit `flutter.minSdkVersion` (API 21), ce cas est **rare** et n'a pas pu être déclenché en test : le parcours normal utilise l'intent du système, qui n'exige pas de permission.
- La progression d'export (`EXP-02`) est obtenue par sondage (`poll`) toutes les secondes côté Dart. Le pourcentage est monotone (il ne recule jamais) et n'affiche jamais 100 % avant la fin de la vérification, mais la fluidité dépend de la fréquence du sondage sur appareil réel.
- Le titre de duplication d'un projet est calculé côté écran (pour être traduit) et transmis au magasin. Tout nouvel appel à `AppStore.duplicate` doit fournir le `titleOf` sinon il lèvera une erreur de compilation.

## 8. Reste à faire par un humain

Voir `docs/graceedit/RESTE_A_FAIRE.md`, qui reste entièrement d'actualité pour ce qui n'est pas du code :

- **Décisions de produit** : version minimale d'Android à fixer, modèle économique, nom du fichier d'export, enregistrement de la couverture, verrou ou copie figée pendant l'export, vouvoiement (déjà appliqué).
- **Juridique** : conditions d'utilisation, politique de confidentialité, formulation sur les droits d'auteur des médias, recherche d'antériorité du nom et du logo.
- **Ressources** : icône d'application Android adaptative, icône de notification, jeu d'icônes final, fiche de la boutique Google Play.
- **Traduction** : les 706 clés sont traduites en anglais, mais une relecture par une personne reste à faire.
- **Tests** : 3 à 5 appareils réels (dont un d'entrée de gamme), test utilisateur sur 5 à 8 personnes, mesures de performance (démarrage, timeline longue, mémoire, chauffe).
