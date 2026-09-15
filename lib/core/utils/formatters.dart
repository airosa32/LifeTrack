import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  static final DateFormat _shortDate = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final DateFormat _dayMonth = DateFormat('d MMMM', 'pt_BR');
  static final DateFormat _weekdayDay = DateFormat('EEEE, d MMM', 'pt_BR');
  static final DateFormat _monthName = DateFormat('MMMM', 'pt_BR');

  static String currency(double value) => _currency.format(value);

  /// Mesmo formato de moeda, mas sempre com sinal (+/-) explícito.
  static String signedCurrency(double value, {required bool isIncome}) {
    final formatted = _currency.format(value.abs());
    return isIncome ? '+ $formatted' : '- $formatted';
  }

  static String shortDate(DateTime date) => _shortDate.format(date);

  static String dayMonth(DateTime date) => _dayMonth.format(date);

  static String weekdayDay(DateTime date) => _weekdayDay.format(date);

  /// Nome do mês com inicial maiúscula (ex: "Março").
  static String monthName(DateTime date) {
    final name = _monthName.format(date);
    return name[0].toUpperCase() + name.substring(1);
  }

  static String percentage(double value) => '${value.toStringAsFixed(0)}%';
}
