import 'package:flutter/material.dart';

/// LinearProgressIndicator não anima sozinho quando o `value` muda de
/// um número pra outro — ele simplesmente "pula". Este wrapper anima
/// a transição suavemente, dando uma sensação viva às barras de
/// progresso de tarefas e de uso de limite dos alertas.
class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final double minHeight;
  final Color? backgroundColor;
  final Color? valueColor;
  final Duration duration;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.minHeight = 8,
    this.backgroundColor,
    this.valueColor,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(minHeight),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1)),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, child) {
          return LinearProgressIndicator(
            value: animatedValue,
            minHeight: minHeight,
            backgroundColor: backgroundColor,
            valueColor: valueColor != null ? AlwaysStoppedAnimation(valueColor) : null,
          );
        },
      ),
    );
  }
}
