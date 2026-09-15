import '../core/network/api_client.dart';
import '../models/financial_alert.dart';

class AlertRepository {
  static const _path = 'alerts';
  final ApiClient _client;

  AlertRepository(this._client);

  Future<List<FinancialAlert>> getAll() async {
    final list = await _client.getList(_path);
    return list.map(FinancialAlert.fromJson).toList();
  }

  Future<FinancialAlert> create(FinancialAlert alert) async {
    final json = await _client.post(_path, alert.toJson());
    return FinancialAlert.fromJson(json);
  }

  Future<FinancialAlert> update(FinancialAlert alert) async {
    final json = await _client.put(_path, alert.id, alert.toJson());
    return FinancialAlert.fromJson(json);
  }

  Future<void> delete(String id) => _client.delete(_path, id);
}
