import 'package:flutter/material.dart'
    show Color, ColorScheme, Brightness;

extension ColorSchemeExt on ColorScheme {
  bool get isLight => brightness == Brightness.light;

  bool get isDark => brightness == Brightness.dark;

  Color get freeColor =>
      isLight ? const Color(0xFFFF7F24) : const Color(0xFFD66011);
}
