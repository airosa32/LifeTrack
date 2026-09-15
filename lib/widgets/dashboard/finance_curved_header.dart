import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../common/animated_currency_text.dart';
import '../common/curved_gradient_header.dart';

/// Header colorido em largura total (sem card/sombra, onda animada na
/// base) mostrando saldo disponível + entradas/saídas. Usado tanto na
/// Dashboard quanto na tela de Finanças, para manter o mesmo estilo
/// visual em todo o app (a mesma composição vista nos Relatórios).
class FinanceCurvedHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double balance;
  final double income;
  final double expense;

  const FinanceCurvedHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    // Compensa o espaço da AppBar (transparente) + status bar, já que o
    // gradiente agora se estende por trás dela (extendBodyBehindAppBar).
    final appBarClearance = MediaQuery.paddingOf(context).top + kToolbarHeight;

    return CurvedGradientHeader(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, appBarClearance + 8, 20, 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 18),
            Text(
              'SALDO DISPONÍVEL',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 0.8,
                  ),
            ),
            const SizedBox(height: 4),
            AnimatedCurrencyText(
              value: balance,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MiniStat(
                  icon: CupertinoIcons.arrow_up_circle_fill,
                  label: 'Entradas',
                  value: income,
                ),
                const SizedBox(width: 24),
                Container(width: 1, height: 32, color: Colors.white24),
                const SizedBox(width: 24),
                _MiniStat(
                  icon: CupertinoIcons.arrow_down_circle_fill,
                  label: 'Saídas',
                  value: expense,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;

  const _MiniStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(height: 4),
        Text(label, style: textTheme.labelSmall?.copyWith(color: Colors.white70)),
        AnimatedCurrencyText(value: value, style: textTheme.titleMedium?.copyWith(color: Colors.white)),
      ],
    );
  }
}
