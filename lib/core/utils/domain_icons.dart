import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart' show IconData;

import '../../models/financial_alert.dart';
import '../../models/task.dart';
import '../../models/transaction.dart';

/// Centraliza a escolha de ícone para cada valor de enum do domínio.
/// Mantém os widgets livres de switch/case repetidos e garante que o
/// mesmo conceito (ex: "Pix") sempre apareça com o mesmo ícone em
/// qualquer tela do app.
class DomainIcons {
  DomainIcons._();

  static IconData paymentMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return CupertinoIcons.money_dollar;
      case PaymentMethod.pix:
        return CupertinoIcons.bolt_fill;
      case PaymentMethod.debit:
        return CupertinoIcons.creditcard;
      case PaymentMethod.credit:
        return CupertinoIcons.creditcard_fill;
      case PaymentMethod.boleto:
        return CupertinoIcons.barcode;
      case PaymentMethod.other:
        return CupertinoIcons.ellipsis_circle;
    }
  }

  static IconData recurrence(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return CupertinoIcons.xmark_circle;
      case RecurrenceType.daily:
        return CupertinoIcons.sun_max;
      case RecurrenceType.weekly:
        return CupertinoIcons.calendar;
      case RecurrenceType.monthly:
        return CupertinoIcons.repeat;
    }
  }

  static IconData priority(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return CupertinoIcons.arrow_down_circle;
      case TaskPriority.medium:
        return CupertinoIcons.minus_circle;
      case TaskPriority.high:
        return CupertinoIcons.arrow_up_circle;
      case TaskPriority.urgent:
        return CupertinoIcons.exclamationmark_circle_fill;
    }
  }

  static IconData alertType(AlertType type) {
    switch (type) {
      case AlertType.minimumBalance:
        return CupertinoIcons.money_dollar_circle;
      case AlertType.maxExpense:
        return CupertinoIcons.chart_bar;
      case AlertType.dailyLimit:
        return CupertinoIcons.calendar_today;
      case AlertType.categoryLimit:
        return CupertinoIcons.tag;
      case AlertType.balancePercentage:
        return CupertinoIcons.percent;
    }
  }

  static IconData categoryType(CategoryTypeLike type) {
    return type == CategoryTypeLike.income
        ? CupertinoIcons.arrow_down_left_circle
        : CupertinoIcons.arrow_up_right_circle;
  }
}

/// Evita importar `Category`/`CategoryType` aqui só por causa de um ícone;
/// as telas passam o valor já convertido.
enum CategoryTypeLike { income, expense }
