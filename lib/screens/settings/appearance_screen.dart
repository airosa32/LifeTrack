import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/section_title.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPalette = ref.watch(paletteProvider);
    final currentMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Aparência')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle(title: 'Escolha seu tema'),
          ...AppPalette.values.map((palette) {
            final selected = palette == currentPalette;
            final previewScheme = buildColorScheme(palette, Theme.of(context).brightness);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                onTap: () => ref.read(paletteProvider.notifier).setPalette(palette),
                child: Row(
                  children: [
                    Row(
                      children: [
                        _Swatch(color: previewScheme.primary),
                        const SizedBox(width: 4),
                        _Swatch(color: previewScheme.secondary),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(palette.label, style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            palette.description,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Radio<AppPalette>(
                      value: palette,
                      groupValue: currentPalette,
                      onChanged: (value) {
                        if (value != null) ref.read(paletteProvider.notifier).setPalette(value);
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Modo de exibição'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Claro'),
                  value: ThemeMode.light,
                  groupValue: currentMode,
                  onChanged: (value) => value != null
                      ? ref.read(themeModeProvider.notifier).setThemeMode(value)
                      : null,
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Escuro'),
                  value: ThemeMode.dark,
                  groupValue: currentMode,
                  onChanged: (value) => value != null
                      ? ref.read(themeModeProvider.notifier).setThemeMode(value)
                      : null,
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Sistema'),
                  value: ThemeMode.system,
                  groupValue: currentMode,
                  onChanged: (value) => value != null
                      ? ref.read(themeModeProvider.notifier).setThemeMode(value)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  const _Swatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
