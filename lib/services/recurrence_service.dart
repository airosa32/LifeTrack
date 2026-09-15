import 'package:uuid/uuid.dart';

import '../models/transaction.dart';

/// Responsável por expandir um lançamento recorrente em suas ocorrências
/// futuras no momento da criação.
///
/// Abordagem escolhida para o MVP: gerar um número fixo de ocorrências
/// futuras de uma vez (em vez de um job/cron rodando em background, que
/// exigiria backend), simples de explicar e de testar. O usuário pode
/// excluir/editar cada ocorrência individualmente depois, como qualquer
/// outro lançamento.
class RecurrenceService {
  final Uuid _uuid;

  const RecurrenceService([this._uuid = const Uuid()]);

  /// Quantas ocorrências futuras gerar por frequência.
  static const Map<RecurrenceType, int> occurrencesByType = {
    RecurrenceType.daily: 14,
    RecurrenceType.weekly: 8,
    RecurrenceType.monthly: 12,
  };

  /// Recebe a transação original (já com `id` e `recurrence` definidos) e
  /// devolve a lista de ocorrências futuras a serem persistidas em seguida
  /// (a original não é incluída na lista de retorno).
  List<Transaction> generateFutureOccurrences(Transaction original) {
    if (!original.isRecurring) return const [];

    final occurrences = occurrencesByType[original.recurrence] ?? 0;
    final groupId = original.recurrenceGroupId ?? original.id;
    final result = <Transaction>[];

    var currentDate = original.date;
    for (var i = 0; i < occurrences; i++) {
      currentDate = original.recurrence.nextDate(currentDate);
      result.add(
        original.copyWith(
          id: _uuid.v4(),
          date: currentDate,
          recurrenceGroupId: groupId,
        ),
      );
    }
    return result;
  }
}
