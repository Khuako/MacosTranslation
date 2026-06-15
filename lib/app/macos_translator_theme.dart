import 'package:flutter/material.dart';

class MacTranslatorKit {
  const MacTranslatorKit._();

  static const graphite = Color(0xFF5F625D);
  static const graphitePressed = Color(0xFF4D504B);
  static const ink = Color(0xE6171717);
  static const secondaryInk = Color(0x99171717);
  static const mutedInk = Color(0x70171717);
  static const error = Color(0xFF9A3A32);

  static const glassSurface = Color(0xBBF4F2EC);
  static const glassSurfaceSoft = Color(0x8FEFEDE7);
  static const glassSurfaceBarely = Color(0x5FEDEBE4);
  static const glassEdge = Color(0xD9FFFFFF);
  static const glassEdgeMuted = Color(0x8AFFFFFF);
  static const glassInset = Color(0x1AFFFFFF);
  static const hairline = Color(0x24000000);

  static const radiusWindow = 22.0;
  static const radiusControl = 13.0;
  static const radiusField = 15.0;

  static ThemeData theme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: graphite,
      brightness: Brightness.light,
      primary: graphite,
      onPrimary: Colors.white,
      surface: glassSurface,
      onSurface: ink,
      error: error,
    );

    return ThemeData(
      colorScheme: scheme,
      fontFamily: '.AppleSystemUIFont',
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xF7F4F2EC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          side: const BorderSide(color: glassEdgeMuted, width: 0.8),
        ),
        textStyle: const TextStyle(
          color: ink,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: graphite,
          highlightColor: graphite.withValues(alpha: 0.10),
          hoverColor: graphite.withValues(alpha: 0.08),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: graphite,
      ),
    );
  }
}
