# GraceEdit — Master Autonomous Implementation Task

> **Document destiné à OpenCode.**
> Ce fichier est le prompt maître d'exécution du projet GraceEdit. Il est conçu pour permettre à l'agent de travailler sur une longue durée, de façon autonome, sans demander une validation humaine à chaque étape.

---

## 0. MISSION PRINCIPALE

Tu es l'agent principal chargé de transformer le projet GraceEdit en un produit réellement fonctionnel, cohérent, robuste, testable et commercialisable.

GraceEdit n'est PAS simplement un clone de CapCut.

GraceEdit doit devenir progressivement une **plateforme de création assistée par IA**, centrée sur la simplicité d'utilisation mais capable d'évoluer vers un niveau professionnel :

- montage vidéo ;
- capture vidéo ;
- audio ;
- sous-titres ;
- thumbnails ;
- templates ;
- affiches/flyers/social posts ;
- génération d'images ;
- génération de vidéos ;
- génération d'audios ;
- scénarios ;
- storyboards ;
- direction artistique ;
- UX/UI design ;
- identité visuelle et Brand Kit ;
- campagnes de contenu ;
- rôles IA spécialisés ;
- automatisation créative ;
- export professionnel ;
- fonctionnement offline lorsque possible ;
- orchestration intelligente avec Jev ;
- architecture extensible vers Android, iOS, Desktop et Web.

L'objectif final est que GraceEdit puisse prendre une intention simple comme :

> « Je veux une affiche professionnelle pour annoncer la conférence des jeunes de mon église samedi. »

et permettre progressivement de passer de l'idée au résultat final :

**brief → direction créative → template ou génération → texte → assets → composition → vérification → variantes → export**.

Même logique pour la vidéo :

**idée → scénario → storyboard → assets → voix/audio → montage → sous-titres → corrections → thumbnail → export**.

Même logique pour le design produit :

**idée → UX → architecture → wireframe → UI → design system → prototype → export/implémentation**.

---

# 1. RÈGLES ABSOLUES D'AUTONOMIE

Tu dois travailler comme un agent logiciel autonome capable de poursuivre le projet pendant une longue durée.

### 1.1 Ne demande pas de validation pour les décisions normales

Ne t'arrête pas pour demander :

- « Est-ce que je peux faire ceci ? »
- « Quelle couleur veux-tu ? »
- « Quelle architecture préfères-tu ? »
- « Dois-je ajouter cette page ? »
- « Dois-je corriger ce bug ? »
- « Quelle bibliothèque choisir ? »

Utilise la documentation existante, les conventions du projet, les bonnes pratiques et ton jugement technique.

### 1.2 Si une information manque

Choisis l'option la plus cohérente avec :

1. les documents du projet ;
2. la simplicité utilisateur ;
3. la robustesse ;
4. la maintenabilité ;
5. les performances ;
6. la possibilité de commercialiser le produit ;
7. l'architecture cross-platform ;
8. la compatibilité avec les futures fonctionnalités IA.

Documente brièvement la décision dans `docs/decisions/` et continue.

### 1.3 Ne bloque jamais le projet à cause d'un service externe

Si une API, une clé, un compte, un fournisseur IA ou un service cloud n'est pas disponible :

- crée l'abstraction/provider interface ;
- implémente le comportement local lorsqu'il est possible ;
- implémente un mock/dev provider réaliste ;
- ajoute une feature flag/capability ;
- garde l'architecture prête pour le provider réel ;
- teste l'intégration avec des données déterministes ;
- continue le reste du projet.

Ne prétends jamais qu'une fonctionnalité IA externe est réellement opérationnelle si elle ne l'est pas.

### 1.4 Ne crée pas de fausses fonctionnalités

Interdit :

- boutons qui ne font rien ;
- écrans décoratifs sans logique ;
- faux exports ;
- faux projets enregistrés ;
- faux résultats IA présentés comme réels ;
- données hardcodées utilisées comme produit final ;
- TODO laissés dans les parcours critiques ;
- navigation cassée ;
- fonctionnalités annoncées mais non implémentées.

Un prototype peut utiliser un provider mock uniquement lorsqu'il est explicitement identifié comme tel et que l'architecture réelle existe derrière.

### 1.6 Utilise les sous-agents lorsque cela améliore réellement l'exécution

Le projet utilise **ECC (Everything Claude Code / équivalent installé dans OpenCode), ainsi que les skills/specs déjà disponibles dans l'environnement**. Tu es autorisé et encouragé à utiliser des sous-agents lorsque cela permet de paralléliser ou fiabiliser le travail.

Utilise notamment des sous-agents spécialisés pour :

- architecture et revue technique ;
- Flutter/Dart et state management ;
- Android/Kotlin/Media3/CameraX/media pipeline ;
- UI/UX et design system ;
- tests unitaires/widget/integration/E2E ;
- QA visuelle et responsive ;
- performance et profiling ;
- sécurité et privacy ;
- licences/open source ;
- IA/Jev/providers ;
- documentation ;
- recherche technique lorsqu'une documentation officielle est nécessaire.

Règles :

1. L'agent principal reste responsable de l'intégration finale.
2. Ne délègue pas une tâche critique sans vérifier le résultat.
3. Les sous-agents doivent recevoir un contexte ciblé et retourner des résultats exploitables.
4. Évite les sous-agents redondants qui modifient simultanément les mêmes fichiers sans coordination.
5. Après chaque travail de sous-agent, inspecte les changements, lance les tests pertinents et corrige les régressions.
6. Utilise les mécanismes ECC/specs/skills réellement installés dans l'environnement au lieu d'inventer des commandes ou des capacités inexistantes.
7. Pour les gros travaux, décompose en sous-tâches indépendantes puis intègre-les dans l'ordre des dépendances.

### 1.7 Le projet doit être livré par paliers utilisables

Ne traite pas « terminer tout GraceEdit » comme une seule livraison. Le projet doit avancer par **versions réellement utilisables**.

La première mission prioritaire est de produire une **V1 mondiale, présentable au client et utilisable par de vrais utilisateurs**, et non un prototype de démonstration rempli d'écrans statiques.

Une fois cette V1 terminée, validée et documentée :

- arrête-toi à ce checkpoint ;
- ne commence pas automatiquement les grosses fonctionnalités futures ;
- laisse un état d'exécution propre permettant de reprendre immédiatement ;
- si l'utilisateur dit « suivant », « continue », « poursuis », « finis le projet » ou équivalent, reprends à la prochaine phase non terminée ;
- si l'utilisateur demande une phase précise, exécute cette phase puis poursuis selon son instruction ;
- ne recommence jamais une phase déjà validée sauf si un audit montre une régression ou un problème bloquant.

Le mot **V1** signifie ici une vraie première version produit : stable, cohérente, accessible, responsive lorsque pertinent, avec persistance, gestion des erreurs, tests, export réel et UX complète sur son périmètre. Ce n'est pas un simple mockup.

### 1.8 État de reprise obligatoire

Maintiens un fichier de suivi, par exemple `.opencode/graceedit-execution-state.md`, contenant :

- phase actuelle ;
- tâches terminées ;
- tâches en cours ;
- tâches bloquées et raison ;
- décisions prises ;
- tests exécutés ;
- bugs connus ;
- prochaines tâches ;
- version/checkpoint atteint ;
- migrations ou actions manuelles réellement nécessaires.

Ce fichier doit permettre à un nouvel appel OpenCode de reprendre le travail sans demander à l'utilisateur de réexpliquer le projet.

### 1.5 Travaille en boucle autonome

Après chaque fonctionnalité importante :

1. implémenter ;
2. compiler ;
3. lancer les tests ;
4. analyser les erreurs ;
5. corriger ;
6. lancer l'analyse statique ;
7. vérifier l'UX ;
8. vérifier les performances ;
9. vérifier les états d'erreur ;
10. vérifier l'accessibilité ;
11. continuer.

Ne considère jamais une tâche terminée simplement parce que le code compile.

---

# 2. DOCUMENTATION À LIRE AVANT TOUTE MODIFICATION

Avant d'écrire du code, lis intégralement les documents GraceEdit disponibles dans le projet.

Ordre recommandé :

```text
00_README.md
01_PRODUCT_BRIEF.md
02_PRD.md
03_UX_SPEC.md
04_INFORMATION_ARCHITECTURE.md
05_USER_FLOWS.md
06_SCREEN_INVENTORY.md
07_UI_DESIGN_SYSTEM.md
08_TECHNICAL_ARCHITECTURE.md
09_MEDIA_THUMBNAILS_EXPORT.md
10_JEV_AI_SPEC.md
11_ROADMAP.md
12_OPEN_SOURCE_LEGAL.md
13_TEST_SPEC.md
14_IMPLEMENTATION_PLAN.md
15_PRODUCT_DECISIONS.md
16_RESEARCH_SOURCES.md
17_CREATIVE_STUDIO.md
18_AI_CREATIVE_ROLES.md
19_GENERATIVE_MEDIA_PIPELINE.md
20_GRAPHIC_DESIGN_SYSTEM.md
21_BRAND_KIT_AND_ASSET_LIBRARY.md
22_CREATIVE_PROJECT_MODEL.md
```

Le présent fichier est le **master execution plan**.

En cas de conflit :

1. contraintes de sécurité et de plateforme ;
2. architecture technique ;
3. PRD ;
4. UX/UI ;
5. documents Creative Studio / AI / Graphic Design ;
6. ce plan d'exécution.

Si un document semble incomplet, améliore-le au lieu de supprimer son intention.

---

# 3. AUDIT INITIAL DU REPOSITORY

Commence par inspecter entièrement le repository.

Tu dois identifier :

- stack actuelle ;
- architecture ;
- packages ;
- dépendances ;
- plateformes ;
- fichiers de configuration ;
- assets ;
- tests ;
- routes ;
- écrans existants ;
- services ;
- modèles ;
- état global ;
- code mort ;
- TODO ;
- FIXME ;
- bugs évidents ;
- dette technique ;
- fonctionnalités déjà présentes ;
- fonctionnalités manquantes ;
- conflits avec la documentation.

Crée :

```text
docs/IMPLEMENTATION_AUDIT.md
```

avec :

- état actuel ;
- architecture réelle ;
- risques ;
- fonctionnalités déjà terminées ;
- fonctionnalités partielles ;
- fonctionnalités absentes ;
- ordre de correction recommandé.

Ne réécris pas inutilement ce qui fonctionne correctement.

---

# 4. STACK ET ARCHITECTURE CIBLE

## 4.1 Frontend

Utiliser prioritairement :

- Flutter ;
- Dart ;
- Material 3 ;
- Riverpod ;
- code generation lorsque pertinent ;
- GoRouter ;
- architecture modulaire/feature-first ;
- séparation présentation/domain/data/infrastructure ;
- interfaces pour les capacités natives ;
- modèles immuables ;
- gestion d'état explicite ;
- observabilité ;
- tests.

Ne mélange pas logique métier et widgets.

## 4.2 Android

Android est la première plateforme cible.

Utiliser les technologies natives appropriées pour les tâches média :

- Kotlin ;
- AndroidX ;
- Media3 ;
- Transformer ;
- CameraX ;
- MediaCodec ;
- APIs système adaptées ;
- traitement GPU lorsqu'il apporte un vrai bénéfice.

Le code natif doit être exposé au Flutter par une couche clairement définie.

## 4.3 Futures plateformes

Préparer les interfaces pour :

- Android ;
- iOS ;
- Desktop ;
- Web.

Ne suppose jamais que les capacités Android existent sur les autres plateformes.

Créer un système de **capability detection**.

Exemple :

```text
supports4K
supportsHDR
supportsHEVC
supportsHardwareEncoding
supportsBackgroundExport
supportsCamera
supportsLocalAI
supportsOfflineGeneration
```

---

# 5. ARCHITECTURE PRODUIT

GraceEdit doit être construit autour d'un modèle de projet commun.

Conceptuellement :

```text
GraceEditProject
 ├── metadata
 ├── canvas/settings
 ├── mediaAssets
 ├── videoSequences
 ├── audioTracks
 ├── textLayers
 ├── subtitleTracks
 ├── graphicElements
 ├── generatedAssets
 ├── templates
 ├── brandKit
 ├── storyboard
 ├── scenes
 ├── designFrames
 ├── AI decisions
 ├── history
 ├── versions
 └── exportProfiles
```

L'utilisateur débutant et l'utilisateur expert doivent manipuler **le même projet**, avec deux niveaux d'interface :

- mode simple ;
- mode Studio/Pro.

Le mode simple masque la complexité.
Le mode Studio l'expose progressivement.

---

# 6. DIRECTION UX/UI À APPLIQUER À TOUT LE PROJET

Le design doit être :

- premium ;
- épuré ;
- calme ;
- ergonomique ;
- cohérent ;
- accessible ;
- moderne ;
- professionnel ;
- humain ;
- proche des standards d'applications haut de gamme ;
- jamais surchargé ;
- jamais générique ;
- jamais « AI dashboard » ;
- jamais rempli de gradients, glow, cartes et badges inutiles.

### 6.1 Principe fondamental

**L'utilisateur doit voir le résultat avant de voir la complexité.**

### 6.2 L'IA ne doit pas visuellement dominer l'application

GraceEdit doit ressembler à un véritable produit créatif professionnel qui utilise l'IA intelligemment, et non à une application générée autour de boutons « AI ».

Éviter :

- accumulation de boutons IA ;
- étoiles partout ;
- gradients violets systématiques ;
- cartes flottantes inutiles ;
- textes marketing artificiels ;
- interfaces futuristes sans raison ;
- effets lumineux excessifs ;
- icônes incohérentes ;
- animations décoratives.

### 6.3 Dark et Light mode

Le produit doit avoir dès l'architecture :

- Dark Mode ;
- Light Mode ;
- système automatique ;
- tokens partagés ;
- contraste accessible.

Les deux thèmes doivent être réellement conçus, pas simplement inversés.

### 6.4 Design system

Créer :

- tokens de couleur ;
- typographie ;
- espacements ;
- rayons ;
- élévations ;
- icônes ;
- boutons ;
- champs ;
- chips ;
- tabs ;
- cards ;
- sheets ;
- dialogs ;
- bottom navigation ;
- toolbars ;
- timeline components ;
- media cards ;
- thumbnails ;
- progress indicators ;
- empty states ;
- error states ;
- loading states.

Tous les écrans doivent utiliser ce système.

---

# 7. ÉCRANS À IMPLÉMENTER

L'inventaire doit être exhaustif et aucune page essentielle ne doit être oubliée.

## 7.1 Onboarding

Implémenter :

- Splash ;
- onboarding 1 ;
- onboarding 2 ;
- onboarding 3 ;
- choix des préférences ;
- connexion ;
- inscription ;
- mode invité lorsque pertinent ;
- permissions ;
- récupération d'une session ;
- états de chargement/erreur.

## 7.2 Accueil

- Home ;
- projets récents ;
- continuer un projet ;
- créer ;
- templates ;
- bibliothèque ;
- favoris ;
- recherche ;
- notifications ;
- profil ;
- paramètres.

## 7.3 Création

Permettre de choisir :

- vidéo ;
- affiche/flyer ;
- image ;
- audio ;
- scénario ;
- clip court ;
- thumbnail ;
- template ;
- campagne ;
- projet UX/UI ;
- autres formats supportés.

## 7.4 Import

- galerie ;
- vidéos ;
- photos ;
- favoris ;
- fichiers ;
- caméra ;
- audio ;
- assets du projet ;
- assets générés ;
- recherche ;
- filtres ;
- sélection multiple ;
- aperçu ;
- import progress ;
- erreur d'import ;
- format non supporté.

## 7.5 Caméra

- capture photo ;
- capture vidéo ;
- front/back ;
- flash ;
- résolution ;
- fps ;
- durée ;
- stabilisation selon capacité ;
- grille ;
- verrouillage exposition/focus lorsque supporté ;
- preview ;
- reprise après interruption.

## 7.6 Éditeur vidéo simple

L'expérience doit être utilisable par quelqu'un qui n'a jamais monté une vidéo.

Actions principales :

- couper ;
- diviser ;
- supprimer ;
- recadrer ;
- rotation ;
- vitesse ;
- volume ;
- texte ;
- musique ;
- sous-titres ;
- filtres ;
- luminosité ;
- contraste ;
- saturation ;
- effets ;
- annuler/refaire ;
- aperçu ;
- enregistrer ;
- exporter.

## 7.7 Studio vidéo

Fonctionnalités avancées :

- timeline multi-pistes ;
- snapping ;
- zoom ;
- découpe précise ;
- keyframes si supportés ;
- transformations ;
- blend/compositing ;
- audio multipiste ;
- sous-titres avancés ;
- overlays ;
- transitions ;
- effets ;
- réglages colorimétriques ;
- speed ramp ;
- historique ;
- versions ;
- proxy media si nécessaire.

## 7.8 Thumbnails

Les thumbnails sont une fonctionnalité centrale.

Implémenter :

- thumbnail média ;
- cover de projet ;
- frame de preview ;
- timeline thumbnail strip ;
- thumbnail de template ;
- thumbnail de résultat exporté ;
- thumbnail d'image générée ;
- thumbnail vidéo générée ;
- thumbnail de scène/storyboard.

Ne pas utiliser systématiquement la première frame.

Prévoir :

```text
assetId
sourceVersion
size
cropMode
frameTimestamp
```

comme éléments du cache lorsque nécessaire.

La timeline doit adapter le nombre de thumbnails au niveau de zoom.

---

# 8. AUDIO

Implémenter :

- import audio ;
- enregistrement voix ;
- découpage ;
- volume ;
- fade in/out ;
- réduction bruit ;
- égalisation lorsque possible ;
- synchronisation ;
- voice-over ;
- waveform ;
- audio tracks ;
- musique ;
- sound effects ;
- pré-écoute ;
- génération audio via provider abstrait ;
- TTS via provider abstrait ;
- transcription locale lorsque possible.

Prévoir whisper.cpp ou équivalent lorsque pertinent et légalement compatible.

---

# 9. SOUS-TITRES

Implémenter :

- génération depuis audio ;
- import ;
- édition ;
- synchronisation ;
- styles ;
- position ;
- taille ;
- couleur ;
- animation lorsque supportée ;
- export incrusté ;
- export séparé si pertinent.

Le système doit fonctionner avec une piste de sous-titres structurée, pas seulement du texte visuel.

---

# 10. IMAGE / COLOR / LIGHTING

Implémenter :

- exposition ;
- luminosité ;
- contraste ;
- saturation ;
- température ;
- teinte ;
- netteté ;
- vignette ;
- filtres ;
- crop ;
- rotation ;
- perspective si pertinent ;
- presets ;
- comparaison avant/après ;
- reset ;
- historique.

Toujours privilégier des modifications réversibles.

---

# 11. TEMPLATES

Créer une architecture de templates structurés.

Un template doit contenir :

- format ;
- dimensions ;
- composition ;
- zones de texte ;
- zones média ;
- couleurs ;
- typographies ;
- animations éventuelles ;
- contraintes ;
- catégorie ;
- audience ;
- domaine ;
- tags ;
- version ;
- licence/source ;
- preview ;
- compatibilité.

Catégories initiales :

- église ;
- événement ;
- business ;
- restaurant ;
- immobilier ;
- formation ;
- association ;
- étudiant ;
- musique ;
- créateur ;
- réseaux sociaux ;
- annonce ;
- promotion ;
- anniversaire ;
- mariage ;
- conférence ;
- podcast ;
- YouTube ;
- Shorts/Reels/TikTok.

L'utilisateur doit pouvoir choisir un template ou demander à GraceEdit de proposer des templates selon son objectif.

---

# 12. CREATIVE STUDIO

Construire un espace distinct :

```text
Creative Studio
```

Il doit permettre de créer :

- affiches ;
- flyers ;
- posts ;
- stories ;
- thumbnails ;
- bannières ;
- couvertures ;
- présentations visuelles simples ;
- visuels d'événements ;
- visuels publicitaires ;
- kits de campagne ;
- miniatures vidéo ;
- visuels pour WhatsApp ;
- visuels pour Instagram ;
- visuels pour YouTube ;
- formats personnalisés.

Le système doit fournir :

1. création libre ;
2. template ;
3. création guidée ;
4. génération assistée par IA ;
5. import d'un design existant ;
6. duplication/variation.

---

# 13. GRAPHIC DESIGN ENGINE

Le moteur de design doit raisonner en termes de :

- hiérarchie ;
- grille ;
- alignement ;
- rythme ;
- contraste ;
- typographie ;
- espace négatif ;
- proportions ;
- densité ;
- focal point ;
- équilibre ;
- cohérence de marque.

L'IA ne doit pas seulement générer des pixels.

Elle doit pouvoir produire une **composition éditable** :

```text
Canvas
 ├── background
 ├── image layers
 ├── shapes
 ├── typography
 ├── logos
 ├── decorative elements
 └── effects
```

Chaque élément doit rester éditable lorsque la technologie le permet.

---

# 14. AI CREATIVE ROLES

Créer un système de rôles IA spécialisés.

Rôles minimum :

- Creative Director ;
- Art Director ;
- Graphic Designer ;
- UX Designer ;
- UI Designer ;
- Product Designer ;
- Video Editor ;
- Motion Designer ;
- Copywriter ;
- Script Writer ;
- Storyboard Artist ;
- Audio Designer ;
- Thumbnail Designer ;
- Brand Designer ;
- Content Strategist ;
- Creative Reviewer.

Chaque rôle doit avoir :

- description ;
- compétences ;
- objectifs ;
- règles ;
- contraintes ;
- critères de qualité ;
- outils autorisés ;
- formats de sortie ;
- system prompt ;
- instructions spécialisées ;
- exemples ;
- anti-patterns ;
- tests.

Ne mets pas toutes les compétences dans un énorme prompt unique.

Créer des compétences modulaires.

---

# 15. AI CREATIVE ORCHESTRATOR

Créer un orchestrateur capable de transformer un brief utilisateur en workflow.

Exemple :

```text
Brief
 ↓
Intent detection
 ↓
Creative Director
 ↓
Domain specialist
 ↓
Template/Generation decision
 ↓
Asset generation
 ↓
Composition
 ↓
Creative Reviewer
 ↓
User revision
 ↓
Variants
 ↓
Export
```

L'orchestrateur doit choisir uniquement les agents nécessaires.

Ne lance pas dix agents pour une tâche simple.

---

# 16. JEV

Jev est un **moteur de décision/orchestration**, pas le moteur de rendu vidéo ou graphique.

Architecture :

```text
GraceEdit
 ↓
Local analysis / structured state
 ↓
Jev
 ↓
Typed decision
 ↓
GraceEdit deterministic action
```

Utilisations :

- choix de format ;
- choix de template ;
- niveau d'amélioration ;
- suppression de silences ;
- style de sous-titres ;
- recommandation d'export ;
- classification de contenu ;
- sélection de workflow ;
- choix d'un rôle IA ;
- sélection d'une variante créative.

Règles :

- jamais d'action irréversible sans confirmation lorsque le risque est significatif ;
- utiliser des fallbacks déterministes ;
- clé API uniquement côté serveur ;
- gérer les erreurs réseau ;
- gérer l'absence de Jev ;
- journaliser les décisions ;
- rendre les décisions explicables à l'utilisateur lorsque nécessaire.

Créer une interface `DecisionProvider` afin de ne pas coupler toute l'application à Jev.

---

# 17. GENERATIVE MEDIA PIPELINE

Créer des interfaces abstraites :

```text
ImageGenerationProvider
VideoGenerationProvider
AudioGenerationProvider
SpeechToTextProvider
TextToSpeechProvider
MusicGenerationProvider
```

Chaque provider doit exposer :

- capabilities ;
- request ;
- progress ;
- cancellation ;
- result ;
- errors ;
- metadata ;
- licensing metadata lorsque disponible.

Prévoir plusieurs providers futurs.

Ne jamais enfermer GraceEdit dans un seul fournisseur IA.

## Génération image

Supporter conceptuellement :

- prompt ;
- style ;
- format ;
- résolution ;
- références ;
- variantes ;
- seed lorsque le provider le permet ;
- negative constraints lorsque disponible.

## Génération vidéo

Supporter conceptuellement :

- prompt-to-video ;
- image-to-video ;
- variations ;
- duration ;
- aspect ratio ;
- resolution ;
- motion/style constraints.

## Génération audio

Supporter :

- voice ;
- narration ;
- music ;
- sound effects ;
- duration ;
- mood ;
- language ;
- intensity.

---

# 18. SCENARIO → STORYBOARD → MEDIA → VIDEO

Construire un workflow complet.

L'utilisateur peut écrire :

> « Je veux faire une vidéo de 45 secondes pour promouvoir mon événement. »

GraceEdit peut produire :

1. objectif ;
2. audience ;
3. angle ;
4. script ;
5. scènes ;
6. storyboard ;
7. plans nécessaires ;
8. images nécessaires ;
9. vidéos nécessaires ;
10. narration ;
11. musique ;
12. textes à l'écran ;
13. sous-titres ;
14. montage ;
15. thumbnail ;
16. variantes ;
17. export.

Chaque étape doit rester éditable.

---

# 19. CAMPAIGN STUDIO

Permettre de transformer un seul brief en plusieurs formats.

Exemple :

```text
Campagne événement
 ├── affiche A4
 ├── affiche Instagram
 ├── Story
 ├── WhatsApp Status
 ├── thumbnail vidéo
 ├── vidéo courte
 ├── teaser
 ├── caption
 └── variantes
```

Les éléments communs doivent partager le Brand Kit et les assets.

Modifier un élément global doit permettre de synchroniser les variantes lorsque l'utilisateur le souhaite.

---

# 20. BRAND KIT

Créer un Brand Kit complet :

- logo ;
- variantes logo ;
- couleurs ;
- typographies ;
- styles ;
- icônes ;
- images ;
- ton éditorial ;
- règles de composition ;
- éléments interdits ;
- préférences visuelles ;
- exemples ;
- templates de marque.

Le moteur IA doit pouvoir utiliser automatiquement le Brand Kit.

Prévoir plusieurs Brand Kits par utilisateur/projet.

---

# 21. ASSET LIBRARY

Créer une bibliothèque unifiée :

- images ;
- vidéos ;
- audio ;
- musique ;
- logos ;
- fonts ;
- templates ;
- générations IA ;
- exports ;
- thumbnails ;
- éléments graphiques ;
- storyboard frames.

Fonctions :

- recherche ;
- tags ;
- favoris ;
- collections ;
- filtres ;
- tri ;
- preview ;
- suppression ;
- duplication ;
- version ;
- métadonnées ;
- source/licence.

---

# 22. UX/UI DESIGN STUDIO

Créer un futur espace permettant de concevoir des interfaces.

Fonctions :

- brief produit ;
- personas ;
- user flows ;
- sitemap ;
- wireframes ;
- UI screens ;
- design system ;
- composants ;
- prototype ;
- variantes ;
- export ;
- documentation.

L'IA doit jouer plusieurs rôles :

```text
Product Strategist
UX Designer
Information Architect
UI Designer
Design System Designer
UX Writer
Accessibility Reviewer
Design Critic
```

Le système doit privilégier des designs cohérents et réellement utilisables plutôt que des concepts visuels spectaculaires mais irréalistes.

---

# 23. EXPORT

L'architecture d'export doit être conçue dès maintenant pour évoluer.

Pipeline :

```text
Project
 ↓
Validate
 ↓
Resolve assets
 ↓
Build render plan
 ↓
Select profile
 ↓
Capability check
 ↓
Render
 ↓
Verify
 ↓
Register output
 ↓
Generate thumbnail
```

Profils initiaux :

- 720p ;
- 1080p ;
- 1080x1920 ;
- 1080x1080 ;
- paysage 1080p.

Préparer :

- 1080p60 ;
- 1440p ;
- 4K30 ;
- 4K60 ;
- HEVC/H.265 ;
- HDR lorsque la plateforme le permet.

Ne pas afficher une option que le device ne peut pas réellement produire.

Créer une stratégie de fallback claire.

---

# 24. PERFORMANCE MEDIA

Le montage vidéo doit rester utilisable sur des appareils modestes.

Prévoir :

- thumbnails en cache ;
- previews adaptées ;
- proxy media ;
- rendu différé ;
- traitement en arrière-plan lorsque supporté ;
- limitation mémoire ;
- libération des ressources ;
- résolution adaptative ;
- chargement progressif ;
- cancellation ;
- reprise après interruption.

Éviter de charger des vidéos complètes en mémoire.

---

# 25. OFFLINE-FIRST

GraceEdit doit fonctionner autant que possible sans connexion.

Offline :

- projets locaux ;
- édition ;
- import ;
- thumbnails ;
- montage ;
- export supporté localement ;
- paramètres ;
- historique ;
- certaines analyses locales ;
- certaines transcriptions locales.

Online :

- génération IA distante ;
- synchronisation ;
- providers externes ;
- services cloud ;
- modèles distants.

Toujours informer clairement l'utilisateur lorsqu'une connexion est requise.

---

# 26. PERSISTENCE ET RECOVERY

Implémenter :

- autosave ;
- versioning ;
- crash recovery ;
- récupération de projet ;
- corruption detection lorsque possible ;
- migration de données ;
- sauvegarde des métadonnées ;
- nettoyage sécurisé des fichiers temporaires.

Un crash pendant un export ou un montage ne doit pas détruire le projet.

---

# 27. ACCESSIBILITÉ

Tous les écrans doivent prendre en compte :

- taille du texte ;
- contraste ;
- lecteurs d'écran ;
- labels sémantiques ;
- zones tactiles suffisamment grandes ;
- navigation logique ;
- alternatives aux couleurs seules ;
- animations réduites ;
- feedbacks accessibles.

---

# 28. INTERNATIONALISATION

Préparer l'architecture pour :

- français ;
- anglais ;
- autres langues futures.

Ne hardcode pas les textes utilisateur dans les widgets.

---

# 29. SÉCURITÉ

Vérifier :

- secrets ;
- clés API ;
- stockage local ;
- fichiers importés ;
- permissions ;
- providers distants ;
- endpoints ;
- authentification ;
- autorisations ;
- validation des entrées ;
- uploads ;
- données utilisateur.

Aucune clé secrète ne doit être intégrée au client mobile.

---

# 30. LICENCES ET COMMERCIALISATION

Pour chaque dépendance importante, vérifier :

- licence ;
- version ;
- dépendances transitives pertinentes ;
- compatibilité commerciale ;
- restrictions particulières ;
- modèles IA ;
- fonts ;
- musiques ;
- templates ;
- images ;
- codecs ;
- assets.

Créer/maintenir :

```text
legal/DEPENDENCIES.md
legal/ASSET_LICENSES.md
legal/MODEL_LICENSES.md
```

Ne jamais supposer qu'une ressource trouvée sur Internet est libre d'utilisation commerciale.

---

# 31. TESTS

Créer une vraie stratégie de test.

## Unit tests

Tester :

- project model ;
- timeline ;
- duration ;
- timecodes ;
- crop ;
- transforms ;
- audio ;
- subtitles ;
- templates ;
- brand kit ;
- asset library ;
- AI decisions ;
- export profiles ;
- capability detection.

## Widget tests

Tester tous les composants critiques.

## Integration tests

Tester :

- création projet ;
- import ;
- édition ;
- sauvegarde ;
- récupération ;
- export ;
- génération mock ;
- template ;
- campaign workflow.

## E2E

Utiliser Playwright lorsque pertinent pour les interfaces supportées.

Sur mobile, utiliser les outils adaptés de la stack.

## Tests média

Tester plusieurs :

- résolutions ;
- codecs ;
- orientations ;
- fps ;
- durées ;
- tailles de fichiers ;
- audio ;
- HDR lorsque disponible.

---

# 32. TESTS UTILISATEUR DÉBUTANT

Les parcours suivants doivent être réalisables sans connaissance préalable du montage :

### Test A

Importer une vidéo → couper une partie → ajouter texte → exporter.

### Test B

Créer une affiche → choisir un template → modifier texte/photo → exporter.

### Test C

Donner une idée → obtenir un scénario → générer/assembler les assets → créer une vidéo.

### Test D

Importer une vidéo → générer sous-titres → corriger → exporter.

### Test E

Créer une campagne → générer plusieurs formats → modifier la marque → exporter les variantes.

### Test F

Créer un projet → fermer l'application → rouvrir → retrouver le projet exactement où il était.

Si un utilisateur débutant ne sait pas quoi faire ensuite, améliorer le parcours plutôt que simplement ajouter du texte explicatif.

---

# 33. QUALITY REVIEWER

Créer un système de contrôle avant livraison.

Le reviewer doit pouvoir analyser :

- hiérarchie visuelle ;
- lisibilité ;
- contraste ;
- alignement ;
- surcharge ;
- cohérence de marque ;
- orthographe ;
- dimensions ;
- safe areas ;
- qualité média ;
- sous-titres ;
- audio ;
- export ;
- accessibilité.

Il doit retourner des problèmes actionnables et non des commentaires vagues.

---

# 34. GESTION DES ERREURS

Chaque opération importante doit avoir :

- loading ;
- success ;
- empty ;
- error ;
- retry ;
- cancellation ;
- offline ;
- permission denied ;
- unsupported capability lorsque pertinent.

Prévoir notamment :

- import échoué ;
- média corrompu ;
- stockage insuffisant ;
- export échoué ;
- génération IA échouée ;
- timeout ;
- absence de réseau ;
- provider indisponible ;
- permission refusée ;
- récupération après crash.

---

# 35. NAVIGATION

La navigation doit rester compréhensible.

Structure cible approximative :

```text
Home
 ├── Create
 │    ├── Video
 │    ├── Poster
 │    ├── Image
 │    ├── Audio
 │    ├── Scenario
 │    ├── Thumbnail
 │    ├── Campaign
 │    └── UX/UI
 │
 ├── Projects
 ├── Templates
 ├── Assets
 ├── Creative Studio
 ├── Notifications
 └── Profile/Settings
```

L'éditeur doit être un espace de travail dédié et ne doit pas donner l'impression d'une page classique de l'application.

---

# 36. MICRO-INTERACTIONS ET MOTION

Utiliser les animations pour :

- confirmer une action ;
- montrer une transition ;
- indiquer une progression ;
- aider à comprendre la hiérarchie ;
- rendre les manipulations plus naturelles.

Ne jamais utiliser des animations simplement parce qu'elles sont possibles.

Respecter Reduced Motion.

---

# 37. PERFORMANCE UI

Éviter :

- rebuilds inutiles ;
- listes lourdes non virtualisées ;
- images pleine résolution partout ;
- providers globaux inutiles ;
- logique dans build ;
- appels réseau directs dans les widgets ;
- traitements lourds sur le thread UI.

Surveiller :

- startup ;
- navigation ;
- scroll ;
- timeline ;
- thumbnails ;
- import ;
- export ;
- mémoire ;
- CPU ;
- batterie.

---

# 38. CODE QUALITY

Respecter :

- architecture claire ;
- noms explicites ;
- petites fonctions ;
- faible couplage ;
- forte cohésion ;
- interfaces ;
- tests ;
- documentation des décisions complexes ;
- aucun code mort ;
- aucun import inutilisé ;
- aucun TODO inutile ;
- aucun workaround non documenté.

Ne sur-architecturer pas les parties simples.

---

# 39. OBSERVABILITÉ

Ajouter lorsque pertinent :

- logs structurés ;
- erreurs ;
- crash reporting abstraction ;
- performance metrics ;
- export timings ;
- génération timings ;
- AI decision logs ;
- diagnostic local.

Aucune donnée sensible ne doit être loggée inutilement.

---

# 40. DOCUMENTATION À MAINTENIR

Le code doit être accompagné de documentation utile.

Créer/maintenir :

```text
docs/
 ├── architecture/
 ├── decisions/
 ├── workflows/
 ├── ai/
 ├── media/
 ├── design/
 ├── testing/
 └── troubleshooting/
```

Mettre à jour la documentation lorsque l'architecture change.

---

# 41. WORKFLOW D'IMPLÉMENTATION OBLIGATOIRE

Le travail doit être exécuté en **deux niveaux** :

1. autonomie complète à l'intérieur d'une phase ;
2. checkpoint humain uniquement entre les grandes versions.

L'objectif immédiat est **V1 → arrêt propre → attente de l'instruction utilisateur**.

## Phase 0 — Audit et préparation

- lire toute la documentation ;
- inspecter repository et historique Git ;
- identifier ce qui existe réellement ;
- compiler/lancer l'application ;
- lancer les tests existants ;
- vérifier les dépendances ;
- établir un backlog réel ;
- définir les risques et dépendances ;
- préparer les sous-agents ECC/specs utiles ;
- créer `.opencode/graceedit-execution-state.md`.

## Phase 1 — Fondation produit

- architecture ;
- routing ;
- state management ;
- design tokens ;
- thème clair/sombre ;
- internationalisation ;
- persistence ;
- autosave ;
- error handling ;
- logging ;
- capability system ;
- accessibilité ;
- responsive/adaptive foundations ;
- structure de tests ;
- structure de documentation.

## Phase 2 — Core utilisateur

- onboarding ;
- mode invité lorsque pertinent ;
- authentification si nécessaire ;
- permissions ;
- accueil ;
- projets ;
- création de projet ;
- import média ;
- galerie ;
- caméra ;
- asset library de base ;
- thumbnails ;
- états loading/empty/error/offline.

## Phase 3 — V1 VIDEO CLIENT-READY / WORLDWIDE

Cette phase est la **première livraison obligatoire**. Elle doit être réellement montrable au client et utilisable par des personnes réelles, sans dépendre d'une démonstration manuelle.

### Fonctionnalités V1

- lecture vidéo fiable ;
- timeline fonctionnelle ;
- thumbnails timeline ;
- trim ;
- split ;
- suppression ;
- réorganisation des clips ;
- crop/rotation/orientation ;
- vitesse lorsque stable ;
- texte de base ;
- audio de base ;
- volume ;
- import musique/audio ;
- sous-titres/captions de base ;
- réglages image essentiels ;
- thumbnail/couverture du projet ;
- aperçu avant export ;
- sauvegarde du projet ;
- autosave/recovery ;
- export vidéo réel ;
- profils courants 720p/1080p et formats vertical/carré/paysage ;
- partage vers le système ;
- gestion des erreurs d'export ;
- historique minimal permettant de récupérer d'une erreur lorsque pertinent.

### Exigences mondiales V1

- aucun contenu ou workflow ne doit supposer que l'utilisateur vient d'un pays précis ;
- architecture prête pour plusieurs langues ;
- français et anglais lorsque le périmètre V1 le permet ;
- textes UI localisables, jamais dispersés en dur dans les widgets ;
- formats date/heure adaptés à la locale ;
- accessibilité de base sérieuse ;
- dark mode et light mode ;
- gestion correcte des différentes tailles d'écran ;
- support des appareils modestes lorsque techniquement possible ;
- aucune dépendance à un service IA payant pour utiliser le cœur de l'éditeur ;
- aucune fonctionnalité critique ne doit être uniquement cosmétique.

### Design V1

Le produit doit être **premium, minimal, ergonomique, cohérent et durable**, sans esthétique générique « application IA ».

Le design doit privilégier :

- hiérarchie visuelle forte ;
- espaces respirants ;
- typographie maîtrisée ;
- composants cohérents ;
- interactions évidentes ;
- feedback précis ;
- animations discrètes ;
- accessibilité ;
- densité adaptée au contexte ;
- absence de décoration inutile ;
- distinction claire entre fonctionnalités essentielles et avancées.

Ne cherche pas à reproduire une interface connue pixel par pixel. Construis une identité propre à GraceEdit.

### Gate V1 obligatoire

Avant de déclarer V1 terminée :

- tests unitaires pertinents passent ;
- tests widget pertinents passent ;
- parcours E2E principaux passent ;
- import → montage → sauvegarde → réouverture → export fonctionne ;
- recovery après fermeture/reprise est vérifié ;
- thumbnails sont correctes ;
- dark/light mode sont vérifiés ;
- aucun overflow évident ;
- aucun bouton critique sans action ;
- aucune erreur critique connue non documentée ;
- performance acceptable sur matériel cible ;
- build release fonctionne ;
- documentation V1 mise à jour ;
- `.opencode/graceedit-execution-state.md` indique précisément le checkpoint ;
- préparer un changelog/release notes V1.

**Après ce gate, ARRÊTE l'exécution autonome.**

Ne passe pas automatiquement aux phases futures. Attends une instruction humaine telle que « suivant », « continue », « poursuis », « finis le projet » ou une phase précise.

## Phase 4 — Studio vidéo

Après autorisation de continuer :

- timeline avancée ;
- multi-track ;
- transitions ;
- effets ;
- keyframes si pertinent ;
- audio avancé ;
- color avancé ;
- versions ;
- proxy ;
- outils professionnels.

## Phase 5 — Templates + Graphic Design

- template engine ;
- poster editor ;
- flyer ;
- social formats ;
- thumbnail designer ;
- composition engine ;
- asset placement ;
- typography ;
- Brand Kit ;
- modèles adaptatifs.

## Phase 6 — Creative Studio

- Creative Studio ;
- brief ;
- creative workflows ;
- campaign ;
- asset library avancée ;
- recommandations de templates ;
- création multi-format.

## Phase 7 — AI foundation

- provider abstractions ;
- Jev adapter ;
- local AI adapters ;
- generation state machine ;
- prompt management ;
- role system ;
- AI history ;
- structured results ;
- cost/capability awareness.

## Phase 8 — AI creative workflows

- génération image ;
- génération vidéo ;
- génération audio ;
- TTS ;
- STT ;
- scénario ;
- storyboard ;
- auto assembly ;
- creative reviewer ;
- variations ;
- regeneration contrôlée.

## Phase 9 — Campaign + Brand

- campaign generation ;
- multi-format variants ;
- Brand Kit avancé ;
- synchronized assets ;
- export packs ;
- content calendar lorsque justifié.

## Phase 10 — UX/UI Studio

- UX workflow ;
- wireframes ;
- UI ;
- design system ;
- prototypes ;
- export/documentation ;
- rôles UX/UI IA.

## Phase 11 — Pro/export

- 60fps ;
- HEVC/H.265 ;
- 4K ;
- HDR lorsque supporté ;
- capability detection ;
- render queue ;
- background processing ;
- proxy avancé.

## Phase 12 — Hardening final

- security ;
- accessibility approfondie ;
- performance ;
- offline ;
- recovery ;
- migration ;
- license audit ;
- tests complets ;
- release builds ;
- documentation finale ;
- préparation production.

---

# 42. PRIORITÉ D'IMPLÉMENTATION

Toujours prioriser :

1. fonctionnalité réellement utilisable ;
2. stabilité ;
3. UX ;
4. performance ;
5. accessibilité ;
6. design polish ;
7. automatisation ;
8. fonctionnalités avancées.

Ne construis pas les fonctionnalités IA spectaculaires avant que le cœur vidéo/design soit solide.

---

# 43. DESIGN REVIEW AUTOMATIQUE

Pour chaque écran terminé, vérifie :

- alignement ;
- spacing ;
- typographie ;
- contraste ;
- hiérarchie ;
- touch targets ;
- états ;
- dark mode ;
- light mode ;
- loading ;
- empty ;
- error ;
- accessibility ;
- overflow ;
- petits écrans ;
- grands écrans lorsque pertinent.

Si l'écran paraît générique, améliore-le.

Le design doit donner l'impression d'un produit conçu par une équipe produit/design expérimentée.

---

# 44. CAPTURE ET QA VISUELLE

Lorsque l'environnement le permet :

- lancer l'application ;
- naviguer dans les parcours ;
- prendre des screenshots ;
- examiner les écrans ;
- corriger les problèmes ;
- recommencer.

Pour le Web, utiliser Playwright pour les parcours et vérifications pertinentes.

Ne considère pas une UI terminée sans l'avoir réellement observée lorsqu'un environnement de preview est disponible.

---

# 45. GIT ET CHECKPOINTS

Utiliser Git proprement.

Créer des commits cohérents après des blocs fonctionnels stables.

Exemples :

```text
feat(core): establish project architecture
feat(editor): implement timeline and thumbnails
feat(export): add media export pipeline
feat(studio): add graphic design editor
feat(ai): add provider abstraction
feat(ai): integrate decision orchestration
feat(creative): add campaign workflow
fix(editor): recover timeline state after interruption
perf(media): optimize thumbnail generation
```

Ne fais pas de commits contenant des secrets.

---

# 46. BACKLOG DYNAMIQUE

Maintenir :

```text
docs/IMPLEMENTATION_STATUS.md
```

Format :

```markdown
# Implementation Status

## Completed
- [x] ...

## In progress
- [ ] ...

## Blocked
- [ ] ...

## External dependencies
- [ ] ...

## Known limitations
- ...

## Next autonomous task
- ...
```

Après chaque grande étape, mets ce fichier à jour.

Le champ `Next autonomous task` doit toujours indiquer la prochaine tâche logique afin que le travail puisse reprendre après interruption.

---

# 47. GESTION DES INTERRUPTIONS

Si l'environnement arrête ton exécution :

1. relis `IMPLEMENTATION_STATUS.md` ;
2. inspecte Git ;
3. vérifie les tests ;
4. reprends à la prochaine tâche non terminée ;
5. ne recommence pas inutilement une tâche déjà stable.

---

# 48. SI TU TROUVES DU CODE EXISTANT DE MAUVAISE QUALITÉ

Ne détruis pas immédiatement le projet.

Procédure :

1. identifier le problème ;
2. vérifier son impact ;
3. écrire un test si possible ;
4. refactorer progressivement ;
5. vérifier les régressions ;
6. supprimer l'ancien code lorsqu'il est réellement inutile.

---

# 49. SI UNE BIBLIOTHÈQUE EST INADAPTÉE

Ne la conserve pas uniquement parce qu'elle existe déjà.

Comparer :

- licence ;
- stabilité ;
- performances ;
- maintenance ;
- compatibilité ;
- taille ;
- API ;
- communauté ;
- possibilité de remplacement.

Documenter la décision.

---

# 50. CE QUI EST INTERDIT DANS LE PRODUIT FINAL

Ne jamais livrer :

- écran vide sans raison ;
- bouton cassé ;
- navigation morte ;
- texte placeholder visible ;
- lorem ipsum ;
- fonctionnalités simulées sans indication ;
- erreurs silencieuses ;
- perte de projet ;
- clé API dans l'application ;
- dépendance avec licence incompatible non documentée ;
- écran surchargé ;
- IA omniprésente visuellement ;
- dark mode cassé ;
- light mode cassé ;
- overflow évident ;
- crash sur un parcours normal ;
- export annoncé mais non vérifié ;
- génération annoncée comme disponible sans provider réel.

---

# 51. DEFINITION OF DONE — ÉCRAN

Un écran est terminé uniquement si :

- UI finale ;
- dark mode ;
- light mode ;
- navigation ;
- données réelles ou provider clairement défini ;
- loading ;
- empty ;
- error ;
- interactions ;
- accessibility ;
- responsive/adaptation ;
- tests pertinents ;
- aucun warning critique ;
- aucun overflow connu ;
- documentation si comportement complexe.

---

# 52. DEFINITION OF DONE — FEATURE

Une feature est terminée uniquement si :

- modèle de données ;
- logique métier ;
- UI ;
- états ;
- persistance ;
- erreurs ;
- tests ;
- performance ;
- accessibilité ;
- documentation ;
- intégration avec les autres fonctionnalités ;
- aucune régression connue.

---

# 53. DEFINITION OF DONE — PRODUIT

GraceEdit peut être considéré comme une version réellement livrable lorsque :

- les parcours principaux fonctionnent de bout en bout ;
- un débutant peut créer un résultat sans tutoriel externe ;
- un utilisateur avancé peut utiliser le Studio ;
- les projets persistent ;
- les médias sont correctement manipulés ;
- les thumbnails sont fiables ;
- les exports sont vérifiés ;
- les erreurs sont récupérables ;
- dark/light sont cohérents ;
- les tests critiques passent ;
- aucune fonctionnalité critique n'est simulée ;
- les dépendances sont auditées ;
- l'application est performante sur un appareil Android raisonnable ;
- l'architecture permet l'ajout progressif des providers IA ;
- Creative Studio est structuré ;
- le système de rôles IA est extensible ;
- Jev est découplé ;
- l'application est prête à accueillir iOS/Desktop/Web.

---

# 54. ORDRE DE TRAVAIL À CHAQUE SESSION

À chaque reprise :

```text
1. Lire IMPLEMENTATION_STATUS.md
2. Vérifier Git
3. Vérifier les tests
4. Identifier la prochaine tâche
5. Implémenter
6. Tester
7. Corriger
8. QA visuelle
9. Mettre à jour documentation/status
10. Commit si stable
11. Passer à la tâche suivante
```

Ne t'arrête pas après une seule fonctionnalité si des tâches autonomes restent disponibles.

---

# 55. MODE LONGUE DURÉE

Tu dois privilégier la continuité.

Si tu as encore du temps, ne retourne pas simplement un résumé.

Continue à :

- implémenter ;
- tester ;
- corriger ;
- refactorer ;
- améliorer ;
- documenter ;
- vérifier.

Lorsqu'une fonctionnalité principale est terminée, passe automatiquement à la suivante selon le backlog.

Si tu rencontres un bug, corrige-le avant de passer à une fonctionnalité dépendante.

Si tu rencontres une limitation externe, isole-la et continue avec le reste.

---

# 56. CRITÈRE FINAL DE QUALITÉ

À la fin, ne te demande pas seulement :

> « Est-ce que le code fonctionne ? »

Demande-toi :

> « Est-ce qu'un véritable utilisateur pourrait installer GraceEdit, comprendre quoi faire, créer quelque chose de professionnel, récupérer son travail en cas de problème et exporter un résultat sans avoir besoin de moi ? »

Puis :

> « Est-ce que le produit est suffisamment bien structuré pour recevoir demain de nouveaux modèles IA, de nouveaux providers, de nouveaux templates, de nouvelles plateformes et de nouvelles fonctionnalités sans devoir être réécrit ? »

Si la réponse est non, continue le travail.

---

# 57. PREMIÈRE ACTION À EXÉCUTER

Commence immédiatement par :

```text
A. Lire toute la documentation GraceEdit.
B. Auditer le repository actuel.
C. Compiler et lancer les tests existants.
D. Créer docs/IMPLEMENTATION_AUDIT.md.
E. Créer docs/IMPLEMENTATION_STATUS.md.
F. Construire le backlog exhaustif à partir de l'écart entre la documentation et le code réel.
G. Commencer automatiquement par la tâche de plus haute priorité.
H. Ne demander aucune validation humaine pour les décisions techniques normales.
I. Continuer jusqu'à épuisement des tâches réalisables.
```

**Ne demande pas à l'utilisateur de te fournir une liste de tâches supplémentaire. La liste présente est précisément cette liste.**

---

# 58. RAPPORT FINAL

Lorsque toutes les tâches réalisables sont terminées, produire :

```text
docs/FINAL_IMPLEMENTATION_REPORT.md
```

avec :

- fonctionnalités terminées ;
- fonctionnalités partiellement disponibles ;
- providers externes nécessaires ;
- limitations matérielles ;
- limitations de plateforme ;
- tests exécutés ;
- résultats ;
- dépendances importantes ;
- licences ;
- performances observées ;
- bugs connus ;
- prochaines étapes réellement nécessaires.

Ne déclare jamais « 100 % terminé » si une fonctionnalité critique est uniquement simulée ou dépend d'un service externe non configuré.

---

# 59. INSTRUCTION FINALE À OPENCO​DE

**Travaille de manière autonome, méthodique et persistante.**

**Lis les documents avant de coder.**

**Ne te limite pas à créer des écrans : implémente les comportements réels.**

**Ne te limite pas à faire compiler : teste, observe, corrige et améliore.**

**Ne demande pas de validation pour les décisions ordinaires.**

**Ne laisse pas les fonctionnalités critiques sous forme de placeholders.**

**Privilégie une architecture simple, solide, testable et extensible.**

**Fais de GraceEdit un produit créatif réellement utilisable, pas une démonstration technique.**

**Lorsque tu as terminé une tâche, passe automatiquement à la suivante.**

**Si une capacité externe est indisponible, construis l'abstraction et continue le reste du projet.**

**Continue jusqu'à ce qu'il n'y ait plus de travail utile et réalisable dans le périmètre défini par cette documentation.**


---

# 50. CONTRAT DE REPRISE POUR LES FUTURES SESSIONS

À chaque nouvelle session, commence par lire :

1. `.opencode/graceedit-execution-state.md` ;
2. le dernier changelog ;
3. les décisions récentes ;
4. les tests/bugs connus ;
5. la documentation pertinente à la phase.

Si le checkpoint V1 est atteint et que l'utilisateur demande simplement de continuer, reprends à la première phase non terminée.

Si l'utilisateur écrit seulement **« suivant »**, interprète cela comme :

> reprendre le développement à la prochaine phase du roadmap, sans refaire les phases terminées, et travailler de manière autonome jusqu'au prochain checkpoint ou jusqu'à un blocage réel.

Si l'utilisateur écrit **« continue »**, même règle.

Si l'utilisateur écrit **« finis le projet »**, exécute toutes les phases restantes dans l'ordre des dépendances, avec sous-agents lorsque pertinent, jusqu'au hardening final.

Si une phase future est trop importante pour être terminée proprement dans une seule session, crée un checkpoint détaillé et reprends automatiquement au prochain appel.

Ne demande jamais à l'utilisateur de choisir entre plusieurs décisions techniques ordinaires. Ne remonte que les blocages qui nécessitent réellement une action externe impossible à automatiser.
