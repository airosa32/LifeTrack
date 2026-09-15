import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/category.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common/section_title.dart';
import '../../widgets/common/staggered_list_item.dart';
import '../../widgets/common/state_widgets.dart';
import '../../widgets/dashboard/finance_curved_header.dart';
import '../../widgets/finance/transaction_card.dart';

extension on FinancePeriod {
  String get label {
    switch (this) {
      case FinancePeriod.today:
        return 'Hoje';
      case FinancePeriod.week:
        return 'Esta semana';
      case FinancePeriod.month:
        return 'Este mês';
      case FinancePeriod.previousMonth:
        return 'Mês anterior';
    }
  }

  IconData get icon {
    switch (this) {
      case FinancePeriod.today:
        return CupertinoIcons.sun_max;
      case FinancePeriod.week:
        return CupertinoIcons.calendar;
      case FinancePeriod.month:
        return CupertinoIcons.calendar_today;
      case FinancePeriod.previousMonth:
        return CupertinoIcons.arrow_counterclockwise;
    }
  }
}

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodTransactionsAsync = ref.watch(periodTransactionsProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final currentPeriod = ref.watch(financePeriodProvider);
    final financeService = ref.watch(financeServiceProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Finanças'),
      ),
      body: periodTransactionsAsync.when(
        loading: () => const LoadingState(),
        error: (error, stack) => ErrorState(
          onRetry: () => ref.read(transactionListProvider.notifier).refresh(),
        ),
        data: (transactions) {
          final income = financeService.totalIncome(transactions);
          final expense = financeService.totalExpense(transactions);
          final balance = income - expense;
          final categories = categoriesAsync.value ?? const <Category>[];

          return RefreshIndicator(
            onRefresh: () => ref.read(transactionListProvider.notifier).refresh(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FinanceCurvedHeader(
                    title: 'Finanças',
                    subtitle: currentPeriod.label,
                    balance: balance,
                    income: income,
                    expense: expense,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: FinancePeriod.values.map((period) {
                              final selected = period == currentPeriod;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  avatar: Icon(period.icon, size: 16),
                                  label: Text(period.label),
                                  selected: selected,
                                  onSelected: (_) => ref.read(financePeriodProvider.notifier).state = period,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const SectionTitle(title: 'Movimentações'),
                        if (transactions.isEmpty)
                          const EmptyState(
                            icon: CupertinoIcons.doc_text,
                            message: 'Você ainda não possui lançamentos neste período.',
                          )
                        else
                          ...transactions.asMap().entries.map((entry) {
                            final t = entry.value;
                            final category = categories.where((c) => c.id == t.categoryId).firstOrNull;
                            return StaggeredListItem(
                              index: entry.key,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: TransactionCard(
                                  transaction: t,
                                  category: category,
                                  onTap: () => context.push('/finance/${t.id}'),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
