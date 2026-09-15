import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';

/// Anima a transição entre um valor monetário e outro (efeito "contador"),
/// em vez de trocar o número de uma vez — dá uma sensação viva ao saldo
/// mudando na Dashboard/Finanças sempre que uma transação é criada.
class AnimatedCurrencyText extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCurrencyText({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(Formatters.currency(animatedValue), style: style);
      },
    );
  }
}
