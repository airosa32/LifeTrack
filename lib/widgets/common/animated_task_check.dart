import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

/// Substitui o Checkbox padrão do Material por um círculo que anima
/// preenchimento de cor + aparecimento do check — o mesmo padrão visual
/// do app Lembretes do iOS, bem mais expressivo que um checkbox quadrado.
class AnimatedTaskCheck extends StatelessWidget {
  final bool checked;
  final Color color;
  final VoidCallback onTap;

  const AnimatedTaskCheck({
    super.key,
    required this.checked,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: checked ? color : Colors.transparent,
            border: Border.all(color: checked ? color : scheme.outline, width: 2),
          ),
          child: AnimatedScale(
            scale: checked ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: const Icon(CupertinoIcons.checkmark_alt, size: 15, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
