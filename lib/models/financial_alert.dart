enum AlertType {
  minimumBalance,
  maxExpense,
  dailyLimit,
  categoryLimit,
  balancePercentage,
}

AlertType alertTypeFromString(String value) {
  return AlertType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => AlertType.minimumBalance,
  );
}

extension AlertTypeLabel on AlertType {
  String get label {
    switch (this) {
      case AlertType.minimumBalance:
        return 'Saldo mínimo';
      case AlertType.maxExpense:
        return 'Gasto máximo (mensal)';
      case AlertType.dailyLimit:
        return 'Limite diário';
      case AlertType.categoryLimit:
        return 'Limite por categoria';
      case AlertType.balancePercentage:
        return 'Percentual do saldo';
    }
  }
}

/// Regra de alerta configurada pelo usuário.
class FinancialAlert {
  final String id;
  final String name;
  final AlertType type;
  final double value; // valor limite, ou percentual (0-100) para balancePercentage
  final String? categoryId; // usado apenas quando type == categoryLimit
  final bool active;

  const FinancialAlert({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.categoryId,
    this.active = true,
  });

  FinancialAlert copyWith({
    String? id,
    String? name,
    AlertType? type,
    double? value,
    String? categoryId,
    bool? active,
  }) {
    return FinancialAlert(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      categoryId: categoryId ?? this.categoryId,
      active: active ?? this.active,
    );
  }

  factory FinancialAlert.fromJson(Map<String, dynamic> json) {
    return FinancialAlert(
      id: json['id'] as String,
      name: json['name'] as String,
      type: alertTypeFromString(json['type'] as String),
      value: (json['value'] as num).toDouble(),
      categoryId: json['categoryId'] as String?,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'value': value,
      'categoryId': categoryId,
      'active': active,
    };
  }
}

enum AlertLevel { normal, attention, critical }

/// Resultado da avaliação de uma regra de alerta em um dado momento.
class AlertResult {
  final FinancialAlert alert;
  final AlertLevel level;
  final String message;
  final double percentage; // 0-100+, útil para barras de progresso

  const AlertResult({
    required this.alert,
    required this.level,
    required this.message,
    required this.percentage,
  });
}
