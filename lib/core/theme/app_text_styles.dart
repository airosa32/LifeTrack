import 'package:flutter/material.dart';

/// Estilos de texto derivados do ColorScheme corrente.
/// Nunca usar TextStyle "solto" nas telas — sempre a partir daqui
/// ou de Theme.of(context).textTheme.
class AppTextStyles {
  AppTextStyles._();

  static TextTheme textTheme(ColorScheme scheme) {
    final base = ThemeData(colorScheme: scheme).textTheme;
    return base.copyWith(
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.4),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
