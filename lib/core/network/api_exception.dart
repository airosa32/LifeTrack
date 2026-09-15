/// Exceção tipada para erros de rede/dados.
///
/// Repositories relançam falhas nesse formato para que a UI
/// (via AsyncValue.error) sempre tenha uma mensagem amigável,
/// sem vazar detalhes de implementação (http, formato de JSON, etc).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}
