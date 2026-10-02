/// GraceEdit design tokens — calm, premium, non-generic.
/// Dark + Light are designed separately, not inverted.
library;

import 'package:flutter/material.dart';

class GraceColors {
  const GraceColors({
    required this.background, required this.surface, required this.elevated,
    required this.textPrimary, required this.textSecondary, required this.border,
    required this.primary, required this.onPrimary,
    required this.success, required this.warning,
    required this.destructive, required this.info,
  });
  final Color background;
  final Color surface;
  final Color elevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color primary;
  final Color onPrimary;
  final Color success;
  final Color warning;
  final Color destructive;
  final Color info;

  static const light = GraceColors(
    background: Color(0xFFFAF8F4),
    surface: Color(0xFFFFFFFF),
    elevated: Color(0xFFF3EFE8),
    textPrimary: Color(0xFF1C1A17),
    textSecondary: Color(0xFF6E675E),
    border: Color(0xFFE5DFD5),
    primary: Color(0xFF2F5D3A),
    onPrimary: Color(0xFFFFFFFF),
    success: Color(0xFF2F7D4F),
    warning: Color(0xFFB7791F),
    destructive: Color(0xFFB3261E),
    info: Color(0xFF2B6CB0),
  );

  static const dark = GraceColors(
    background: Color(0xFF141210),
    surface: Color(0xFF1E1B18),
    elevated: Color(0xFF2A2521),
    textPrimary: Color(0xFFF5F1EA),
    textSecondary: Color(0xFFA8A094),
    border: Color(0xFF38322C),
    primary: Color(0xFF8FBC8F),
    onPrimary: Color(0xFF142114),
    success: Color(0xFF7FBF8E),
    warning: Color(0xFFD9A441),
    destructive: Color(0xFFE57373),
    info: Color(0xFF7FB3E0),
  );
}

class GraceSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class GraceRadius {
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
}

ThemeData graceTheme(Brightness b) {
  final c = b == Brightness.dark ? GraceColors.dark : GraceColors.light;
  final scheme = ColorScheme(
    brightness: b,
    primary: c.primary, onPrimary: c.onPrimary,
    secondary: c.primary, onSecondary: c.onPrimary,
    surface: c.surface, onSurface: c.textPrimary,
    error: c.destructive, onError: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.background,
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      foregroundColor: c.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GraceRadius.m),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GraceRadius.m),
        borderSide: BorderSide(color: c.border),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

extension GraceThemeX on BuildContext {
  GraceColors get grace =>
      Theme.of(this).brightness == Brightness.dark ? GraceColors.dark : GraceColors.light;
}
