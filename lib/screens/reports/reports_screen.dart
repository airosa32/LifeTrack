import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/category_icons.dart';
import '../../core/utils/formatters.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common/animated_currency_text.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/section_title.dart';
import '../../widgets/common/staggered_list_item.dart';
import '../../widgets/common/state_widgets.dart';
import '../../widgets/finance/category_avatar.dart';
import '../../widgets/reports/month_overview_card.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(periodTransactionsProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final financeService = ref.watch(financeServiceProvider);
    final period = ref.watch(financePeriodProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Relatórios'),
      ),
      body: transactionsAsync.when(
        loading: () => const LoadingState(),
        error: (_, __) => const ErrorState(),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const EmptyState(
              icon: CupertinoIcons.chart_pie,
              message: 'Sem dados suficientes para gerar relatórios neste período.',
            );
          }

          final categories = categoriesAsync.value ?? const <Category>[];
          final income = financeService.totalIncome(transactions);
          final expense = financeService.totalExpense(transactions);
          final balance = income - expense;

          final byCategory = <String, double>{};
          for (final t in transactions.where((t) => t.type == TransactionType.expense)) {
            byCategory.update(t.categoryId, (v) => v + t.amount, ifAbsent: () => t.amount);
          }
          final sortedEntries = byCategory.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          Color colorFor(int i) {
            final category = categories.where((c) => c.id == sortedEntries[i].key).firstOrNull;
            return category?.color ?? CategoryIconRegistry.colorAt(i);
          }

          String nameFor(int i) {
            final category = categories.where((c) => c.id == sortedEntries[i].key).firstOrNull;
            return category?.name ?? 'Outros';
          }

          final slices = [
            for (var i = 0; i < sortedEntries.length; i++)
              CategorySlice(
                name: nameFor(i),
                amount: sortedEntries[i].value,
                percentage: expense == 0 ? 0 : sortedEntries[i].value / expense * 100,
                color: colorFor(i),
              ),
          ];

          // Estimativa simples de dias decorridos, usada para a média
          // diária de gastos exibida no card de visão geral.
          final now = DateTime.now();
          final elapsedDays = period == FinancePeriod.month ? now.day : 7;
          final dailyAverage = expense / (elapsedDays == 0 ? 1 : elapsedDays);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MonthOverviewCard(
                  periodLabel: Formatters.monthName(now),
                  totalExpense: expense,
                  dailyAverage: dailyAverage,
                  slices: slices.take(3).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Column(
                    children: [
                      const SectionTitle(title: 'Resumo'),
                      AppCard(
                        child: Column(
                          children: [
                            _SummaryRow(
                              icon: CupertinoIcons.arrow_down_circle_fill,
                              label: 'Entradas',
                              value: income,
                              color: AppStatusColors.normal,
                            ),
                            const SizedBox(height: 10),
                            _SummaryRow(
                              icon: CupertinoIcons.arrow_up_circle_fill,
                              label: 'Saídas',
                              value: expense,
                              color: AppStatusColors.critical,
                            ),
                            const Divider(height: 28),
                            _SummaryRow(
                              icon: CupertinoIcons.money_dollar_circle_fill,
                              label: 'Saldo',
                              value: balance,
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Gastos por categoria'),
                      if (sortedEntries.isEmpty)
                        const EmptyState(message: 'Nenhum gasto registrado neste período.')
                      else
                        ...List.generate(sortedEntries.length, (i) {
                          final entry = sortedEntries[i];
                          final category = categories.where((c) => c.id == entry.key).firstOrNull;
                          return StaggeredListItem(
                            index: i,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  CategoryAvatar(category: category, size: 32),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(category?.name ?? 'Outros'),
                                  ),
                                  Text(
                                    Formatters.currency(entry.value),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color? color;
  final bool bold;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = bold
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.bodyLarge;
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? scheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: style)),
        AnimatedCurrencyText(value: value, style: style?.copyWith(color: color)),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
