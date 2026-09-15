import '../models/dashboard_summary.dart';
import '../models/financial_alert.dart';
import '../models/task.dart';
import '../models/transaction.dart';
import 'alert_service.dart';
import 'finance_service.dart';

/// Monta o [DashboardSummary] combinando finanças, tarefas e alertas.
/// Não acessa repositories diretamente — recebe os dados já carregados
/// pelos providers, mantendo-se puro e testável.
class DashboardService {
  final FinanceService _financeService;
  final AlertService _alertService;

  const DashboardService({
    FinanceService financeService = const FinanceService(),
    AlertService alertService = const AlertService(),
  })  : _financeService = financeService,
        _alertService = alertService;

  DashboardSummary build({
    required List<Transaction> transactions,
    required List<Task> tasks,
    required List<FinancialAlert> alerts,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();

    final todayTasks = tasks.where((t) => _isSameDay(t.dueDate, now)).toList()
      ..sort((a, b) => a.priority.sortWeight.compareTo(b.priority.sortWeight));

    return DashboardSummary(
      totalIncome: _financeService.totalIncome(transactions),
      totalExpense: _financeService.totalExpense(transactions),
      balance: _financeService.calculateBalance(transactions),
      todayExpense: _financeService.calculateDailyExpense(transactions, now),
      todayTasks: todayTasks,
      activeAlerts: _alertService.evaluateAll(
        alerts,
        transactions,
        referenceDate: now,
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
