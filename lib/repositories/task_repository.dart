import '../core/network/api_client.dart';
import '../models/task.dart';

class TaskRepository {
  static const _path = 'tasks';
  final ApiClient _client;

  TaskRepository(this._client);

  Future<List<Task>> getAll() async {
    final list = await _client.getList(_path);
    return list.map(Task.fromJson).toList();
  }

  Future<Task> create(Task task) async {
    final json = await _client.post(_path, task.toJson());
    return Task.fromJson(json);
  }

  Future<Task> update(Task task) async {
    final json = await _client.put(_path, task.id, task.toJson());
    return Task.fromJson(json);
  }

  Future<void> delete(String id) => _client.delete(_path, id);
}
