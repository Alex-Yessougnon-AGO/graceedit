# GraceEdit V1 — Flux de l'application, fonctionnement et actions attendues

Ce document décrit **dans l'ordre** les écrans de la V1, comment on passe de l'un à l'autre, et ce que chaque action doit faire. Il se lit avec `ecrans/` (images et fiches détaillées `SPEC_*.md`) et `design/DESIGN_TOKENS.md`.

**Priorité des sources** : (1) la fiche `SPEC_*.md` de l'écran pour le **comportement** ; (2) ce fichier pour **l'enchaînement** ; (3) les images pour l'**aspect** ; (4) `design/DESIGN_TOKENS.md` pour les **valeurs**. En cas de contradiction, la fiche de l'écran l'emporte ; signaler l'écart plutôt que choisir.

Les routes ci-dessous sont des **suggestions** pour GoRouter.

---

## 1. Principes du produit (à respecter partout)
1. **Local d'abord** : aucun compte, aucun envoi en ligne, tout fonctionne **hors connexion**.
2. **Non destructif** : les médias d'origine ne sont jamais modifiés ni supprimés ; les projets les **référencent** (pas de copie).
3. **Sauvegarde automatique** : l'utilisateur n'a jamais à « enregistrer ». L'état est toujours visible (« Enregistré », « Enregistrement… », « Non enregistré »).
4. **Rien de faux** : pas de bouton sans action, pas de pourcentage inventé, pas d'option présentée comme possible si l'appareil ne peut pas la faire.
5. **Toujours une issue** : chaque erreur dit **ce qui est sûr**, **ce qui s'est passé**, **quoi faire**.
6. **Annuler plutôt que confirmer** (messages « Annuler » après une action réversible). Une fenêtre de confirmation seulement pour : annulation d'export, suppression (choix corbeille/définitive), vider la corbeille.
7. **Accessibilité** : zones tactiles ≥ 48 dp ; jamais la couleur seule ; alternative à chaque geste de glissement ; grandes polices (200 %).
8. **Langue** : français (source) et anglais ; toutes les chaînes dans des fichiers de traduction ; espaces insécables (voir `SPEC_ECRAN_27`).
9. **Appareils modestes** : pas de flou, d'ombres ni d'animations décoratives ; miniatures en cache à la taille d'affichage ; listes paresseuses ; calculs lourds hors du fil d'interface.

---

## 2. Carte de navigation

```
Lancement ── ENT-01 Splash ──┬─ (récupération nécessaire) ─► SYS-01 Récupération ─┐
                             ├─ (premier lancement) ───────► ENT-02 Bienvenue      │
                             └─ (sinon) ───────────────────► HOM-01 Accueil ◄──────┘

Barre de navigation (3 destinations) : HOM-01 Accueil · PRJ-01 Projets · SET-01 Réglages

ENT-02 ── « Monter une vidéo » ─► IMP-01 (sélecteur système) ─► IMP-02 Nouveau projet ─► EDT-01 Éditeur
       └─ « Explorer d'abord » ──► HOM-01 (état vide)

HOM-01 ── Reprendre / ligne récente ─► EDT-01   (si média manquant : PRJ-05)
       ├─ Tout voir ─► PRJ-01
       └─ Nouveau projet ─► IMP-01 ─► IMP-02 ─► EDT-01

PRJ-01 ── ligne ─► EDT-01 (ou PRJ-05) · ⋮ ─► PRJ-02 actions ─► Renommer / Dupliquer / Exporter(EXP-01) / Sélectionner / Supprimer(PRJ-03)
       ├─ Sélection multiple ─► Dupliquer / Supprimer(PRJ-03)
       ├─ Recherche · Tri (CMP-01) · Grille/Liste
       └─ ⋮ ─► Corbeille ─► PRJ-06 (Restaurer / Supprimer définitivement / Vider)

EDT-01 Éditeur ── outils généraux : Ajouter(IMP-01) · Audio(EDT-04) · Texte(EDT-03) · Ajuster/Format(EDT-05) · Couverture(EDT-07)
               ├─ clip sélectionné : Scinder · Rogner(EDT-02) · Volume · Cadrer(EDT-05) · Supprimer · Plus
               ├─ états : vide / lecture / média manquant(PRJ-05) / paysage (EDT-08)
               └─ Exporter ─► EXP-01 ─► (SYS-05 si besoin) ─► EXP-02 ─┬─► EXP-03 Réussite
                                                                       └─► EXP-04 Échec / annulation

SET-01 ─► SET-02 Stockage (─► PRJ-06 Corbeille) · SET-03 Aide (─► ENT-02 · Diagnostic)
Transversaux : SYS-02 échec de sauvegarde · SYS-03 stockage faible/plein · SYS-04 non pris en charge · IMP-03 autorisation médias (conditionnel) · CMP-01 composants
```

## 3. Routes suggérées
| Route | Écran | ID |
|---|---|---|
| `/splash` | Splash | ENT-01 |
| `/welcome` | Bienvenue | ENT-02 |
| `/home` | Accueil | HOM-01 |
| `/import/new` | Nouveau projet (préparation des médias) | IMP-02 |
| `/import/permission` · `/import/permission/denied` | Autorisation médias | IMP-03 |
| `/editor/:projectId` | Éditeur (+ feuilles et modes internes) | EDT-01 à EDT-08 |
| `/export/:projectId` · `/export/:projectId/progress` · `/export/:projectId/result` · `/export/:projectId/error` | Export | EXP-01 à EXP-04 |
| `/projects` · `/projects/trash` · `/projects/:projectId/relink` | Projets, corbeille, média manquant | PRJ-01, PRJ-06, PRJ-05 |
| `/settings` · `/settings/storage` · `/settings/help` · `/settings/help/diagnostic` | Réglages | SET-01 à SET-03 |
| `/system/storage-full` | Stockage plein | SYS-03 |

Feuilles, fenêtres et modes (texte, audio, ajustements, format, cadrer, couverture) sont des **états internes** de l'éditeur ou de l'écran, pas des routes de premier niveau.

---

## 4. Parcours à valider de bout en bout
**P1 — Première création** : Splash → Bienvenue → « Monter une vidéo » → sélecteur système → (une seule vidéo prête : directement l'éditeur ; sinon `IMP-02` → « Commencer le montage ») → éditeur → Exporter → réglages → Exporter → progression → réussite → Partager.
**P2 — Reprise** : Accueil → « Reprendre » → éditeur à l'état enregistré (position, zoom, sélection).
**P3 — Média manquant** : ligne en erreur → `PRJ-05` → Reconnecter (fichier compatible) → « Ouvrir le projet ».
**P4 — Suppression** : Projets → sélectionner 2 projets → Supprimer → « Mettre à la corbeille » → « Annuler » (message) ; puis Corbeille → Restaurer ; puis Supprimer définitivement (double confirmation).
**P5 — Échec d'export** : espace insuffisant en cours de rendu → `EXP-04` → « Libérer de l'espace » → `SET-02` → « Vider le cache » → retour → « Exporter en Standard ».
**P6 — Récupération** : fermeture forcée en édition → relancer → `SYS-01` → « Reprendre le projet ».

---

## 5. Fiches fonctionnelles par écran
Pour chaque écran : **Entrées**, **Actions → destination**, **États**, **Règles clés**, **Référence** (dossier `ecrans/…`).

### ENT-01 Splash — `ecran-01-splash`
- **Entrées** : lancement de l'application.
- **Contenu** : symbole centré (120 dp), rien d'autre. Fond selon le thème. Android 12+ : même symbole et même fond pour le splash système.
- **Actions** : aucune. Durée = temps réel d'initialisation (aucun délai artificiel). Fondu de sortie 200 ms.
- **Sorties** : récupération nécessaire → `SYS-01` ; premier lancement → `ENT-02` ; sinon → `HOM-01`.
- **États** : initialisation échouée → écran d'erreur avec « Réessayer » (jamais bloqué) ; démarrage > 5 s → message « Préparation en cours… ».

### ENT-02 Bienvenue — `ecran-02-bienvenue`
- **Entrées** : premier lancement ; `SET-03` « Revoir la présentation ».
- **Contenu** : titre « Montez vos vidéos, simplement. », phrase, trois garanties (« Aucun compte nécessaire », « Fonctionne sans connexion », « Vos fichiers restent sur votre téléphone »), bande décorative.
- **Actions** : « Monter une vidéo » → sélecteur système (aucune permission préalable) ; « Explorer d'abord » → `HOM-01` vide. Annulation du sélecteur → retour inchangé. Retour système = quitter.
- **Règles** : affiché **une seule fois** (indicateur local). Les trois garanties ne s'affichent que si elles sont vraies (pas de compte, hors connexion, rien d'envoyé).

### HOM-01 Accueil — `ecran-03-accueil`
- **Variante A (avec projets)** : « Reprendre » (dernier projet modifié) ; « Récents » (jusqu'à 5, section absente s'il n'y a qu'un projet) ; bouton « Nouveau projet ». **Variante B (vide)** : emplacement en pointillés + « Monter une vidéo » (pas de bouton flottant).
- **Actions** : toucher « Reprendre » ou une ligne → éditeur à l'état enregistré ; ligne « Média manquant » → `PRJ-05` ; « Tout voir » → `PRJ-01` ; « Nouveau projet » → sélecteur système → `IMP-02`.
- **États** : miniature en chargement / non générée (neutre) / **média manquant** (erreur) ; bandeau stockage faible (`SYS-03`) ; brouillon récupéré ; export en cours (bandeau).
- **Barre supérieure** : symbole et nom seulement (aucune icône d'action en V1).

### IMP-02 Nouveau projet — `ecran-04-nouveau-projet`
- **Entrées** : après le sélecteur système (≥ 1 média). **Saut** si **une seule** vidéo prête : l'éditeur s'ouvre directement avec un nom par défaut.
- **Contenu** : nom prérempli (« Projet du 19 oct. »), liste des médias (miniature, durée, poids, titre = date/heure de prise de vue sinon nom de fichier), poignée de réorganisation, retirer (du **projet**, pas du téléphone), « Ajouter des médias ».
- **Actions** : « Commencer le montage » (ou « Commencer avec N médias ») → éditeur ; retour = annuler (rien d'enregistré, aucune confirmation).
- **Règles** : bouton actif dès qu'**au moins un média utilisable** existe (un média en préparation compte) ; les médias non pris en charge sont ignorés mais listés avec l'erreur ; réorganisation accessible sans glisser (« Monter / Descendre »).

### EDT-01 Éditeur (mode Simple) — `ecran-05-editeur`
- **Structure** : barre (retour, titre, état de sauvegarde, « Exporter ») ; aperçu (région fixe 260 dp) ; ligne de lecture (temps, lecture, annuler, rétablir) ; timeline (règle, piste vidéo, pistes texte et audio, **tête de lecture fixe au centre**) ; barre d'outils contextuelle.
- **Aucun clip sélectionné** (barre générale, défilante) : Ajouter, Audio, Texte, Ajuster, Format, Couverture.
- **Clip sélectionné** : chevron de retour + Scinder, Volume, Cadrer, Supprimer, Plus (Dupliquer…).
- **Gestes** : toucher = sélectionner ; glisser la timeline = déplacer la tête ; pincer = zoom ; poignées = rogner ; appui long + glisser = déplacer un clip ; aimantation (tête de lecture, bords) avec retour haptique.
- **Suppression** : sans confirmation, message « Clip supprimé · Annuler » ; l'espace se referme.
- **Sorties** : « Exporter » → `EXP-01` (désactivé si timeline vide) ; retour → `HOM-01` (sans confirmation si « Enregistré »).

### EDT-02 Rogner et scinder — `ecran-06-rogner-scinder`
- **Rognage** : poignée active (accent), partie retirée atténuée en pointillés, bulle « −0:58 / Durée 1:17 », aimantation, aperçu = image **à la poignée**, tête de lecture masquée pendant le geste, clip suivant avance à la fin du geste.
- **Scinder** : coupe le clip **sélectionné** à la tête de lecture en deux clips ; sélection reste à gauche ; message « Clip scindé · Annuler ». Désactivé si la tête est hors du clip ou sur une limite.
- **Rognage précis** : feuille non modale, Début/Fin au pas de 0,1 s (boutons − et +), limites respectées, une seule action d'annulation.
- Clip < 40 dp à l'écran : poignées à l'extérieur. Durée minimale 0,1 s.

### EDT-03 Texte — `ecran-07-texte`
- **Ajout** : outil « Texte » → un texte est ajouté à la tête de lecture (3 s) → clavier ouvert → champ de saisie, préréglages (Titre, Sous-titre, Légende), « Terminé » (désactivé si vide) ; ✕ supprime un nouveau texte ou annule les changements.
- **Texte sélectionné** : cadre, 4 poignées d'angle (redimensionner), poignée de rotation, glisser = déplacer, double appui = modifier ; barre : Modifier, Style, Couleur, Supprimer, Plus.
- **Style** (feuille) : onglets Style, Police, Couleur, Fond ; six couleurs (≥ 48 dp), curseurs Taille et Opacité ; alternatives accessibles (alignement et position verticale par deux choix, rotation par pas de 15°).
- La timeline s'agrandit à l'ajout pour que l'élément fasse ≥ 64 dp.

### EDT-04 Audio — `ecran-08-audio`
- **Mixage** (outil Audio) : « Son de la vidéo » et « Musique » (curseur 0–100 %, icône haut-parleur = couper), « Ajouter de la musique » → sélecteur de **fichiers audio du système** ; la musique démarre à la tête de lecture, coupée à la fin du projet, jamais bouclée.
- **Élément audio sélectionné** : forme d'onde, poignées ; barre : Volume, Fondu, Scinder, Supprimer, Plus.
- **Volume et fondus** : volume 0–100 %, fondu d'entrée et de sortie 0–10 s (somme ≤ durée), aperçu des rampes.
- Pas de catalogue de musique, pas de voix off en V1.

### EDT-05 Ajustements, format, recadrage — `ecran-09-ajustements`
- **Ajuster** : Luminosité, Contraste, Saturation (−100 à +100) ; portée « Ce clip » / « Tout le projet » (copie dans chaque clip) ; « Comparer » (appui long = original, appui simple = bascule) ; « Réinitialiser ».
- **Format** : Vertical 9:16, Carré 1:1, Horizontal 16:9, Portrait 4:5 ; mode « Remplir » ou « Ajuster » (bandes noires) ; défaut = format du premier média.
- **Cadrer** (plein écran, clip sélectionné) : cadre, grille des tiers, rapports, Pivoter (90°), Miroir, Redresser (−45° à +45°), Réinitialiser, « Terminé » = une action d'annulation.

### EDT-07 Couverture — `ecran-10-couverture`
- Couverture **automatique** (première image) tant qu'aucun choix ; choix → fixe.
- **Image de la vidéo** : bande de 8 vignettes + cadre mobile (accent) ; **Galerie** : sélecteur d'images du système, glisser/pincer pour recadrer, image **copiée** dans le projet (≤ 1280 px).
- « Dans vos projets » montre l'usage réel (miniature 16:9).

### EDT-08 États de l'éditeur — `ecran-26-etats-editeur`
- **Vide** (aucun média, Exporter désactivé), **Lecture** (pause, tête fixe), **Média manquant** (tuile + « Reconnecter » → `PRJ-05`), **Paysage/tablette** (aperçu à gauche, timeline à droite, outils en bas, panneaux à droite).

### EXP-01 Réglages d'export — `ecran-11-export-reglages`
- **Contenu** : récapitulatif ; **Qualité** = Haute 1080p / Standard 720p (selon les capacités de l'appareil ; une option impossible n'est **pas affichée**) ; Format (→ outil Format) ; Destination « Galerie du téléphone » ; espace disponible.
- **Espace insuffisant** : option marquée, encadré (ce qu'il faut / ce qu'il reste / quoi faire), « Exporter » désactivé avec la raison.
- **Contrôles avant export** : projet vide, média manquant (→ `PRJ-05`), batterie très faible (non bloquant).
- **Sorties** : « Exporter » → (`SYS-05` au premier export si nécessaire) → `EXP-02`.

### EXP-02 Progression — `ecran-12-export-progression`
- **Étapes** : Préparation (indéterminée) → Création de la vidéo (**pourcentage réel**, ne recule jamais) → Vérification (indéterminée). Pas de temps restant ; temps écoulé affiché.
- **Actions** : « Continuer en arrière-plan » (→ accueil, bandeau « Export en cours ») ; « Annuler l'export » → fenêtre de confirmation (action sûre « Continuer l'export » en bouton plein) → retour à `EXP-01` avec « Export annulé ».
- **Notification** : progression + « Annuler » ; à la fin « Export terminé » avec « Partager » et « Ouvrir ». L'export fonctionne **même sans autorisation de notification**.
- Écran gardé allumé tant qu'affiché ; projet exporté **verrouillé en lecture seule** pendant l'export.

### EXP-03 Réussite — `ecran-13-export-reussite`
- Affiché **après** vérification du fichier **et** enregistrement dans la galerie. Vignette + lecture interne, « Vidéo enregistrée », nom, dimensions, durée, **taille réelle**.
- **Actions** : « Partager » (panneau du système) ; « Voir dans la galerie » ; « Continuer à modifier » → éditeur ; ✕/Retour → accueil. Aucune publicité, aucune demande de note.

### EXP-04 Échec ou annulation — `ecran-14-export-echec`
- Gabarit : ce qui est sûr (« Votre projet est intact. ») · ce qui s'est passé · actions.
- **Cas** : échec de rendu (Réessayer / Essayer en Standard / Détails techniques) ; espace épuisé (Libérer de l'espace → `SET-02`, fichier incomplet supprimé) ; vidéo créée mais non ajoutée à la galerie (Réessayer l'ajout / Enregistrer sous…) ; **annulation** = simple message sur `EXP-01` ; interruption (réouverture) → « Recommencer l'export ».

### PRJ-01/02/03/06 Projets — `ecran-15-projets`
- **Liste/grille**, tri (Récents, Plus anciens, Nom A–Z), recherche sur les titres, menu « ⋮ » (Sélectionner, Corbeille).
- **Feuille d'actions** : Renommer, Dupliquer, Exporter, Sélectionner, Supprimer.
- **Sélection multiple** : appui long ou « Sélectionner » ; barre du bas Dupliquer / Supprimer ; « Tout sélectionner ».
- **Suppression** : fenêtre à trois actions — **« Mettre à la corbeille »** (défaut, 30 jours, message « Annuler » 6 s), **« Supprimer définitivement »** (seconde confirmation, « Annuler » en bouton plein), « Annuler ». Un projet en cours d'export ne peut pas être supprimé.
- **Corbeille** : ligne avec jours restants (≤ 1 jour = avertissement), Restaurer, Supprimer définitivement, « Vider » (confirmation) ; purge automatique à 30 jours.

### PRJ-05 Média manquant — `ecran-16-media-manquant`
- **Reconnecter** → sélecteur système limité au type ; vérification (lisible, type, durée proche) ; si différent → fenêtre « Ce fichier est différent » (action sûre « Choisir un autre fichier ») ; « Retirer du projet » (retire aussi les clips, message « Annuler »).
- « Ouvrir le projet » actif quand tout est reconnecté ou retiré ; « Ouvrir sans ces médias » toujours disponible. **Aucun balayage** du stockage.

### SET-01/02/03 Réglages — `ecran-17-reglages`, `ecran-18-stockage`, `ecran-19-aide-apropos`
- **SET-01** : Thème (Système/Clair/Sombre), Langue, Réduire les animations, Retour haptique, Suppression (demander / toujours corbeille), Corbeille, Stockage, Aide.
- **SET-02** : total utilisé + barre segmentée + légende ; « Vider » le cache (**ne touche jamais** aux projets, médias, exports) ; exports non enregistrés ; corbeille ; espace libre.
- **SET-03** : Revoir la présentation, Questions fréquentes (intégrées), **Rapport de diagnostic** (généré sur l'appareil, copié ou partagé **par l'utilisateur**, jamais envoyé automatiquement), version, licences, conditions, confidentialité.

### Systèmes — `ecran-20` à `ecran-25`
- **SYS-01 Récupération** (feuille au lancement, une fois) ; **SYS-02 Échec de sauvegarde** (« Non enregistré », réessais automatiques) ; **SYS-03 Stockage faible** (bandeau) et **plein** (écran) ; **SYS-04 Non pris en charge** (repli concret) ; **SYS-05 Notifications** (une explication avant le premier export, jamais bloquante) ; **IMP-03 Autorisation médias** (**conditionnel**, seulement si le sélecteur système est inutilisable).

### CMP-01 Composants — `ecran-27-composants`
Menu de tri, fenêtre « Renommer » (60 caractères, nom non vide), messages temporaires (4 à 6 s, un à la fois), règles typographiques.

---

## 6. Machines d'états
- **Import (par média)** : `selected → preparing(%) → ready | unsupported | unreadable`.
- **Sauvegarde du projet** : `saved ⇄ saving → failed(reason) → (réessai) saved` ; `recovered` après `SYS-01`.
- **Export** : `idle → preflight(blocked?) → preparing → rendering(%) → verifying → registering → done | failed(cause) | cancelled | interrupted`.
- **Projet** : `active → trashed(30 j) → restored | purged` ; `active → deleted` (définitive).
- **Média** : `ok | missing | different(durée) | removed`.
- **Éditeur** : `empty | ready | playing | missingMedia`.

## 7. Modèle de données suggéré (local)
`Project(id, title, createdAt, modifiedAt, format, fitMode, coverRef, trashedAt?)` · `MediaRef(id, uri, type, name, duration, size, width, height, status)` · `Clip(id, mediaId, trimStart, trimEnd, order, adjustments, crop, volume)` · `TextItem(id, text, style, position, rotation, start, duration)` · `AudioItem(id, mediaId, start, trimStart, trimEnd, volume, fadeIn, fadeOut)` · `ExportJob(id, projectId, quality, state, progress, outputUri?, error?)` · `Settings(theme, language, reduceMotion, haptics, deleteBehavior, sort, view)`.

## 8. Décisions par défaut (modifiables)
Aucun compte · voix off, enregistrement caméra, filtres, vitesse, sous-titres, transitions : **hors V1** · corbeille 30 jours **et** suppression définitive · pas de catalogue de musique · qualité d'export Haute/Standard à 30 images/s · 60 images/s, 4K, HEVC, HDR : hors V1.

## 9. Ordre de réalisation conseillé
**M0** socle (thème et jetons, i18n, navigation, base locale, services de stockage et de sauvegarde) → **M1** entrée, accueil, import → **M2** éditeur de base (aperçu, timeline, lecture, sélection, annuler/rétablir, sauvegarde) → **M3** outils (rogner/scinder, texte, audio, ajustements/format/cadrer, couverture) → **M4** export complet (réglages, progression, notification, réussite, échecs) → **M5** projets (liste, grille, recherche, sélection, corbeille, média manquant) → **M6** réglages et états système → **M7** accessibilité, performance sur appareil modeste, finitions.

**Critère d'acceptation d'un écran** : (a) conforme à l'image dans les deux thèmes ; (b) toutes les actions de la fiche fonctionnent et mènent à la bonne destination ; (c) tous les états listés sont atteignables ; (d) zones tactiles ≥ 48 dp, lecteur d'écran, police à 200 % ; (e) aucune chaîne en dur ; (f) aucun comportement non décrit.
