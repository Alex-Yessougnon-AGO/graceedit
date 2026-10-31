# GraceEdit V1 — Inventaire final des écrans

Tous les écrans de la V1 sont **dessinés et spécifiés** (✔). Dossier = `ecrans/<dossier>/`.

| N° | ID | Écran | Dossier | Route suggérée |
|---|---|---|---|---|
| 01 | ENT-01 | Splash | `ecran-01-splash` | `/splash` |
| 02 | ENT-02 | Bienvenue (premier lancement) | `ecran-02-bienvenue` | `/welcome` |
| 03 | HOM-01 | Accueil (avec projets, vide) | `ecran-03-accueil` | `/home` |
| 04 | IMP-02 | Nouveau projet (préparation des médias) | `ecran-04-nouveau-projet` | `/import/new` |
| 05 | EDT-01 | Éditeur, mode Simple | `ecran-05-editeur` | `/editor/:id` |
| 06 | EDT-02 | Rogner et scinder | `ecran-06-rogner-scinder` | (dans l'éditeur) |
| 07 | EDT-03 | Texte et titres | `ecran-07-texte` | (dans l'éditeur) |
| 08 | EDT-04 | Audio : musique, volume, fondus | `ecran-08-audio` | (dans l'éditeur) |
| 09 | EDT-05 | Ajuster, format, cadrer | `ecran-09-ajustements` | (dans l'éditeur) |
| 10 | EDT-07 | Couverture | `ecran-10-couverture` | (dans l'éditeur) |
| 11 | EXP-01 | Réglages d'export | `ecran-11-export-reglages` | `/export/:id` |
| 12 | EXP-02 | Progression de l'export | `ecran-12-export-progression` | `/export/:id/progress` |
| 13 | EXP-03 | Export réussi et partage | `ecran-13-export-reussite` | `/export/:id/result` |
| 14 | EXP-04 | Échec et annulation de l'export | `ecran-14-export-echec` | `/export/:id/error` |
| 15 | PRJ-01/02/03/06 | Projets, actions, suppression, sélection, corbeille | `ecran-15-projets` | `/projects`, `/projects/trash` |
| 16 | PRJ-05 | Média manquant | `ecran-16-media-manquant` | `/projects/:id/relink` |
| 17 | SET-01 | Réglages | `ecran-17-reglages` | `/settings` |
| 18 | SET-02 | Stockage et cache | `ecran-18-stockage` | `/settings/storage` |
| 19 | SET-03 | Aide, diagnostic, à propos | `ecran-19-aide-apropos` | `/settings/help` |
| 20 | SYS-01 | Récupération après fermeture inattendue | `ecran-20-recuperation` | (feuille au lancement) |
| 21 | SYS-02 | Échec de sauvegarde (EDT-06) | `ecran-21-echec-sauvegarde` | (feuille dans l'éditeur) |
| 22 | SYS-03 | Stockage faible et plein | `ecran-22-stockage-plein` | `/system/storage-full` |
| 23 | SYS-04 | Fonction non prise en charge | `ecran-23-fonction-non-prise-en-charge` | (fenêtre) |
| 24 | SYS-05 | Autorisation de notification | `ecran-24-autorisation-notification` | (feuille avant export) |
| 25 | IMP-03 | Autorisation d'accès aux médias (conditionnel) | `ecran-25-autorisation-medias` | `/import/permission` |
| 26 | EDT-08 | États de l'éditeur (vide, lecture, manquant, paysage) | `ecran-26-etats-editeur` | (dans l'éditeur) |
| 27 | CMP-01 | Composants communs | `ecran-27-composants` | (composants) |

**Non dessiné volontairement** : `IMP-01` (sélecteur de médias, écran du **système**) ; panneau de partage (système) ; clavier (système) ; menu de tri et fenêtre « Renommer » (dessinés dans `CMP-01`).
**États ajoutés à la dernière révision** : onglets Style, Police et Fond du texte (`ecran-07-texte`), feuilles de langue et de suppression (`ecran-17-reglages`), corbeille vide (`ecran-15-projets`), vérification d'un média (`ecran-16-media-manquant`).
**Ressources** : `design/` (logo, icônes, icône d'application, icône de notification, polices, jetons).
**Non dessiné, post-V1** : tablettes et pliables (décrits dans `ecran-26-etats-editeur`, dessin prévu au lot P2-F de `PHASE2_PLAN.md`).
**Hors V1** : voix off, enregistrement caméra, filtres, vitesse, sous-titres, transitions, mode Studio, modèles, bibliothèque d'assets, génération IA, campagnes.
