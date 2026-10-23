# Écran 02 — Bienvenue (premier lancement)

**ID** : `ENT-02` · **Phase** : V1 · **Précédent** : `ENT-01` (splash) · **Fichiers** : `ecran-02-clair.png`, `ecran-02-sombre.png` (1080 × 2400 px = 360 × 800 dp à 3x)

## Décision de conception
Le brief demande un premier succès rapide et déconseille les interruptions d'onboarding. L'écran est donc **une seule page**, pas un carrousel de trois diapositives. Il dit ce que fait l'application, rassure sur trois points concrets, puis propose deux actions. L'application doit se faire comprendre par son interface principale, pas par cet écran.

## Rôle
Orienter l'utilisateur au premier lancement et le mener le plus vite possible vers l'import d'une vidéo (parcours : premier lancement → intention → import → montage → export).

## Contenu (de haut en bas)

| Zone | Contenu | Style |
|---|---|---|
| En-tête | Symbole + logotype GraceEdit, alignés à gauche, symbole 36 dp | Marge 24 dp, à 56 dp du haut |
| Titre | « Montez vos vidéos, simplement. » | 34 sp, semi-gras, interligne 40 |
| Texte | « Importez une vidéo, coupez, ajoutez du texte, puis exportez. » | 16 sp, interligne 24, couleur secondaire |
| Bande décorative | 4 blocs arrondis dont un en accent | Hauteur 56 dp, rayon 10 dp, décorative |
| Garanties | « Aucun compte nécessaire » · « Fonctionne sans connexion » · « Vos fichiers restent sur votre téléphone » | 15 sp, une puce par ligne, 32 dp par ligne |
| Action principale | « Monter une vidéo » | Bouton plein, 56 dp de haut, pleine largeur |
| Action secondaire | « Explorer d’abord » | Bouton texte, 48 dp de haut |

## Valeurs de design

| Élément | Clair | Sombre |
|---|---|---|
| Fond | `#F6F2EA` | `#14151A` |
| Texte principal | `#14151A` | `#F6F2EA` |
| Texte secondaire | `#5E5C58` | `#B9B5AD` |
| Surface (blocs) | `#E4DED2` | `#2A2C33` |
| Bouton principal (fond / texte) | `#14151A` / `#F6F2EA` | `#F6F2EA` / `#14151A` |
| Accent | `#E2542B` | `#E2542B` |

Typographie : Inter (licence OFL, à confirmer avant publication). Grille 8 dp, marges latérales 24 dp.

## Comportement
- **« Monter une vidéo »** : ouvre directement le sélecteur de médias du système. Dès que des médias sont choisis, l'écran « Nouveau projet » (`IMP-02`) s'ouvre. Cas particulier : si une seule vidéo est choisie et qu'elle est utilisable immédiatement, `IMP-02` est sauté et l'éditeur s'ouvre directement (règle détaillée dans la fiche `IMP-02`). Pas de permission demandée avant : le sélecteur système ne nécessite pas d'accès général au stockage (comportement du sélecteur de photos Android à confirmer dans la documentation, y compris sur les versions plus anciennes d'Android, où un repli est à prévoir).
- **Annulation du sélecteur** : retour à cet écran, inchangé, sans message d'erreur.
- **« Explorer d'abord »** : ouvre l'accueil (`HOM-01`) dans son état vide, avec l'action « Nouveau projet ».
- **Affichage unique** : cet écran n'apparaît qu'au premier lancement. Un indicateur local mémorise qu'il a été vu. Il reste accessible plus tard depuis Réglages > Aide.
- **Bouton Retour** : quitte l'application (aucun écran précédent).
- **Transition d'entrée** : fondu de 200 ms depuis le splash. Aucune animation du contenu.

## États et adaptation
- **Thèmes** : clair et sombre dessinés séparément, selon le réglage du système.
- **Grandes polices (200 %)** : la colonne de contenu défile, les deux boutons restent fixés en bas de l'écran. Aucun texte n'est tronqué.
- **Langues** : tous les textes sont externalisés. Le français est la langue source, l'anglais est la première traduction. Prévoir jusqu'à 30 % de texte en plus : les garanties peuvent passer sur deux lignes sans casser la mise en page.
- **Grands écrans et pliables** : contenu centré, largeur maximale 480 dp.
- **Paysage** : colonne défilante, boutons visibles en bas.
- **Appareils modestes** : aucun flou, aucune ombre, aucune animation. Écran entièrement statique.

## Accessibilité
- Ordre de lecture : titre (annoncé comme titre), texte, les trois garanties, action principale, action secondaire.
- Le logotype est annoncé « GraceEdit ». La bande de blocs est décorative et ignorée par les lecteurs d'écran.
- Cibles tactiles : 56 dp et 48 dp, supérieures au minimum de 48 dp.
- Contraste : texte principal supérieur à 15:1 dans les deux thèmes. Le texte secondaire doit dépasser 4,5:1 : à confirmer avec un outil de mesure sur les valeurs finales.
- Aucune information ne passe par la couleur seule. L'accent est décoratif.

## Conditions de vérité des textes
Les trois garanties ne doivent s'afficher que si elles sont exactes. Elles reposent sur une hypothèse de la V1 :
- « Aucun compte nécessaire » : suppose qu'il n'y a pas de compte obligatoire en V1.
- « Fonctionne sans connexion » : suppose que l'import, le montage et l'export locaux fonctionnent hors ligne, ce que demande le contexte du projet.
- « Vos fichiers restent sur votre téléphone » : suppose qu'aucun média n'est envoyé en ligne en V1. Cette ligne doit être retirée ou reformulée dès qu'une fonction cloud ou IA en ligne existe.

## Points ouverts
- **Tutoiement ou vouvoiement** : j'ai écrit au vouvoiement, plus neutre pour un public international. À trancher pour toute l'application.
- **Bande décorative** : elle donne un point d'ancrage visuel mais n'apporte pas d'information. À supprimer si elle est jugée superflue ou ressemblant à un chargement.
- **Réglage de l'expérience (Simple ou Studio)** : volontairement absent de cet écran. L'expérience par défaut est Simple, modifiable plus tard.
- **Langue** : suit la langue du système. Un sélecteur n'est pas proposé ici.
