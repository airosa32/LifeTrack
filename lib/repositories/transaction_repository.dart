import '../core/network/api_client.dart';
import '../models/transaction.dart';

class TransactionRepository {
  static const _path = 'transactions';
  final ApiClient _client;

  TransactionRepository(this._client);

  Future<List<Transaction>> getAll() async {
    final list = await _client.getList(_path);
    return list.map(Transaction.fromJson).toList();
  }

  Future<Transaction> create(Transaction transaction) async {
    final json = await _client.post(_path, transaction.toJson());
    return Transaction.fromJson(json);
  }

  Future<Transaction> update(Transaction transaction) async {
    final json = await _client.put(_path, transaction.id, transaction.toJson());
    return Transaction.fromJson(json);
  }

  Future<void> delete(String id) => _client.delete(_path, id);
}
