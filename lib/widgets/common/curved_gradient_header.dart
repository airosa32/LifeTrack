import 'package:flutter/material.dart';

import 'wave_header_clipper.dart';

/// Header colorido em largura total (sem margens, sem sombra, sem
/// cantos arredondados) — "pertence ao fundo" da tela em vez de flutuar
/// como um card. A curva da base anima continuamente (respiração sutil),
/// dando vida ao elemento mesmo sem nenhuma interação do usuário.
class CurvedGradientHeader extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;

  const CurvedGradientHeader({super.key, required this.child, this.colors});

  @override
  State<CurvedGradientHeader> createState() => _CurvedGradientHeaderState();
}

class _CurvedGradientHeaderState extends State<CurvedGradientHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat(reverse: true);

  late final Animation<double> _dip = Tween<double>(begin: 10, end: 30).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = widget.colors ?? [scheme.primary, scheme.secondary];

    return AnimatedBuilder(
      animation: _dip,
      builder: (context, child) {
        return ClipPath(
          clipper: WaveHeaderClipper(dip: _dip.value),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
