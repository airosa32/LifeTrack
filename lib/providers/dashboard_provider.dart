import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dashboard_summary.dart';
import '../services/dashboard_service.dart';
import 'alert_provider.dart';
import 'finance_provider.dart';
import 'task_provider.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) => const DashboardService());

final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);
  final tasksAsync = ref.watch(taskListProvider);
  final alertsAsync = ref.watch(alertListProvider);
  final service = ref.watch(dashboardServiceProvider);

  for (final async in [transactionsAsync, tasksAsync, alertsAsync]) {
    if (async is AsyncLoading) return const AsyncLoading();
  }
  for (final async in [transactionsAsync, tasksAsync, alertsAsync]) {
    if (async.hasError) return AsyncError(async.error!, async.stackTrace!);
  }

  return AsyncData(service.build(
    transactions: transactionsAsync.value ?? [],
    tasks: tasksAsync.value ?? [],
    alerts: alertsAsync.value ?? [],
  ));
});
