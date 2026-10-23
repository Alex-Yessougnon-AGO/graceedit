# Écran 25 — Autorisation d'accès aux médias (conditionnel)

**ID** `IMP-03` · **Phase** V1 (**conditionnel**) · **Routes** `/import/permission`, `/import/permission/denied` · **Fichiers** `imp03-acces-*`, `imp03-refuse-*`

## Quand l'afficher
**Seulement** si le **sélecteur de médias du système** n'est pas utilisable sur l'appareil (anciennes versions d'Android). Sur les appareils modernes, le sélecteur du système ne demande aucune autorisation générale et **cet écran n'apparaît jamais**.

## Explication (`imp03-acces-*`)
Icône d'image ; titre « Accès à vos photos et vidéos » ; deux lignes avec coche (« Vous choisissez ce que GraceEdit peut voir. » ; « Rien n'est envoyé en ligne. ») ; texte « Pour monter vos vidéos, GraceEdit a besoin d'accéder à vos photos et vidéos. » ; actions **« Continuer »** (principal → demande système) et **« Choisir des fichiers un par un »** (repli : sélecteur de documents du système).

## Refus (`imp03-refuse-*`)
Icône d'avertissement ; titre « Accès refusé » ; texte « Sans cet accès, GraceEdit ne peut pas afficher vos vidéos. Autorisez-le dans les réglages ou choisissez les fichiers un par un. » ; actions **« Ouvrir les réglages »** (principal → réglages de l'application), **« Choisir des fichiers un par un »** (contour), **« Retour »**.

## Règles
- Ne demander l'autorisation **qu'au moment d'en avoir besoin** (premier import), jamais au lancement.
- Si l'utilisateur refuse définitivement, ne pas redemander ; proposer le repli.
- Au retour des réglages, **revérifier** l'autorisation et poursuivre l'import si elle est accordée.

## Accessibilité
Cibles tactiles d'au moins 48 dp ; états annoncés par le texte et par la forme, jamais par la couleur seule ; grandes polices (200 %) : le contenu défile, les boutons principaux restent fixés en bas ; contrastes à mesurer sur les valeurs finales. Focus sur le titre ; annonce de la cause en cas de refus.

## Notes d'implémentation
Détecter la disponibilité du sélecteur du système ; sinon utiliser la gestion d'autorisations de la plateforme. Prévoir un test sur plusieurs versions d'Android.

## Points ouverts
Version minimale d'Android prise en charge (détermine si cet écran existe réellement).
