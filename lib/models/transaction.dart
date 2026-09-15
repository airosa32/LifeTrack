enum TransactionType { income, expense }

TransactionType transactionTypeFromString(String value) {
  return TransactionType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => TransactionType.expense,
  );
}

enum PaymentMethod { cash, pix, debit, credit, boleto, other }

PaymentMethod? paymentMethodFromString(String? value) {
  if (value == null) return null;
  return PaymentMethod.values.firstWhere(
    (e) => e.name == value,
    orElse: () => PaymentMethod.other,
  );
}

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Dinheiro';
      case PaymentMethod.pix:
        return 'Pix';
      case PaymentMethod.debit:
        return 'Débito';
      case PaymentMethod.credit:
        return 'Crédito';
      case PaymentMethod.boleto:
        return 'Boleto';
      case PaymentMethod.other:
        return 'Outros';
    }
  }
}

/// Frequência de repetição de uma entrada/saída (item 20 e roadmap V2
/// do briefing — "recorrência de despesas"). Quando diferente de [none],
/// o [RecurrenceService] gera automaticamente as próximas ocorrências
/// no momento da criação do lançamento.
enum RecurrenceType { none, daily, weekly, monthly }

RecurrenceType recurrenceTypeFromString(String? value) {
  if (value == null) return RecurrenceType.none;
  return RecurrenceType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => RecurrenceType.none,
  );
}

extension RecurrenceTypeLabel on RecurrenceType {
  String get label {
    switch (this) {
      case RecurrenceType.none:
        return 'Não repetir';
      case RecurrenceType.daily:
        return 'Diariamente';
      case RecurrenceType.weekly:
        return 'Semanalmente';
      case RecurrenceType.monthly:
        return 'Mensalmente';
    }
  }

  DateTime nextDate(DateTime from) {
    switch (this) {
      case RecurrenceType.none:
        return from;
      case RecurrenceType.daily:
        return DateTime(from.year, from.month, from.day + 1, from.hour);
      case RecurrenceType.weekly:
        return DateTime(from.year, from.month, from.day + 7, from.hour);
      case RecurrenceType.monthly:
        return DateTime(from.year, from.month + 1, from.day, from.hour);
    }
  }
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final PaymentMethod? paymentMethod;
  final String? note;
  final RecurrenceType recurrence;

  /// Vincula ocorrências geradas automaticamente ao lançamento original
  /// (nulo na primeira transação, preenchido nas seguintes).
  final String? recurrenceGroupId;

  const Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.paymentMethod,
    this.note,
    this.recurrence = RecurrenceType.none,
    this.recurrenceGroupId,
  });

  bool get isRecurring => recurrence != RecurrenceType.none;

  Transaction copyWith({
    String? id,
    String? description,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    PaymentMethod? paymentMethod,
    String? note,
    RecurrenceType? recurrence,
    String? recurrenceGroupId,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      recurrence: recurrence ?? this.recurrence,
      recurrenceGroupId: recurrenceGroupId ?? this.recurrenceGroupId,
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: transactionTypeFromString(json['type'] as String),
      categoryId: json['categoryId'] as String,
      date: DateTime.parse(json['date'] as String),
      paymentMethod: paymentMethodFromString(json['paymentMethod'] as String?),
      note: json['note'] as String?,
      recurrence: recurrenceTypeFromString(json['recurrence'] as String?),
      recurrenceGroupId: json['recurrenceGroupId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod?.name,
      'note': note,
      'recurrence': recurrence.name,
      'recurrenceGroupId': recurrenceGroupId,
    };
  }
}
