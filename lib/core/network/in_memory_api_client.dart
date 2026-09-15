import 'package:uuid/uuid.dart';

import 'api_client.dart';
import 'api_exception.dart';

/// Implementação local do [ApiClient], usada como "API mock" do MVP.
///
/// Segue exatamente o mesmo contrato REST (getList/getOne/post/put/delete)
/// que [HttpApiClient] usaria contra um JSON Server real — por isso trocar
/// uma implementação pela outra não exige nenhuma mudança em Repository,
/// Service ou Provider. Simula latência de rede propositalmente, para que
/// os estados de loading do app sejam exercitados de verdade.
class InMemoryApiClient implements ApiClient {
  final Map<String, List<Map<String, dynamic>>> _store;
  final Uuid _uuid = const Uuid();
  final Duration _latency;

  InMemoryApiClient(this._store, {Duration? latency})
      : _latency = latency ?? const Duration(milliseconds: 350);

  List<Map<String, dynamic>> _collection(String path) {
    return _store.putIfAbsent(path, () => []);
  }

  @override
  Future<List<Map<String, dynamic>>> getList(String path) async {
    await Future.delayed(_latency);
    return List<Map<String, dynamic>>.from(_collection(path));
  }

  @override
  Future<Map<String, dynamic>> getOne(String path, String id) async {
    await Future.delayed(_latency);
    final item = _collection(path).firstWhere(
      (e) => e['id'] == id,
      orElse: () => throw const ApiException('Registro não encontrado.'),
    );
    return Map<String, dynamic>.from(item);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    await Future.delayed(_latency);
    final newItem = {...body, 'id': body['id'] ?? _uuid.v4()};
    _collection(path).add(newItem);
    return Map<String, dynamic>.from(newItem);
  }

  @override
  Future<Map<String, dynamic>> put(
    String path,
    String id,
    Map<String, dynamic> body,
  ) async {
    await Future.delayed(_latency);
    final collection = _collection(path);
    final index = collection.indexWhere((e) => e['id'] == id);
    if (index == -1) {
      throw const ApiException('Registro não encontrado para atualização.');
    }
    final updated = {...body, 'id': id};
    collection[index] = updated;
    return Map<String, dynamic>.from(updated);
  }

  @override
  Future<void> delete(String path, String id) async {
    await Future.delayed(_latency);
    final collection = _collection(path);
    final removed = collection.any((e) => e['id'] == id);
    if (!removed) {
      throw const ApiException('Registro não encontrado para exclusão.');
    }
    collection.removeWhere((e) => e['id'] == id);
  }
}
