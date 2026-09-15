import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Deve ser sobrescrito em main.dart antes do runApp.');
});

class PaletteNotifier extends Notifier<AppPalette> {
  @override
  AppPalette build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(AppConstants.prefThemePalette);
    return AppPalette.values.firstWhere(
      (p) => p.name == saved,
      orElse: () => AppPalette.ocean,
    );
  }

  void setPalette(AppPalette palette) {
    state = palette;
    ref.read(sharedPreferencesProvider).setString(
          AppConstants.prefThemePalette,
          palette.name,
        );
  }
}

final paletteProvider = NotifierProvider<PaletteNotifier, AppPalette>(
  PaletteNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(AppConstants.prefThemeMode);
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    ref.read(sharedPreferencesProvider).setString(
          AppConstants.prefThemeMode,
          mode.name,
        );
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
