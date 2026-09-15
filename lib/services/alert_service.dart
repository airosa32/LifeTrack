import '../core/constants/app_constants.dart';
import '../models/financial_alert.dart';
import '../models/transaction.dart';
import 'finance_service.dart';

/// Motor de regras dos alertas financeiros.
///
/// Cada `checkX` recebe o estado financeiro atual + a regra configurada
/// pelo usuário e devolve um [AlertResult] com o nível (normal/atenção/
/// crítico) e uma mensagem pronta para exibição. Mantido sem qualquer
/// dependência de Riverpod ou widgets, para ser 100% testável.
class AlertService {
  final FinanceService _financeService;

  const AlertService([this._financeService = const FinanceService()]);

  /// Avalia todas as regras ativas e retorna apenas os resultados
  /// que merecem exibição (atenção ou crítico primeiro).
  List<AlertResult> evaluateAll(
    List<FinancialAlert> alerts,
    List<Transaction> transactions, {
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final results = <AlertResult>[];

    for (final alert in alerts.where((a) => a.active)) {
      final result = _evaluateSingle(alert, transactions, now);
      if (result != null) results.add(result);
    }

    results.sort((a, b) => b.level.index.compareTo(a.level.index));
    return results;
  }

  AlertResult? _evaluateSingle(
    FinancialAlert alert,
    List<Transaction> transactions,
    DateTime now,
  ) {
    switch (alert.type) {
      case AlertType.minimumBalance:
        return _checkMinimumBalance(alert, transactions);
      case AlertType.maxExpense:
        return _checkMonthlyLimit(alert, transactions, now);
      case AlertType.dailyLimit:
        return _checkDailyLimit(alert, transactions, now);
      case AlertType.categoryLimit:
        return _checkCategoryLimit(alert, transactions, now);
      case AlertType.balancePercentage:
        return _checkBalancePercentage(alert, transactions);
    }
  }

  /// Saldo mínimo: dispara quando o saldo atual se aproxima ou fica
  /// abaixo do limite configurado. Usamos uma margem de segurança de
  /// 25% acima do limite como zona de "atenção".
  AlertResult _checkMinimumBalance(
    FinancialAlert alert,
    List<Transaction> transactions,
  ) {
    final balance = _financeService.calculateBalance(transactions);

    // Normalizado para que balance == alert.value equivalha a 100%
    // (ou seja, exatamente no limite configurado).
    final percentage = balance <= 0
        ? 200.0
        : (alert.value / balance * 100).clamp(0, 200).toDouble();

    final level = _levelFromPercentage(percentage);
    final message = switch (level) {
      AlertLevel.critical =>
        'Seu saldo está abaixo do limite configurado.',
      AlertLevel.attention =>
        'Seu saldo está se aproximando do limite mínimo.',
      AlertLevel.normal => 'Seu saldo está dentro do limite.',
    };

    return AlertResult(
      alert: alert,
      level: level,
      message: message,
      percentage: percentage,
    );
  }

  /// Gasto máximo mensal.
  AlertResult _checkMonthlyLimit(
    FinancialAlert alert,
    List<Transaction> transactions,
    DateTime now,
  ) {
    final spent = _financeService.calculateMonthlyExpense(transactions, now);
    final percentage = alert.value <= 0 ? 0.0 : (spent / alert.value * 100);
    final level = _levelFromPercentage(percentage);

    final message = switch (level) {
      AlertLevel.critical => 'Você ultrapassou o limite mensal de gastos.',
      AlertLevel.attention => 'Você está próximo do limite mensal.',
      AlertLevel.normal => 'Seus gastos mensais estão sob controle.',
    };

    return AlertResult(alert: alert, level: level, message: message, percentage: percentage);
  }

  /// Limite diário de gastos.
  AlertResult _checkDailyLimit(
    FinancialAlert alert,
    List<Transaction> transactions,
    DateTime now,
  ) {
    final spentToday = _financeService.calculateDailyExpense(transactions, now);
    final percentage = alert.value <= 0 ? 0.0 : (spentToday / alert.value * 100);
    final level = _levelFromPercentage(percentage);

    final message = switch (level) {
      AlertLevel.critical => 'Limite diário ultrapassado.',
      AlertLevel.attention => 'Você está próximo do limite diário.',
      AlertLevel.normal => 'Gastos de hoje dentro do limite diário.',
    };

    return AlertResult(alert: alert, level: level, message: message, percentage: percentage);
  }

  /// Limite de gasto por categoria (base mensal).
  AlertResult? _checkCategoryLimit(
    FinancialAlert alert,
    List<Transaction> transactions,
    DateTime now,
  ) {
    if (alert.categoryId == null) return null;
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final spent = _financeService.calculateCategoryExpense(
      transactions,
      alert.categoryId!,
      from: from,
      to: to,
    );
    final percentage = alert.value <= 0 ? 0.0 : (spent / alert.value * 100);
    final level = _levelFromPercentage(percentage);

    final message = switch (level) {
      AlertLevel.critical => 'Limite da categoria ultrapassado.',
      AlertLevel.attention => 'Você está próximo do limite desta categoria.',
      AlertLevel.normal => 'Gastos desta categoria dentro do limite.',
    };

    return AlertResult(alert: alert, level: level, message: message, percentage: percentage);
  }

  /// Percentual do saldo/renda já utilizado em gastos.
  AlertResult? _checkBalancePercentage(
    FinancialAlert alert,
    List<Transaction> transactions,
  ) {
    final income = _financeService.totalIncome(transactions);
    if (income <= 0) return null;
    final expense = _financeService.totalExpense(transactions);
    final usedPercentage = expense / income * 100;
    // alert.value é o percentual-gatilho configurado pelo usuário (ex: 80%).
    final percentage = alert.value <= 0 ? 0.0 : (usedPercentage / alert.value * 100);
    final level = _levelFromPercentage(percentage);

    final message = switch (level) {
      AlertLevel.critical =>
        'Você já utilizou mais de ${alert.value.toStringAsFixed(0)}% do seu saldo.',
      AlertLevel.attention =>
        'Você está se aproximando de ${alert.value.toStringAsFixed(0)}% do saldo utilizado.',
      AlertLevel.normal => 'Uso do saldo dentro do esperado.',
    };

    return AlertResult(alert: alert, level: level, message: message, percentage: percentage);
  }

  AlertLevel _levelFromPercentage(double percentage) {
    if (percentage >= AppConstants.criticalThreshold) return AlertLevel.critical;
    if (percentage >= AppConstants.attentionThreshold) return AlertLevel.attention;
    return AlertLevel.normal;
  }
}
