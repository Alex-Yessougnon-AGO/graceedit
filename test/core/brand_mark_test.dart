import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graceedit/core/theme/app_theme.dart';
import 'package:graceedit/core/theme/tokens.dart';
import 'package:graceedit/core/ui/brand.dart';

/// Vérification pixel du symbole : c'est lui qui donne l'échelle de tout le
/// reste de l'interface (maquettes 1080 × 2400 px à 3x).
///
/// Géométrie de référence (`design/logo/graceedit-symbole.svg`, viewBox 120) :
/// encre de 12 à 108, bloc d'accent de (62, 54) à (82, 70).
void main() {
  const pixelRatio = 3.0;

  /// Rend `mark` à 3x et renvoie l'image et ses octets RGBA.
  Future<({ui.Image image, ByteData data})> render(
    WidgetTester tester,
    Widget mark, {
    Brightness brightness = Brightness.light,
  }) async {
    const key = Key('mark');
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGraceTheme(brightness),
        // Fond opaque : sans lui l'image rendue est transparente et les bords
        // anti-aliasés faussent la mesure de la boîte englobante.
        home: ColoredBox(
          color: brightness == Brightness.light
              ? GraceColors.ivory
              : GraceColors.ink,
          child: Center(
            child: RepaintBoundary(key: key, child: mark),
          ),
        ),
      ),
    );
    await tester.pump();

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    final image = (await tester.runAsync(
      () => boundary.toImage(pixelRatio: pixelRatio),
    ))!;
    final data = (await tester.runAsync(
      () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
    ))!;
    return (image: image, data: data);
  }

  testWidgets('le symbole dessine 96 dp d’encre dans un carré de 120 dp', (
    tester,
  ) async {
    final rendered = await render(tester, const GraceMark(size: 120));
    final image = rendered.image;
    final data = rendered.data;

    ({int r, int g, int b, int a}) at(int x, int y) {
      final i = (y * image.width + x) * 4;
      return (
        r: data.getUint8(i),
        g: data.getUint8(i + 1),
        b: data.getUint8(i + 2),
        a: data.getUint8(i + 3),
      );
    }

    /// Un pixel appartient au dessin dès qu'il est couvert à moitié : c'est la
    /// frontière que perçoit l'œil, et elle ignore l'anti-aliasing du bord.
    /// Le RepaintBoundary n'a pas de fond : l'alpha mesure la couverture.
    bool covered(int x, int y) => at(x, y).a >= 128;

    bool isAccent(int x, int y) {
      final c = at(x, y);
      return c.a == 255 && c.r == 0xE2 && c.g == 0x54 && c.b == 0x2B;
    }

    var minX = image.width, maxX = -1, minY = image.height, maxY = -1;
    var accentMinX = image.width, accentMaxX = -1;
    var accentMinY = image.height, accentMaxY = -1;

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        if (covered(x, y)) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
        if (isAccent(x, y)) {
          if (x < accentMinX) accentMinX = x;
          if (x > accentMaxX) accentMaxX = x;
          if (y < accentMinY) accentMinY = y;
          if (y > accentMaxY) accentMaxY = y;
        }
      }
    }

    // Encre : 96 dp de large et de haut (288 px à 3x), centrée dans le carré.
    expect(minX, 36);
    expect(maxX, 323);
    expect(minY, 36);
    expect(maxY, 323);
    expect(maxX - minX + 1, 288);
    expect(maxY - minY + 1, 288);

    // Bloc d'accent : 20 × 16 dp, à 2 dp du bord droit de l'encre.
    expect(accentMinX, 186);
    expect(accentMaxX, 245);
    expect(accentMinY, 162);
    expect(accentMaxY, 209);
  });

  testWidgets('les couleurs du symbole suivent les jetons', (tester) async {
    final rendered = await render(
      tester,
      const GraceMark(size: 120),
      brightness: Brightness.dark,
    );
    final image = rendered.image;
    final data = rendered.data;

    /// Lit un point exprimé en dp du widget (l'image est à 3x).
    ({int r, int g, int b, int a}) atDp(double x, double y) {
      final px = (x * pixelRatio).round();
      final py = (y * pixelRatio).round();
      final i = (py * image.width + px) * 4;
      return (
        r: data.getUint8(i),
        g: data.getUint8(i + 1),
        b: data.getUint8(i + 2),
        a: data.getUint8(i + 3),
      );
    }

    int channel(double value) => (value * 255).round();

    // Un point plein de l'anneau (à gauche du centre) et le bloc d'accent.
    final ring = atDp(30, 60);
    final accent = atDp(72, 62);

    expect(ring.a, 255);
    expect(ring.r, channel(GraceColors.ivory.r));
    expect(ring.g, channel(GraceColors.ivory.g));
    expect(ring.b, channel(GraceColors.ivory.b));

    expect(accent.a, 255);
    expect(accent.r, channel(GraceColors.accent.r));
    expect(accent.g, channel(GraceColors.accent.g));
    expect(accent.b, channel(GraceColors.accent.b));
  });
}
