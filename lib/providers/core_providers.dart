import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/network/in_memory_api_client.dart';
import '../core/network/seed_data.dart';
import '../repositories/alert_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/task_repository.dart';
import '../repositories/transaction_repository.dart';

/// Fonte única do "banco de dados" em memória durante a sessão do app.
/// Trocar por [HttpApiClient] aqui é a única mudança necessária para
/// migrar para uma API real (ex: JSON Server) — nenhuma outra camada
/// precisa ser alterada.
final apiClientProvider = Provider<ApiClient>((ref) {
  return InMemoryApiClient(buildSeedStore());
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(apiClientProvider));
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(apiClientProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(apiClientProvider));
});

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepository(ref.watch(apiClientProvider));
});
