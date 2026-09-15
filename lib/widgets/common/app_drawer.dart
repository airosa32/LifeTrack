import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/theme_provider.dart';

/// Menu lateral simplificado — só o essencial que não cabe na navegação
/// principal (que já fica na barra inferior): preferências de tema e
/// acesso ao perfil. Visual propositalmente escuro e fixo, independente
/// do tema claro/escuro do resto do app.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  static const _bg = Color(0xFF17171F);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    void push(String path) {
      Navigator.of(context).pop();
      context.push(path);
    }

    return Drawer(
      backgroundColor: _bg,
      width: 280,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DrawerLabel('PREFERÊNCIAS'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.moon, color: Colors.white70, size: 20),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('Modo escuro', style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                  Switch(
                    value: isDarkMode,
                    onChanged: (value) => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 24, indent: 20, endIndent: 20),
            _DrawerItem(
              icon: CupertinoIcons.person,
              label: 'Meu perfil',
              onTap: () => push('/settings/profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerLabel extends StatelessWidget {
  final String text;
  const _DrawerLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white70, size: 20),
                const SizedBox(width: 16),
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const Spacer(),
                const Icon(CupertinoIcons.chevron_right, color: Colors.white38, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
