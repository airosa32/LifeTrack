import '../core/network/api_client.dart';
import '../models/category.dart';

class CategoryRepository {
  static const _path = 'categories';
  final ApiClient _client;

  CategoryRepository(this._client);

  Future<List<Category>> getAll() async {
    final list = await _client.getList(_path);
    return list.map(Category.fromJson).toList();
  }

  Future<Category> create(Category category) async {
    final json = await _client.post(_path, category.toJson());
    return Category.fromJson(json);
  }

  Future<Category> update(Category category) async {
    final json = await _client.put(_path, category.id, category.toJson());
    return Category.fromJson(json);
  }

  Future<void> delete(String id) => _client.delete(_path, id);
}
