class Validators {
  Validators._();

  static String? requiredField(String? value, {String message = 'Campo obrigatório'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? positiveAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe um valor';
    final normalized = value.replaceAll('.', '').replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null) return 'Valor inválido';
    if (parsed <= 0) return 'O valor deve ser maior que zero';
    return null;
  }

  /// Converte texto de input (ex: "1.234,56" ou "1234.56") para double.
  static double parseAmount(String value) {
    final normalized = value.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }
}
