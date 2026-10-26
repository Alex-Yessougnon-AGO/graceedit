import 'package:flutter/material.dart';

import 'tokens.dart';

/// Échelle typographique de la V1 (Inter).
abstract final class GraceType {
  static const family = 'Inter';

  static const display = TextStyle(
    fontFamily: family,
    fontSize: 34,
    height: 40 / 34,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );
  static const screenTitle = TextStyle(
    fontFamily: family,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );
  static const sheetTitle = TextStyle(
    fontFamily: family,
    fontSize: 22,
    height: 26 / 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
  static const barTitle = TextStyle(
    fontFamily: family,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
  static const subtitle = TextStyle(
    fontFamily: family,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );
  static const body = TextStyle(
    fontFamily: family,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: -0.1,
  );
  static const bodyMedium = TextStyle(
    fontFamily: family,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
  );
  static const bodyBold = TextStyle(
    fontFamily: family,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
  );
  static const bodyCompact = TextStyle(
    fontFamily: family,
    fontSize: 15,
    height: 22 / 15,
    letterSpacing: -0.1,
  );
  static const secondary = TextStyle(
    fontFamily: family,
    fontSize: 14,
    height: 20 / 14,
  );
  static const secondaryMedium = TextStyle(
    fontFamily: family,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
  );
  static const caption = TextStyle(
    fontFamily: family,
    fontSize: 13,
    height: 18 / 13,
  );
  static const small = TextStyle(
    fontFamily: family,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: -0.1,
  );
  static const tab = TextStyle(
    fontFamily: family,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
  );
  static const timecode = TextStyle(
    fontFamily: family,
    fontSize: 13,
    height: 18 / 13,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const timecodeSmall = TextStyle(
    fontFamily: family,
    fontSize: 11,
    height: 14 / 11,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

ThemeData buildGraceTheme(Brightness brightness) {
  final p = brightness == Brightness.light
      ? GracePalette.light
      : GracePalette.dark;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.button,
    onPrimary: p.onButton,
    secondary: p.text,
    onSecondary: p.background,
    error: p.error,
    onError: p.background,
    surface: p.background,
    onSurface: p.text,
    surfaceContainerHighest: p.surface,
    onSurfaceVariant: p.secondary,
    outline: p.outline,
    scrim: GraceColors.scrim,
  );

  final base = ThemeData(
    brightness: brightness,
    useMaterial3: true,
    fontFamily: GraceType.family,
    scaffoldBackgroundColor: p.background,
    canvasColor: p.background,
    colorScheme: scheme,
    splashFactory: NoSplash.splashFactory,
    shadowColor: Colors.transparent,
    highlightColor: Colors.transparent,
  );

  final textTheme = base.textTheme
      .copyWith(
        displayLarge: GraceType.display,
        headlineMedium: GraceType.screenTitle,
        headlineSmall: GraceType.sheetTitle,
        titleLarge: GraceType.barTitle,
        titleMedium: GraceType.subtitle,
        bodyLarge: GraceType.body,
        bodyMedium: GraceType.bodyCompact,
        bodySmall: GraceType.secondary,
        labelLarge: GraceType.bodyMedium,
        labelMedium: GraceType.caption,
        labelSmall: GraceType.small,
      )
      .apply(bodyColor: p.text, displayColor: p.text);

  return base.copyWith(
    textTheme: textTheme,
    extensions: [p],
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: p.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: GraceDims.topBar,
      centerTitle: false,
      titleTextStyle: GraceType.barTitle.copyWith(color: p.text),
    ),
    iconTheme: IconThemeData(color: p.text, size: GraceDims.icon),
    dividerTheme: DividerThemeData(color: p.surface, thickness: 1, space: 1),
    dialogTheme: DialogThemeData(
      backgroundColor: p.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GraceRadius.sheet),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.nav,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      showDragHandle: false,
      modalBarrierColor: GraceColors.scrim,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GraceRadius.sheet),
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? p.onButton : p.text,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? p.button : p.surface,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? p.button : p.outline,
      ),
      thumbIcon: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Icon(Icons.check, size: 16, color: p.button)
            : null,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: p.text,
      inactiveTrackColor: p.active,
      thumbColor: p.text,
      overlayColor: Colors.transparent,
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: SliderComponentShape.noOverlay,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.text,
      contentTextStyle: GraceType.secondary.copyWith(color: p.background),
      actionTextColor: p.background,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GraceRadius.thumb),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: GraceType.caption.copyWith(color: p.secondary),
      hintStyle: GraceType.body.copyWith(color: p.secondary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GraceRadius.small),
        borderSide: BorderSide(color: p.text, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GraceRadius.small),
        borderSide: BorderSide(color: p.text, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GraceRadius.small),
        borderSide: BorderSide(color: p.text, width: 1.5),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.text,
      selectionColor: p.active,
      selectionHandleColor: p.text,
    ),
  );
}

extension GraceThemeX on BuildContext {
  GracePalette get grace => Theme.of(this).extension<GracePalette>()!;
  TextTheme get texts => Theme.of(this).textTheme;
  bool get isDark => grace.isDark;
}
