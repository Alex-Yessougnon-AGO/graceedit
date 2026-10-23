# Message de démarrage pour opencode (à coller tel quel)

## Mise en place (à faire une fois, par toi)
1. Crée un dépôt vide `graceedit/` et ouvre-le avec opencode.
2. Décompresse `GraceEdit_V1_pour_opencode.zip` dans `docs/graceedit/` (le dossier `GraceEdit_V1/` devient `docs/graceedit/`).
3. Copie `docs/graceedit/AGENTS.md` à la **racine** du dépôt.
4. Copie le dossier `docs/graceedit/suivi/` à la racine du dépôt (il contient les modèles de suivi).
5. Vérifie que Flutter (SDK stable) est installé (`flutter doctor`). Idéalement, un émulateur Android ou un appareil est disponible (sinon opencode le consignera).

## Le message à coller
```text
Tu es l'agent de développement autonome du projet GraceEdit.

MISSION
Réaliser entièrement la V1 de GraceEdit (éditeur vidéo mobile Android, local, hors connexion, sans compte) en Flutter, en suivant à la lettre la documentation de docs/graceedit/. Tu travailles seul, du début à la fin, sans me demander de confirmation.

COMMENCE PAR LIRE, dans cet ordre et en entier :
1. AGENTS.md (à la racine) : tes règles permanentes. Elles priment sur tout.
2. docs/graceedit/LISEZ-MOI_OPENCODE.md
3. docs/graceedit/FLUX_V1.md : l'ordre des écrans, la navigation, le fonctionnement et les actions de chaque écran, les états, les données, et l'ordre de réalisation (jalons M0 à M7).
4. docs/graceedit/design/DESIGN_TOKENS.md et tokens.json : toutes les valeurs visuelles.
5. Pour chaque écran, avant de le coder : sa fiche docs/graceedit/ecrans/<écran>/SPEC_*.md en entier, puis ses images .png si tu sais les lire.

COMMENT TRAVAILLER
- Suis les jalons de FLUX_V1.md §9, dans l'ordre : M0 socle, M1 entrée/accueil/import, M2 éditeur de base, M3 outils, M4 export, M5 projets, M6 réglages et états système, M7 accessibilité/performance/finitions.
- Pour chaque jalon : planifie dans suivi/AVANCEMENT.md, écris les interfaces et les tests, implémente, lance les contrôles de qualité de AGENTS.md §6, corrige, commite, étiquette (git tag mN), puis passe au jalon suivant sans attendre.
- Chaque écran doit être fidèle aux images dans les deux thèmes (clair et sombre), avec TOUTES les actions et TOUS les états de sa fiche.
- N'invente rien : aucun écran, bouton, option absent des fiches. Les fonctions hors V1 (voix off, caméra, filtres, vitesse, sous-titres, transitions, comptes, IA, réseau) n'existent pas du tout dans l'application.
- Si un cas n'est pas décrit : applique la politique de décision de AGENTS.md §4 (valeur de départ de la fiche, sinon option la plus simple conforme aux règles), consigne dans suivi/DECISIONS.md, et continue. Marque [IMPORTANT] dans suivi/QUESTIONS.md ce qui a un fort impact.
- Pour la lecture et l'export vidéo, lis d'abord la documentation officielle d'Android, choisis une solution à licence compatible avec un usage commercial, et consigne le choix, les versions et les licences. N'intègre pas FFmpeg sans validation du propriétaire.
- Ne présente jamais comme réel ce qui ne l'est pas. Ce que tu ne peux pas vérifier (pas d'appareil, pas d'émulateur) va sous « Non vérifié » dans suivi/AVANCEMENT.md, avec la commande à lancer plus tard.

ARRÊT
Tu ne t'arrêtes que dans les cas de AGENTS.md §9. Sinon, tu continues jusqu'à la fin de M7, puis tu écris suivi/RAPPORT_FINAL.md (fait, pas fait, écarts, décisions importantes, résultats des contrôles, non vérifié, reste à faire par un humain) et tu t'arrêtes.

PREMIÈRE ACTION
Lis les fichiers ci-dessus, crée la structure du projet Flutter, puis réalise M0. Affiche-moi seulement un court résumé à la fin de chaque jalon.
```

## Si tu veux piloter jalon par jalon
Donne le même message en remplaçant la phrase « Tu travailles seul, du début à la fin » par « Réalise uniquement le jalon M_ puis arrête-toi et résume ». Puis relance avec le jalon suivant.

## Après chaque jalon, vérifie rapidement
- `suivi/AVANCEMENT.md` à jour et honnête (la section « Non vérifié » n'est pas vide par erreur).
- `suivi/DECISIONS.md` : lis les décisions `[IMPORTANT]`.
- L'application se lance et les écrans du jalon ressemblent aux images.
