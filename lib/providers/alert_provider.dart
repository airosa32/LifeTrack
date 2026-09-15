import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/financial_alert.dart';
import '../services/alert_service.dart';
import 'core_providers.dart';
import 'finance_provider.dart';

final alertServiceProvider = Provider<AlertService>((ref) => const AlertService());

class AlertListNotifier extends AsyncNotifier<List<FinancialAlert>> {
  @override
  Future<List<FinancialAlert>> build() {
    return ref.read(alertRepositoryProvider).getAll();
  }

  Future<void> addAlert(FinancialAlert alert) async {
    try {
      final created = await ref.read(alertRepositoryProvider).create(alert);
      state = AsyncData([...state.value ?? [], created]);
    } catch (_) {
      throw const ApiException('Não foi possível criar o alerta.');
    }
  }

  Future<void> updateAlert(FinancialAlert alert) async {
    try {
      final updated = await ref.read(alertRepositoryProvider).update(alert);
      final current = state.value ?? [];
      state = AsyncData([
        for (final a in current) if (a.id == updated.id) updated else a,
      ]);
    } catch (_) {
      throw const ApiException('Não foi possível atualizar o alerta.');
    }
  }

  Future<void> toggleActive(FinancialAlert alert) async {
    await updateAlert(alert.copyWith(active: !alert.active));
  }

  Future<void> deleteAlert(String id) async {
    try {
      await ref.read(alertRepositoryProvider).delete(id);
      final current = state.value ?? [];
      state = AsyncData(current.where((a) => a.id != id).toList());
    } catch (_) {
      throw const ApiException('Não foi possível excluir o alerta.');
    }
  }
}

final alertListProvider = AsyncNotifierProvider<AlertListNotifier, List<FinancialAlert>>(
  AlertListNotifier.new,
);

/// IDs de alerta que o usuário já marcou como lido nesta sessão.
/// Mantido em memória (não persistido) — é o suficiente para o MVP,
/// já que os alertas são recalculados a cada mudança de transação.
class ReadAlertsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void markAsRead(String alertId) {
    state = {...state, alertId};
  }

  void markAllAsRead(Iterable<String> alertIds) {
    state = {...state, ...alertIds};
  }

  void markAsUnread(String alertId) {
    state = {...state}..remove(alertId);
  }
}

final readAlertsProvider = NotifierProvider<ReadAlertsNotifier, Set<String>>(
  ReadAlertsNotifier.new,
);

/// Quantidade de alertas não-normais (atenção/crítico) ainda não lidos —
/// usado no badge do sino na Dashboard.
final unreadAlertCountProvider = Provider<int>((ref) {
  final resultsAsync = ref.watch(alertResultsProvider);
  final read = ref.watch(readAlertsProvider);
  final results = resultsAsync.value ?? [];
  return results
      .where((r) => r.level != AlertLevel.normal && !read.contains(r.alert.id))
      .length;
});

/// Resultado da avaliação de todas as regras de alerta ativas,
/// recalculado sempre que transações ou alertas mudam.
final alertResultsProvider = Provider<AsyncValue<List<AlertResult>>>((ref) {
  final alertsAsync = ref.watch(alertListProvider);
  final transactionsAsync = ref.watch(transactionListProvider);
  final alertService = ref.watch(alertServiceProvider);

  if (alertsAsync is AsyncLoading || transactionsAsync is AsyncLoading) {
    return const AsyncLoading();
  }
  if (alertsAsync.hasError) {
    return AsyncError(alertsAsync.error!, alertsAsync.stackTrace!);
  }
  if (transactionsAsync.hasError) {
    return AsyncError(transactionsAsync.error!, transactionsAsync.stackTrace!);
  }

  final alerts = alertsAsync.value ?? [];
  final transactions = transactionsAsync.value ?? [];
  return AsyncData(alertService.evaluateAll(alerts, transactions));
});
