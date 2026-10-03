# Décision — Port design OD → Flutter (Accueil)

Date : 2026-10-03. Source : `home.html` (run OD), brief confirmé, docs 03/07.

## Adopté
- Bottom nav 4 items + FAB central Créer (Accueil, Bibliothèque, Créer, Profil).
- Vignettes projet 80×60 avec badge durée bas-droite (thumbnail représentative).
- Section header 18px w700 ; icônes cartes création 40px.
- Bibliothèque globale (tous projets) quand aucune session éditeur ouverte.

## Divergences assumées
1. **Serif display (Playfair) rejetée** : le brief confirmé et docs 03/07 exigent
   une sans-serif hautement lisible. Le choix serif de l'agent OD contredit le
   brief → brief gagne. Titres en sans w700.
2. **Nav à 4 items au lieu de 5** : l'item Modèles mènerait vers un écran inexistant
   (bouton mort = interdit §1.4 master). Modèles arrivera Phase 5 ; la nav
   passera à 5 items à ce moment-là.
3. **Profil = Paramètres** : l'écran settings (thème, langue, à-propos) tient lieu
   de profil en V1. Écran profil dédié si besoin Phase 4+.
4. **Ombres subtiles OD ignorées** : DESIGN.md impose flat-first (bordures, pas
   d'ombres). Cohérence avec le système.
5. **Placeholders via.placeholder.com ignorés** : vraies thumbnails natives.
