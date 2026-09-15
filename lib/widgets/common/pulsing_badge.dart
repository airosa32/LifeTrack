import 'package:flutter/material.dart';

/// Pulsação contínua e sutil (escala 1.0 → 1.15 → 1.0 em loop) — usada
/// no badge do sino de alertas para chamar atenção discretamente quando
/// há algo novo, sem depender de uma interação do usuário.
class PulsingBadge extends StatefulWidget {
  final Widget child;
  final bool active;

  const PulsingBadge({super.key, required this.child, required this.active});

  @override
  State<PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<PulsingBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1 + (_controller.value * 0.15);
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}
