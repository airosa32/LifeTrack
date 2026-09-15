import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Contrato de acesso a dados que os Repositories dependem.
///
/// Isso é o que permite trocar a fonte de dados (mock local <-> API real)
/// sem alterar uma linha sequer de Repository, Service ou Provider.
abstract class ApiClient {
  Future<List<Map<String, dynamic>>> getList(String path);
  Future<Map<String, dynamic>> getOne(String path, String id);
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body);
  Future<Map<String, dynamic>> put(
    String path,
    String id,
    Map<String, dynamic> body,
  );
  Future<void> delete(String path, String id);
}

/// Implementação real, pensada para falar com um JSON Server
/// (`json-server --watch db.json --port 3000`) ou qualquer backend REST
/// que siga o mesmo contrato de endpoints descrito no briefing do projeto.
///
/// Para usar: troque `mockApiClientProvider` por este client nos providers,
/// apontando `baseUrl` para o seu servidor.
class HttpApiClient implements ApiClient {
  final String baseUrl;
  final http.Client _client;

  HttpApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  Uri _uri(String path, [String? id]) {
    final segments = id == null ? path : '$path/$id';
    return Uri.parse('$baseUrl/$segments');
  }

  @override
  Future<List<Map<String, dynamic>>> getList(String path) async {
    final response = await _get(_uri(path));
    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> getOne(String path, String id) async {
    final response = await _get(_uri(path, id));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    _checkStatus(response.statusCode);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> put(
    String path,
    String id,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.put(
      _uri(path, id),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    _checkStatus(response.statusCode);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<void> delete(String path, String id) async {
    final response = await _client.delete(_uri(path, id));
    _checkStatus(response.statusCode);
  }

  Future<http.Response> _get(Uri uri) async {
    final response = await _client.get(uri);
    _checkStatus(response.statusCode);
    return response;
  }

  void _checkStatus(int statusCode) {
    if (statusCode < 200 || statusCode >= 300) {
      throw ApiException(
        'Não foi possível completar a requisição.',
        statusCode: statusCode,
      );
    }
  }
}
