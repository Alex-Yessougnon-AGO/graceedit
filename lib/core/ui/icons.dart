import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

/// Jeu d'icônes de la V1 — 42 tracés SVG, grille de 24 dp, trait de 2 dp.
///
/// Source : `docs/graceedit/design/icones/` (copiés dans `assets/icons/`).
/// Les tracés utilisent `currentColor` ; [GraceIcon] les teinte avec la
/// couleur du thème, comme le reste de l'interface.
abstract final class GraceIcons {
  static const String ajouter = 'assets/icons/ajouter.svg';
  static const String annuler = 'assets/icons/annuler.svg';
  static const String avertissement = 'assets/icons/avertissement.svg';
  static const String chevronBas = 'assets/icons/chevron_bas.svg';
  static const String chevronDroite = 'assets/icons/chevron_droite.svg';
  static const String chevronGauche = 'assets/icons/chevron_gauche.svg';
  static const String coche = 'assets/icons/coche.svg';
  static const String crayon = 'assets/icons/crayon.svg';
  static const String deuxColonnes = 'assets/icons/deux_colonnes.svg';
  static const String dupliquer = 'assets/icons/dupliquer.svg';
  static const String entree = 'assets/icons/entree.svg';
  static const String exporter = 'assets/icons/exporter.svg';
  static const String fermer = 'assets/icons/fermer.svg';
  static const String flecheRetour = 'assets/icons/fleche_retour.svg';
  static const String fondu = 'assets/icons/fondu.svg';
  static const String home = 'assets/icons/home.svg';
  static const String image = 'assets/icons/image.svg';
  static const String information = 'assets/icons/information.svg';
  static const String lecture = 'assets/icons/lecture.svg';
  static const String liste = 'assets/icons/liste.svg';
  static const String miroir = 'assets/icons/miroir.svg';
  static const String modifier = 'assets/icons/modifier.svg';
  static const String musique = 'assets/icons/musique.svg';
  static const String palette = 'assets/icons/palette.svg';
  static const String partager = 'assets/icons/partager.svg';
  static const String pivoter = 'assets/icons/pivoter.svg';
  static const String plusHorizontal = 'assets/icons/plus_horizontal.svg';
  static const String plusVertical = 'assets/icons/plus_vertical.svg';
  static const String poigneeDeplacer = 'assets/icons/poignee_deplacer.svg';
  static const String projetsGrille = 'assets/icons/projets_grille.svg';
  static const String recadrer = 'assets/icons/recadrer.svg';
  static const String recherche = 'assets/icons/recherche.svg';
  static const String reglagesCurseurs = 'assets/icons/reglages_curseurs.svg';
  static const String restaurer = 'assets/icons/restaurer.svg';
  static const String retablir = 'assets/icons/retablir.svg';
  static const String scinder = 'assets/icons/scinder.svg';
  static const String selectionCercle = 'assets/icons/selection_cercle.svg';
  static const String styleTexte = 'assets/icons/style_texte.svg';
  static const String supprimer = 'assets/icons/supprimer.svg';
  static const String texte = 'assets/icons/texte.svg';
  static const String volume = 'assets/icons/volume.svg';
  static const String volumeCoupe = 'assets/icons/volume_coupe.svg';
}

/// Affiche une icône du jeu GraceEdit, teintée avec la couleur courante.
///
/// L'icône est purement décorative : le libellé accessible est porté par le
/// contrôle qui l'entoure ([Semantics] / `IconButton`), jamais par l'image.
class GraceIcon extends StatelessWidget {
  const GraceIcon(this.asset, {super.key, this.size = 24, this.color});

  final String asset;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.grace.text;
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      excludeFromSemantics: true,
    );
  }
}
