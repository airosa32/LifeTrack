import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const LifeTrackApp(),
    ),
  );
}

class LifeTrackApp extends ConsumerWidget {
  const LifeTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(paletteProvider);
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'LifeTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(palette),
      darkTheme: AppTheme.dark(palette),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
