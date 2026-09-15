import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/category_icons.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/icon_badge.dart';

/// Perfil do usuário — nome e cor do avatar são editáveis e persistem
/// localmente. Autenticação real e upload de foto de verdade ficam fora
/// do escopo do MVP (ver item 64 do briefing): trocar a "foto" aqui
/// significa escolher uma cor de destaque para o avatar, sem depender
/// de permissões de câmera/galeria que exigiriam configuração nativa
/// (AndroidManifest/Info.plist) fora do que dá pra ajustar só em `lib/`.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _nameController;
  bool _editingName = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: ref.read(profileProvider).name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() {
    ref.read(profileProvider.notifier).setName(_nameController.text);
    setState(() => _editingName = false);
  }

  Future<void> _pickAvatarColor() async {
    final current = ref.read(profileProvider).avatarColorValue;
    final selected = await showModalBottomSheet<Color>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cor do avatar', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: CategoryIconRegistry.colorPalette.map((color) {
                  final selectedNow = color.value == current;
                  return GestureDetector(
                    onTap: () => Navigator.of(context).pop(color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selectedNow
                            ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
                            : null,
                      ),
                      child: selectedNow
                          ? const Icon(CupertinoIcons.checkmark, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      ref.read(profileProvider.notifier).setAvatarColor(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAvatarColor,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: profile.avatarColor,
                        child: Text(
                          profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: scheme.surfaceContainerLow, width: 2),
                          ),
                          child: const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Toque no avatar para trocar a cor',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                if (_editingName)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(isDense: true),
                          onSubmitted: (_) => _saveName(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.checkmark_circle_fill),
                        onPressed: _saveName,
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: () => setState(() => _editingName = true),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(profile.name, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(width: 6),
                        Icon(CupertinoIcons.pencil, size: 16, color: scheme.onSurfaceVariant),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ProfileTile(
                  icon: CupertinoIcons.tag_fill,
                  color: const Color(0xFFE0A32E),
                  title: 'Categorias',
                  onTap: () => context.push('/settings/categories'),
                ),
                const Divider(height: 1, indent: 68),
                _ProfileTile(
                  icon: CupertinoIcons.bell_fill,
                  color: const Color(0xFFD64545),
                  title: 'Alertas',
                  onTap: () => context.push('/settings/alerts'),
                ),
                const Divider(height: 1, indent: 68),
                _ProfileTile(
                  icon: CupertinoIcons.paintbrush_fill,
                  color: const Color(0xFF5B3A9C),
                  title: 'Aparência',
                  onTap: () => context.push('/settings/appearance'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'LifeTrack v0.1.0',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconBadge(icon: icon, color: color),
      title: Text(title),
      trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}
