import '../models/transaction.dart';

/// Camada de cálculos financeiros. Mantida livre de qualquer
/// dependência de UI ou de estado para poder ser testada isoladamente.
class FinanceService {
  const FinanceService();

  double totalIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double totalExpense(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Saldo = entradas - saídas.
  double calculateBalance(List<Transaction> transactions) {
    return totalIncome(transactions) - totalExpense(transactions);
  }

  /// Saldo disponível = saldo atual - reserva personalizada do usuário.
  double calculateAvailableBalance(
    List<Transaction> transactions, {
    double customReserve = 0,
  }) {
    return calculateBalance(transactions) - customReserve;
  }

  double calculateCategoryExpense(
    List<Transaction> transactions,
    String categoryId, {
    DateTime? from,
    DateTime? to,
  }) {
    return transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.categoryId == categoryId &&
            _withinRange(t.date, from, to))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double calculateDailyExpense(List<Transaction> transactions, DateTime day) {
    return transactions
        .where((t) =>
            t.type == TransactionType.expense && _isSameDay(t.date, day))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double calculateMonthlyExpense(
    List<Transaction> transactions,
    DateTime referenceMonth,
  ) {
    return transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.year == referenceMonth.year &&
            t.date.month == referenceMonth.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<Transaction> transactionsForDay(
    List<Transaction> transactions,
    DateTime day,
  ) {
    final list = transactions.where((t) => _isSameDay(t.date, day)).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _withinRange(DateTime date, DateTime? from, DateTime? to) {
    if (from != null && date.isBefore(from)) return false;
    if (to != null && date.isAfter(to)) return false;
    return true;
  }
}
