import 'package:flutter/material.dart';

import 'pressable_scale.dart';

/// Card com sombra suave e cantos bem arredondados — visual mais próximo
/// de apps nativos da Apple do que o Card padrão do Material (que usa
/// borda + elevação chapada). A sombra é discreta e some no modo escuro,
/// onde optamos por um contorno sutil no lugar.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const radius = 20.0;

    final decoratedChild = Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius),
        border: isDark
            ? Border.all(color: scheme.outlineVariant.withOpacity(0.3))
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: scheme.shadow.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return decoratedChild;

    return PressableScale(
      onTap: onTap,
      scaleWhenPressed: 0.98,
      child: decoratedChild,
    );
  }
}
