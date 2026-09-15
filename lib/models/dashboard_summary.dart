import 'financial_alert.dart';
import 'task.dart';

/// Objeto agregador, computado em runtime (nunca persistido),
/// que resume o estado do dia para a Dashboard.
class DashboardSummary {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final double todayExpense;
  final List<Task> todayTasks;
  final List<AlertResult> activeAlerts;

  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.todayExpense,
    required this.todayTasks,
    required this.activeAlerts,
  });

  int get completedTasksCount => todayTasks.where((t) => t.completed).length;

  double get todayProgress =>
      todayTasks.isEmpty ? 0 : completedTasksCount / todayTasks.length;
}
