import 'package:flutter/material.dart';

/// Valeurs de design de la V1 — source : docs/graceedit/design/tokens.json.
/// Toute valeur visuelle de l'application vient d'ici.
abstract final class GraceColors {
  /// Couleurs de marque, communes aux deux thèmes.
  static const ink = Color(0xFF14151A);
  static const ivory = Color(0xFFF6F2EA);
  static const accent = Color(0xFFE2542B);
  static const preview = Color(0xFF0B0B0D);

  /// Palette sémantique du thème clair.
  static const lightBackground = Color(0xFFF6F2EA);
  static const lightText = Color(0xFF14151A);
  static const lightSecondary = Color(0xFF5E5C58);
  static const lightSurface = Color(0xFFE4DED2);
  static const lightNav = Color(0xFFEDE7DB);
  static const lightActive = Color(0xFFD9D2C3);
  static const lightOutline = Color(0xFF9A968D);
  static const lightError = Color(0xFFB3261E);

  /// Palette sémantique du thème sombre, dessinée séparément.
  static const darkBackground = Color(0xFF14151A);
  static const darkText = Color(0xFFF6F2EA);
  static const darkSecondary = Color(0xFFB9B5AD);
  static const darkSurface = Color(0xFF2A2C33);
  static const darkNav = Color(0xFF1D1F25);
  static const darkActive = Color(0xFF3A3C45);
  static const darkOutline = Color(0xFF6B6D75);
  static const darkError = Color(0xFFF2B8B5);

  static const scrim = Color(0x73000000);
}

@immutable
class GracePalette extends ThemeExtension<GracePalette> {
  const GracePalette({
    required this.brightness,
    required this.background,
    required this.text,
    required this.secondary,
    required this.surface,
    required this.button,
    required this.onButton,
    required this.nav,
    required this.active,
    required this.outline,
    required this.error,
  });

  final Brightness brightness;
  final Color background;
  final Color text;
  final Color secondary;
  final Color surface;
  final Color button;
  final Color onButton;
  final Color nav;
  final Color active;
  final Color outline;
  final Color error;

  static const light = GracePalette(
    brightness: Brightness.light,
    background: GraceColors.lightBackground,
    text: GraceColors.lightText,
    secondary: GraceColors.lightSecondary,
    surface: GraceColors.lightSurface,
    button: GraceColors.ink,
    onButton: GraceColors.ivory,
    nav: GraceColors.lightNav,
    active: GraceColors.lightActive,
    outline: GraceColors.lightOutline,
    error: GraceColors.lightError,
  );

  static const dark = GracePalette(
    brightness: Brightness.dark,
    background: GraceColors.darkBackground,
    text: GraceColors.darkText,
    secondary: GraceColors.darkSecondary,
    surface: GraceColors.darkSurface,
    button: GraceColors.ivory,
    onButton: GraceColors.ink,
    nav: GraceColors.darkNav,
    active: GraceColors.darkActive,
    outline: GraceColors.darkOutline,
    error: GraceColors.darkError,
  );

  bool get isDark => brightness == Brightness.dark;

  Color get accent => GraceColors.accent;

  @override
  GracePalette copyWith() => this;

  @override
  GracePalette lerp(ThemeExtension<GracePalette>? other, double t) {
    if (other is! GracePalette) return this;
    return t < 0.5 ? this : other;
  }
}

/// Dimensions en dp, écran de référence 360 × 800.
abstract final class GraceDims {
  static const touch = 48.0;
  static const topBar = 56.0;
  static const navBar = 80.0;
  static const primaryButton = 56.0;
  static const outlineButton = 48.0;
  static const dialogButton = 52.0;
  static const chip = 40.0;
  static const side = 24.0;
  static const icon = 24.0;

  static const projectRow = 80.0;
  static const thumbListW = 96.0;
  static const thumbListH = 54.0;
  static const gridCardW = 152.0;
  static const gridThumbH = 86.0;

  static const preview = 260.0;
  static const playLine = 48.0;
  static const ruler = 22.0;
  static const videoTrack = 72.0;
  static const subTrack = 40.0;
  static const playheadLine = 2.0;
  static const playheadHead = 10.0;
  static const toolbar = 80.0;
  static const trimHandle = 14.0;
  static const trimHandleActive = 18.0;

  static const sheetWidth = 312.0;
  static const toast = 48.0;
}

abstract final class GraceRadius {
  static const thumb = 8.0;
  static const small = 12.0;
  static const card = 16.0;
  static const chip = 20.0;
  static const button = 28.0;
  static const sheet = 28.0;
}

abstract final class GraceSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class GraceMotion {
  static const fade = Duration(milliseconds: 200);
  static const splashSlide = Duration(milliseconds: 400);
  static const toast = Duration(seconds: 4);
  static const toastLong = Duration(seconds: 6);
  static const undo = Duration(seconds: 6);
}
