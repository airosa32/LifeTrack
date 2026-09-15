class AppConstants {
  AppConstants._();

  static const String appName = 'LifeTrack';
  static const String appSlogan =
      'Organize sua rotina. Controle seu dinheiro. Tenha clareza do seu dia.';

  // Limites de nível de alerta (percentual sobre o limite configurado).
  static const double attentionThreshold = 80; // 80% - 99% = atenção
  static const double criticalThreshold = 100; // 100%+ = crítico

  // Chaves de SharedPreferences
  static const String prefThemePalette = 'pref_theme_palette';
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefUseCustomAvailableBalance =
      'pref_use_custom_available_balance';
  static const String prefCustomReserve = 'pref_custom_reserve';
}
