import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/formatters.dart';
import '../../providers/alert_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/alerts/alert_card.dart';
import '../../widgets/common/animated_currency_text.dart';
import '../../widgets/common/animated_progress_bar.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/pulsing_badge.dart';
import '../../widgets/common/section_title.dart';
import '../../widgets/common/staggered_list_item.dart';
import '../../widgets/common/state_widgets.dart';
import '../../widgets/dashboard/finance_curved_header.dart';
import '../../widgets/tasks/task_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final unreadCount = ref.watch(unreadAlertCountProvider);
    final now = DateTime.now();

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.bell),
                onPressed: () => context.push('/alert-center'),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 8,
                  child: PulsingBadge(
                    active: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$unreadCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(CupertinoIcons.line_horizontal_3),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const LoadingState(),
        error: (error, stack) => ErrorState(
          onRetry: () => ref.invalidate(dashboardSummaryProvider),
        ),
        data: (summary) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardSummaryProvider);
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FinanceCurvedHeader(
                  title: 'Bom dia 👋',
                  subtitle: Formatters.weekdayDay(now),
                  balance: summary.balance,
                  income: summary.totalIncome,
                  expense: summary.totalExpense,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SectionTitle(
                        title: 'Hoje',
                        trailing: Text(
                          '${summary.completedTasksCount}/${summary.todayTasks.length} concluídas',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      if (summary.todayTasks.isEmpty)
                        const EmptyState(
                          icon: CupertinoIcons.checkmark_seal_fill,
                          message: 'Você está livre hoje! Nenhuma tarefa pendente.',
                        )
                      else ...[
                        AnimatedProgressBar(value: summary.todayProgress, minHeight: 8),
                        const SizedBox(height: 12),
                        ...summary.todayTasks.take(4).toList().asMap().entries.map(
                              (entry) => StaggeredListItem(
                                index: entry.key,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: TaskCard(
                                    task: entry.value,
                                    onToggle: () =>
                                        ref.read(taskListProvider.notifier).toggleCompleted(entry.value),
                                    onTap: () => context.push('/tasks/${entry.value.id}/edit'),
                                    onDelete: () => ref.read(taskListProvider.notifier).deleteTask(entry.value.id),
                                  ),
                                ),
                              ),
                            ),
                      ],
                      const SizedBox(height: 12),

                      SectionTitle(title: 'Gastos de hoje'),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AnimatedCurrencyText(
                          value: summary.todayExpense,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (summary.activeAlerts.isNotEmpty) ...[
                        const SectionTitle(title: 'Alertas'),
                        ...summary.activeAlerts.take(3).toList().asMap().entries.map(
                              (entry) => StaggeredListItem(
                                index: entry.key,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AlertCard(result: entry.value),
                                ),
                              ),
                            ),
                        const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
