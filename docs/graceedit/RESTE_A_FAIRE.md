# Ce qui reste à faire après la conception et avant la publication

Ce document est pour **toi** (propriétaire du produit). Il liste ce que la conception ne règle pas, par ordre d'importance.

## 1. Décisions de produit à prendre
| Sujet | Valeur retenue en attendant | Pourquoi c'est important |
|---|---|---|
| **Version minimale d'Android** | Non fixée | Détermine si l'écran d'autorisation d'accès aux médias (`IMP-03`) existe, et les API utilisables. |
| **Voix off et enregistrement caméra** | Hors V1 (Phase 2) | Demandent micro/caméra, permissions et trois écrans de plus. |
| **Modèle économique** (gratuit, abonnement, publicité, filigrane) | Aucun en V1 | À décider **tôt** : il change l'architecture (comptes, paiement). La V1 n'a ni compte ni publicité. |
| Nom du fichier d'export modifiable ? | Non | Étape de plus pour un débutant. |
| Enregistrer la couverture comme image ? | Non | Utile pour publier. |
| Projet verrouillé pendant l'export, ou copie figée ? | Verrou | Le verrou est plus simple et plus léger. |
| Textes qui se chevauchent, volume > 100 % | Non prévus | À trancher après les premiers tests. |
| Tutoiement ou vouvoiement | Vouvoiement | Vaut pour toute l'application. |

## 2. Contenus et juridique (à faire par toi ou un professionnel)
- **Conditions d'utilisation** et **politique de confidentialité** : rédaction et relecture par un juriste (la V1 ne collecte rien, ce qui simplifie).
- **Droits d'auteur** sur les musiques et vidéos ajoutées par l'utilisateur : formulation du message d'information à faire valider.
- **Recherche d'antériorité** du nom « GraceEdit » et du logo avant tout dépôt ou publication.
- **Contenu de la page « Questions fréquentes »** et des textes d'aide.
- **Traduction anglaise** complète et **relecture du français** par une personne.

## 3. Ressources à produire
- **Icône d'application Android adaptative** (premier plan, arrière-plan, version monochrome thématique) : **non produite**. Le symbole du logo existe en SVG.
- **Icône de notification** monochrome.
- **Jeu d'icônes final** (les maquettes en contiennent un jeu dessiné ; choisir une bibliothèque libre de style équivalent ou les exporter).
- **Police Inter** : fichiers et vérification de la licence (SIL OFL).
- **Fiche de la boutique** (Google Play) : textes, captures d'écran, graphiques.

## 4. Vérifications techniques Android
- Services d'exécution en avant-plan pour un export long, notifications sur les versions récentes d'Android, comportement du sélecteur de médias sur les anciennes versions : **à vérifier dans la documentation officielle**.
- Choix de la bibliothèque de lecture et d'export vidéo (licence, taille, capacités). **Pas de FFmpeg** sans validation de licence.
- **Capacités réelles** des appareils d'entrée de gamme (résolutions, formats).
- Mesures de **performance** : démarrage, timeline avec de longs clips, mémoire, chauffe.

## 5. Tests
- Sur **3 à 5 appareils réels**, dont au moins un d'entrée de gamme (4 Go de mémoire ou moins) et plusieurs versions d'Android.
- **Test avec de vrais utilisateurs** (5 à 8 personnes suffisent pour les premiers constats) sur : compréhension de « Format » et « Cadrer », parcours de première création, suppression et corbeille, lisibilité des textes d'erreur.
- **Mesure des contrastes** sur les couleurs finales.
- Test avec un lecteur d'écran (TalkBack) et une police à 200 %.

## 6. Conception non faite ou à compléter
- Onglets **Style, Police, Fond** du texte (décrits dans la fiche, non dessinés) ; feuilles de choix de la **langue** et de la **suppression** dans les réglages (même gabarit que la feuille de thème) ; état « corbeille vide » ; état « vérification en cours » de la reconnexion d'un média.
- **Tablette et pliables** (décrits, non dessinés) ; panneaux latéraux de l'éditeur en paysage.
- **Phase 2 et suivantes** : mode Studio, modèles, bibliothèque d'assets, génération par IA, voix off, caméra, sous-titres, transitions, filtres, vitesse.
- **Prototype interactif** : non fourni. Les images sont des rendus statiques.

## 7. Limites de ce que j'ai produit (à savoir)
- Les images sont **dessinées par code**, pas des maquettes éditables ni des captures. Les miniatures, titres et durées sont des **exemples**.
- Je n'ai **pas mesuré** les contrastes ni testé les textes avec des utilisateurs.
- Les **routes** et le **modèle de données** sont des suggestions.
- Je n'ai **pas pu tester** ce dossier avec opencode : prévoir une relecture après les jalons M0 et M1 pour repérer les ambiguïtés des fiches.
- Les chiffres de marché cités pendant la recherche (appareils d'entrée de gamme en Afrique) sont indicatifs et ne concernent pas le Bénin en particulier.

## 8. Comment piloter opencode
- Après **chaque jalon** : ouvre `suivi/AVANCEMENT.md` (honnête ?), lis les décisions `[IMPORTANT]` de `suivi/DECISIONS.md`, réponds aux questions de `suivi/QUESTIONS.md`.
- Lance l'application sur un appareil et compare avec les images du jalon.
- Ne rouvre pas les décisions déjà prises sans raison (liste dans `LISEZ-MOI_OPENCODE.md`).

## 9. Les cinq priorités avant publication
1. Fixer la version minimale d'Android et le modèle économique.
2. Valider le choix de lecture et d'export vidéo (licence, capacités).
3. Tester sur appareils réels d'entrée de gamme.
4. Rédiger les textes juridiques et vérifier le nom et le logo.
5. Produire l'icône d'application et la fiche de la boutique.
