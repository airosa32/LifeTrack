import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/finance_service.dart';
import '../services/recurrence_service.dart';
import 'core_providers.dart';

final financeServiceProvider = Provider<FinanceService>((ref) => const FinanceService());
final recurrenceServiceProvider = Provider<RecurrenceService>((ref) => const RecurrenceService());

class TransactionListNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() {
    return ref.read(transactionRepositoryProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(transactionRepositoryProvider).getAll());
  }

  /// Cria o lançamento e, se ele for recorrente, já gera e persiste
  /// as próximas ocorrências (ver [RecurrenceService]).
  /// Retorna quantas ocorrências futuras foram criadas.
  Future<int> addTransaction(Transaction transaction) async {
    try {
      final repository = ref.read(transactionRepositoryProvider);
      final created = await repository.create(transaction);
      var all = <Transaction>[created, ...state.value ?? <Transaction>[]];

      var generatedCount = 0;
      if (created.isRecurring) {
        final futureOnes = ref.read(recurrenceServiceProvider).generateFutureOccurrences(created);
        for (final occurrence in futureOnes) {
          final savedOccurrence = await repository.create(occurrence);
          all = <Transaction>[...all, savedOccurrence];
        }
        generatedCount = futureOnes.length;
      }

      state = AsyncData(all);
      return generatedCount;
    } catch (_) {
      throw const ApiException('Não foi possível salvar o lançamento.');
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      final updated = await ref.read(transactionRepositoryProvider).update(transaction);
      final current = state.value ?? [];
      state = AsyncData([
        for (final t in current) if (t.id == updated.id) updated else t,
      ]);
    } catch (_) {
      throw const ApiException('Não foi possível atualizar o lançamento.');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await ref.read(transactionRepositoryProvider).delete(id);
      final current = state.value ?? [];
      state = AsyncData(current.where((t) => t.id != id).toList());
    } catch (_) {
      throw const ApiException('Não foi possível excluir o lançamento.');
    }
  }
}

final transactionListProvider =
    AsyncNotifierProvider<TransactionListNotifier, List<Transaction>>(
  TransactionListNotifier.new,
);

class CategoryListNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() {
    return ref.read(categoryRepositoryProvider).getAll();
  }

  Future<void> addCategory(Category category) async {
    try {
      final created = await ref.read(categoryRepositoryProvider).create(category);
      state = AsyncData([...state.value ?? [], created]);
    } catch (_) {
      throw const ApiException('Não foi possível criar a categoria.');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await ref.read(categoryRepositoryProvider).delete(id);
      final current = state.value ?? [];
      state = AsyncData(current.where((c) => c.id != id).toList());
    } catch (_) {
      throw const ApiException('Não foi possível excluir a categoria.');
    }
  }
}

final categoryListProvider = AsyncNotifierProvider<CategoryListNotifier, List<Category>>(
  CategoryListNotifier.new,
);

/// Saldo atual (entradas - saídas), computado a partir das transações.
final balanceProvider = Provider<AsyncValue<double>>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);
  final financeService = ref.watch(financeServiceProvider);
  return transactionsAsync.whenData(financeService.calculateBalance);
});

enum FinancePeriod { today, week, month, previousMonth }

final financePeriodProvider = StateProvider<FinancePeriod>((ref) => FinancePeriod.month);

/// Transações filtradas pelo período selecionado na tela de Finanças.
final periodTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);
  final period = ref.watch(financePeriodProvider);
  final now = DateTime.now();

  return transactionsAsync.whenData((transactions) {
    late DateTime from;
    late DateTime to;

    switch (period) {
      case FinancePeriod.today:
        from = DateTime(now.year, now.month, now.day);
        to = DateTime(now.year, now.month, now.day, 23, 59, 59);
      case FinancePeriod.week:
        from = now.subtract(Duration(days: now.weekday - 1));
        from = DateTime(from.year, from.month, from.day);
        to = now;
      case FinancePeriod.month:
        from = DateTime(now.year, now.month, 1);
        to = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      case FinancePeriod.previousMonth:
        from = DateTime(now.year, now.month - 1, 1);
        to = DateTime(now.year, now.month, 0, 23, 59, 59);
    }

    return transactions
        .where((t) => !t.date.isBefore(from) && !t.date.isAfter(to))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  });
});
