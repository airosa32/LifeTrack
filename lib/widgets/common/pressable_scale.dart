import 'package:flutter/material.dart';

/// Envolve qualquer widget tocável e aplica um leve "encolhimento" ao
/// pressionar, voltando ao tamanho normal ao soltar — a mesma sensação
/// tátil dos botões e cards nativos do iOS (em vez do ripple padrão do
/// Material, que não combina com o resto do visual do app).
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleWhenPressed;

  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleWhenPressed = 0.96,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scaleWhenPressed : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
