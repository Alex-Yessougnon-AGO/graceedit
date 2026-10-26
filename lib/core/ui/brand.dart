import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Symbole GraceEdit : anneau ouvert, barre horizontale et bloc d'accent.
class GraceMark extends StatelessWidget {
  const GraceMark({
    super.key,
    this.size = 36,
    this.color,
    this.accentProgress = 1,
    this.semanticLabel,
  });

  final double size;
  final Color? color;

  /// Position du bloc d'accent (0 → 8 dp à gauche, 1 → position finale).
  final double accentProgress;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.grace;
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      child: CustomPaint(
        size: Size.square(size),
        painter: _GraceMarkPainter(
          ink: color ?? palette.text,
          accent: GraceColors.accent,
          accentProgress: accentProgress,
        ),
      ),
    );
  }
}

class _GraceMarkPainter extends CustomPainter {
  _GraceMarkPainter({
    required this.ink,
    required this.accent,
    required this.accentProgress,
  });

  final Color ink;
  final Color accent;
  final double accentProgress;

  @override
  void paint(Canvas canvas, Size size) {
    // Tracé exact du symbole fourni : `design/logo/graceedit-symbole.svg`,
    // viewBox 120 × 120. On travaille dans ce repère puis on met à l'échelle.
    // Le dessin occupe la zone 12…108 ; le widget mesure donc 120 dp pour un
    // symbole de 96 dp de large, comme sur les maquettes.
    final scale = size.shortestSide / 120.0;
    canvas.save();
    canvas.scale(scale);

    // Anneau ouvert en haut à droite (trou du G).
    final ring = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.butt;
    final start = math.atan2(28.9 - 60, 81.8 - 60);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(60, 60), radius: 38),
      start,
      -(math.pi * 2 + start),
      false,
      ring,
    );

    // Barre horizontale de la lettre, extrémité droite légèrement biseautée.
    final bar = Path()
      ..moveTo(88, 54)
      ..lineTo(107.6, 54)
      ..lineTo(108, 60)
      ..lineTo(88, 60)
      ..close();
    canvas.drawPath(bar, Paint()..color = ink);

    // Bloc d'accent : glisse de 8 dp vers sa position finale au lancement.
    final dx = 8 * (1 - accentProgress);
    canvas.drawRect(
      Rect.fromLTWH(62 - dx, 54, 20, 16),
      Paint()..color = accent,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GraceMarkPainter old) =>
      old.ink != ink ||
      old.accent != accent ||
      old.accentProgress != accentProgress;
}

class GraceBrand extends StatelessWidget {
  const GraceBrand({super.key, this.markSize = 32, this.textSize = 15});

  final double markSize;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    final palette = context.grace;
    final title = AppLocalizations.of(context).appTitle;
    return Semantics(
      label: title,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GraceMark(size: markSize),
          const SizedBox(width: 10),
          // `Flexible` : avec une police à 200 %, le nom ne doit jamais
          // pousser le symbole hors de la largeur disponible.
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: GraceType.family,
                fontSize: textSize,
                height: 1.2,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: palette.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
