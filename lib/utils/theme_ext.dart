import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart'
    show Color, ColorScheme, Brightness;

extension ColorSchemeExt on ColorScheme {
  bool get isLight => brightness == Brightness.light;

  bool get isDark => brightness == Brightness.dark;

  Color get freeColor =>
      isLight ? const Color(0xFFFF7F24) : const Color(0xFFD66011);
}

/// Builds an M3 [ColorScheme] seeded from [seedColor].
ColorScheme colorSchemeFromSeed(
  Color seedColor, {
  FlexSchemeVariant variant = .material,
  Brightness brightness = .light,
}) =>
    SeedColorScheme.fromSeeds(
      primaryKey: seedColor,
      variant: variant,
      brightness: brightness,
      useExpressiveOnContainerColors: false,
    );
