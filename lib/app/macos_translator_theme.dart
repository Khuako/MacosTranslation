import 'package:flutter/material.dart';

class MacTranslatorKit {
  const MacTranslatorKit._();

  static const graphite = Color(0xFFE8EAED);
  static const graphitePressed = Color(0xFFCBD2DC);
  static const accent = Color(0xFFE8EAED);
  static const ink = Color(0xF2F4F7FA);
  static const secondaryInk = Color(0xBFD8DCE4);
  static const mutedInk = Color(0x8A9AA1AC);
  static const error = Color(0xFFFF8A80);

  static const glassSurface = Color(0xFF121418);
  static const glassSurfaceSoft = Color(0xFF191C22);
  static const glassSurfaceBarely = Color(0xFF20242B);
  static const glassEdge = Color(0xFF343A44);
  static const glassEdgeMuted = Color(0xFF262B33);
  static const glassInset = Color(0xFF1A1E24);
  static const glassInsetStrong = Color(0xFF222731);
  static const hairline = Color(0xFF343A44);
  static const focusRing = Color(0x2FE8EAED);

  static const radiusWindow = 20.0;
  static const radiusControl = 11.0;
  static const radiusField = 14.0;

  static ThemeData theme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: graphite,
      brightness: Brightness.dark,
      primary: accent,
      onPrimary: const Color(0xFF08111F),
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
        color: glassSurfaceSoft,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: const Color(0x66000000),
        menuPadding: const EdgeInsets.all(6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          side: const BorderSide(color: hairline, width: 0.8),
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
          hoverColor: graphite.withValues(alpha: 0.07),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accent,
      ),
    );
  }
}
