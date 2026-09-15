import 'package:flutter/material.dart';

enum AppPalette { ocean, emerald, purple, sunset, slate }

extension AppPaletteLabel on AppPalette {
  String get label {
    switch (this) {
      case AppPalette.ocean:
        return 'Ocean';
      case AppPalette.emerald:
        return 'Emerald';
      case AppPalette.purple:
        return 'Purple';
      case AppPalette.sunset:
        return 'Sunset';
      case AppPalette.slate:
        return 'Slate';
    }
  }

  String get description {
    switch (this) {
      case AppPalette.ocean:
        return 'Tecnologia, confiança, profissional';
      case AppPalette.emerald:
        return 'Financeiro, equilíbrio, crescimento';
      case AppPalette.purple:
        return 'Moderno, tecnológico, premium';
      case AppPalette.sunset:
        return 'Energia, produtividade';
      case AppPalette.slate:
        return 'Minimalista, profissional';
    }
  }
}

/// Cores fixas de status, iguais em qualquer paleta/tema —
/// usadas pelos alertas e indicadores de saldo.
class AppStatusColors {
  AppStatusColors._();

  static const Color normal = Color(0xFF2E9E5B);
  static const Color attention = Color(0xFFE0A32E);
  static const Color critical = Color(0xFFD64545);

  static const Color normalDark = Color(0xFF4ADE80);
  static const Color attentionDark = Color(0xFFFBBF24);
  static const Color criticalDark = Color(0xFFF87171);
}

class _PaletteSeed {
  final Color primary;
  final Color secondary;
  const _PaletteSeed(this.primary, this.secondary);
}

const Map<AppPalette, _PaletteSeed> _seeds = {
  AppPalette.ocean: _PaletteSeed(Color(0xFF0F4C81), Color(0xFF5DA9E9)),
  AppPalette.emerald: _PaletteSeed(Color(0xFF1B5E42), Color(0xFF5FBF8F)),
  AppPalette.purple: _PaletteSeed(Color(0xFF5B3A9C), Color(0xFFB79CED)),
  AppPalette.sunset: _PaletteSeed(Color(0xFFC1552C), Color(0xFFE8A657)),
  AppPalette.slate: _PaletteSeed(Color(0xFF3A3F47), Color(0xFF8A919B)),
};

ColorScheme buildColorScheme(AppPalette palette, Brightness brightness) {
  final seed = _seeds[palette]!;
  return ColorScheme.fromSeed(
    seedColor: seed.primary,
    brightness: brightness,
    secondary: seed.secondary,
  );
}
