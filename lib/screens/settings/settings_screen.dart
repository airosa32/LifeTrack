import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/common/app_card.dart';
import '../../widgets/common/icon_badge.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            onTap: () => context.push('/settings/profile'),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: scheme.primary,
                  child: Text(
                    'T',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tiago', style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        'Ver perfil',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(CupertinoIcons.chevron_right, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _GroupLabel('PREFERÊNCIAS'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: CupertinoIcons.paintbrush_fill,
                  color: const Color(0xFF5B3A9C),
                  title: 'Aparência',
                  subtitle: 'Tema, paleta de cores e modo escuro',
                  onTap: () => context.push('/settings/appearance'),
                ),
                const Divider(height: 1, indent: 68),
                _SettingsTile(
                  icon: CupertinoIcons.tag_fill,
                  color: const Color(0xFFE0A32E),
                  title: 'Categorias',
                  subtitle: 'Gerenciar categorias de entrada e saída',
                  onTap: () => context.push('/settings/categories'),
                ),
                const Divider(height: 1, indent: 68),
                _SettingsTile(
                  icon: CupertinoIcons.bell_fill,
                  color: const Color(0xFFD64545),
                  title: 'Alertas',
                  subtitle: 'Regras de alertas financeiros',
                  onTap: () => context.push('/settings/alerts'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _GroupLabel('SOBRE'),
          AppCard(
            padding: EdgeInsets.zero,
            child: _SettingsTile(
              icon: CupertinoIcons.info_circle_fill,
              color: const Color(0xFF0F4C81),
              title: 'Sobre o aplicativo',
              subtitle: 'LifeTrack v0.1.0',
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;
  const _GroupLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconBadge(icon: icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(CupertinoIcons.chevron_right, size: 18) : null,
      onTap: onTap,
    );
  }
}
