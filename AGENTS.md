# AGENTS.md — Règles permanentes du projet GraceEdit

> À copier à la **racine du dépôt**. Ce fichier est relu à chaque session : il prime sur toute habitude.

## 1. Contexte
GraceEdit est un éditeur vidéo mobile **Android d'abord**, **local et hors connexion**, **sans compte**. Mission : réaliser la **V1** décrite dans `docs/graceedit/` (27 écrans, un flux, des jetons de design). Le propriétaire du produit est francophone ; l'application est en **français** (source) et **anglais**.

## 2. Sources de vérité (ordre de priorité)
1. `docs/graceedit/ecrans/<écran>/SPEC_*.md` — **comportement** de chaque écran.
2. `docs/graceedit/FLUX_V1.md` — **enchaînement**, états, données, ordre de réalisation.
3. `docs/graceedit/design/tokens.json` et `DESIGN_TOKENS.md` — **valeurs** (couleurs, tailles, typographie).
4. `docs/graceedit/ecrans/<écran>/*.png` — **aspect** (si tu ne sais pas lire les images, les fiches et les jetons suffisent : ils décrivent tout).
En cas de contradiction, applique cet ordre **et note l'écart** dans `suivi/DECISIONS.md`.
`docs/graceedit/` est en **lecture seule** : ne jamais le modifier.

## 2 bis. Ce que la V1 est — et n'est pas
Dedans : entrée, accueil, import, éditeur Simple (rogner, scinder, texte, audio, ajustements, format, cadrer, couverture), export, projets (liste, grille, recherche, sélection multiple, corbeille 30 jours, média manquant), réglages, états système.
Dehors (**ne pas les faire, ne pas les afficher**) : voix off, enregistrement caméra, filtres, vitesse, sous-titres, transitions, mode Studio, modèles, bibliothèque d'assets, génération par IA, comptes, synchronisation, publicité, mesures d'usage.

## 3. Règles impératives (jamais enfreintes)
1. **Aucun accès réseau** dans l'application (ni compte, ni statistiques, ni envoi de rapport).
2. **Ne jamais modifier ni supprimer un média d'origine** de l'utilisateur. Les projets le **référencent**.
3. **Aucune fonction factice** en production : pas de bouton sans action, pas de pourcentage inventé, pas de donnée d'exemple affichée comme réelle. Les doublures (`Fake*`) n'existent que pour les tests et le mode développement.
4. **Ne rien inventer** : pas d'écran, d'option ni de réglage absent des fiches.
5. **Toute erreur dit** : ce qui est sûr, ce qui s'est passé, quoi faire (`FLUX_V1.md` §1).
6. **Accessibilité** : zones tactiles ≥ 48 dp, jamais d'information par la couleur seule, alternative sans glisser à chaque geste, police jusqu'à 200 %, noms d'éléments pour lecteur d'écran.
7. **Aucune chaîne en dur** : tout passe par les fichiers de traduction (ARB). Appliquer les **espaces insécables** (nombre + unité, avant `? ! : ; %`, dans « guillemets ») par une fonction utilitaire unique et testée.
8. **Thèmes clair et sombre** = deux jeux de valeurs (jetons), pas une inversion automatique.
9. **Appareils modestes** : pas de flou, d'ombres, de dégradés ni d'animations décoratives ; miniatures en cache à la taille d'affichage ; listes paresseuses ; aucun calcul lourd sur le fil d'interface.
10. **Licences** : n'ajouter une dépendance que si sa licence permet un usage commercial ; **ne pas intégrer FFmpeg** (ou tout composant GPL) sans validation écrite du propriétaire.

## 4. Politique de décision autonome (ne pas bloquer le projet)
Quand un cas n'est pas décrit ou qu'une fiche est ambiguë :
1. Cherche la réponse dans les « Points ouverts » de la fiche (une **valeur de départ** y est souvent proposée) et dans `FLUX_V1.md` §8.
2. Sinon, choisis l'option **la plus simple** qui respecte les règles du §3.
3. **Consigne** la décision dans `suivi/DECISIONS.md` (date, contexte, options, choix, raison).
4. **Continue.** Ne demande pas de confirmation et n'attends pas de réponse.
5. Si la décision a un fort impact (données, sécurité, licence, coût), ajoute-la aussi à `suivi/QUESTIONS.md` avec le marqueur `[IMPORTANT]` pour que le propriétaire la valide **plus tard**.
Tu ne t'arrêtes que dans les cas du §9.

## 5. Boucle de travail (par jalon, puis par écran)
Jalons : M0 → M7 (`FLUX_V1.md` §9). Pour **chaque jalon** :
1. Lis les fiches des écrans concernés **en entier** ; liste les tâches dans `suivi/AVANCEMENT.md`.
2. Écris d'abord les **interfaces** (domaine) et les **tests**, puis l'implémentation.
3. Implémente écran par écran : routes, état (Riverpod), interface, actions, **tous** les états de la fiche.
4. Lance les contrôles du §6. Corrige jusqu'à ce qu'ils passent.
5. Mets à jour `suivi/AVANCEMENT.md`, fais un **commit** (`[M2] éditeur : timeline et lecture`), étiquette le jalon (`git tag m2`).
6. Passe au jalon suivant **sans attendre**.

## 6. Contrôles de qualité (à passer avant chaque commit de jalon)
- `dart format --set-exit-if-changed .` et `flutter analyze` : **aucune alerte**.
- `flutter test` : tout passe.
- Tests d'accessibilité sur chaque écran (widgets) : `meetsGuideline(androidTapTargetGuideline)`, `meetsGuideline(labeledTapTargetGuideline)`, `meetsGuideline(textContrastGuideline)`, avec `tester.ensureSemantics()`.
- Tests de rendu des écrans en **clair et sombre**, à 360 × 800 dp, et avec une police à 200 % (aucun débordement, aucun texte coupé).
- Test unitaire du formatage typographique (espaces insécables) et des **machines d'états** (import, sauvegarde, export, corbeille).
- Aucune chaîne en dur (vérifier avec une recherche automatisée dans `lib/`).
Si un contrôle ne peut pas s'exécuter dans ton environnement (pas d'émulateur, pas d'appareil), écris-le dans `suivi/AVANCEMENT.md` sous « Non vérifié » avec la commande à lancer plus tard. **Ne l'invente pas.**

## 7. Organisation et conventions
- Dart/Flutter, **Clean Architecture** : `lib/core` (jetons, thème, i18n, utilitaires), `lib/features/<fonction>/{presentation,domain,data}`.
- État : **Riverpod 2.x** ; navigation : **GoRouter** (routes de `FLUX_V1.md` §3) ; erreurs : `fpdart` (`Either`) ; injection : `get_it`/`injectable` ; base locale : au choix, consigné dans `DECISIONS.md`.
- Chaque service externe est **derrière une interface** : lecteur vidéo, rendu/export, stockage, notifications, sélecteur de fichiers, capacités de l'appareil.
- **Lecture et export vidéo** : utiliser les API natives d'Android (lecteur et transcodeur matériels). La bibliothèque exacte (par exemple Media3) est à **choisir après lecture de la documentation officielle**, en consignant le choix, les versions et les licences dans `DECISIONS.md`.
- Identifiants de code en **anglais** ; textes affichés en **français** (source) et **anglais** ; documents, commentaires utiles et messages de commit en **français**.
- Commits **petits et fréquents**, un jalon = une branche, fusion quand les contrôles passent.

## 8. Fichiers de suivi (à tenir à jour en continu)
`suivi/AVANCEMENT.md` (tableau des 27 écrans + jalons + « Non vérifié ») · `suivi/DECISIONS.md` (journal des décisions) · `suivi/QUESTIONS.md` (à valider par le propriétaire) · `suivi/RAPPORT_FINAL.md` (écrit à la toute fin).

## 9. Seuls cas où tu t'arrêtes
- Une règle du §3 serait **violée** pour avancer.
- L'environnement empêche tout progrès (outil absent et impossible à installer) : écris `suivi/BLOQUE.md` (ce qui manque, ce que tu as essayé, la commande à lancer) et arrête-toi.
- Un jalon ne peut pas passer ses contrôles après **trois tentatives** de correction différentes : documente dans `BLOQUE.md` et passe au jalon suivant s'il est indépendant, sinon arrête-toi.

## 10. Fin de mission
Quand M7 est terminé : écris `suivi/RAPPORT_FINAL.md` (voir le modèle) : ce qui est fait, ce qui ne l'est pas, les écarts, les décisions `[IMPORTANT]`, les résultats des contrôles, le « Non vérifié », et la liste de ce qui reste à faire par un humain. Puis arrête-toi.
