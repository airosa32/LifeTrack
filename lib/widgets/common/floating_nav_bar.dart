import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import 'pressable_scale.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabTap,
  });

  static const _items = [
    (icon: CupertinoIcons.house, selectedIcon: CupertinoIcons.house_fill, label: 'Início'),
    (icon: CupertinoIcons.checkmark_circle, selectedIcon: CupertinoIcons.checkmark_circle_fill, label: 'Tarefas'),
    (icon: CupertinoIcons.creditcard, selectedIcon: CupertinoIcons.creditcard_fill, label: 'Finanças'),
    (icon: CupertinoIcons.chart_pie, selectedIcon: CupertinoIcons.chart_pie_fill, label: 'Relatórios'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.paddingOf(context).bottom + 12),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(32),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: scheme.shadow.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavIcon(item: _items[0], selected: currentIndex == 0, onTap: () => onTap(0)),
                _NavIcon(item: _items[1], selected: currentIndex == 1, onTap: () => onTap(1)),
                const SizedBox(width: 48),
                _NavIcon(item: _items[2], selected: currentIndex == 2, onTap: () => onTap(2)),
                _NavIcon(item: _items[3], selected: currentIndex == 3, onTap: () => onTap(3)),
              ],
            ),
          ),
          Positioned(
            top: -22,
            child: PressableScale(
              onTap: onFabTap,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [scheme.primary, scheme.secondary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(CupertinoIcons.add, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

typedef _NavItem = ({IconData icon, IconData selectedIcon, String label});

class _NavIcon extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavIcon({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return PressableScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? item.selectedIcon : item.icon, color: color, size: 22),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 5 : 0,
              height: 5,
              decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }
}
