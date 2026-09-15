import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../common/animated_currency_text.dart';
import '../common/curved_gradient_header.dart';

class CategorySlice {
  final String name;
  final double amount;
  final double percentage;
  final Color color;

  const CategorySlice({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

/// Header colorido em largura total (sem card, sem sombra — pertence ao
/// fundo da tela) seguido do conteúdo (rosca + média diária), igual à
/// referência: nada aqui flutua como um card separado, só a curva da
/// base do header (animada) separa visualmente as duas zonas.
class MonthOverviewCard extends StatelessWidget {
  final String periodLabel;
  final double totalExpense;
  final double dailyAverage;
  final List<CategorySlice> slices;

  const MonthOverviewCard({
    super.key,
    required this.periodLabel,
    required this.totalExpense,
    required this.dailyAverage,
    required this.slices,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appBarClearance = MediaQuery.paddingOf(context).top + kToolbarHeight;

    return Column(
      children: [
        CurvedGradientHeader(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, appBarClearance + 12, 24, 44),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      periodLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(CupertinoIcons.calendar, color: Colors.white70, size: 18),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Total de gastos do mês',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                AnimatedCurrencyText(
                  value: totalExpense,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                      ),
                ),
              ],
            ),
          ),
        ),
        // Conteúdo direto sobre o fundo da tela — sem card, sem sombra.
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: SizedBox(
                  width: 260,
                  height: 190,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 55,
                          sections: [
                            for (final slice in slices)
                              PieChartSectionData(
                                value: slice.amount,
                                color: slice.color,
                                radius: 34,
                                showTitle: false,
                              ),
                          ],
                        ),
                      ),
                      // Rótulos de percentual bem próximos ao anel
                      // (a caixa é só um pouco mais larga que a rosca).
                      if (slices.isNotEmpty)
                        Positioned(
                          top: 6,
                          left: 0,
                          child: _SliceLabel(slice: slices[0]),
                        ),
                      if (slices.length > 1)
                        Positioned(
                          top: 6,
                          right: 0,
                          child: _SliceLabel(slice: slices[1]),
                        ),
                      if (slices.length > 2)
                        Positioned(
                          bottom: 6,
                          child: _SliceLabel(slice: slices[2]),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedCurrencyText(
                value: dailyAverage,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 2),
              Text(
                'média diária de gastos',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SliceLabel extends StatelessWidget {
  final CategorySlice slice;

  const _SliceLabel({required this.slice});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          slice.name,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: slice.color, fontWeight: FontWeight.w700),
        ),
        Text(
          Formatters.percentage(slice.percentage),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
