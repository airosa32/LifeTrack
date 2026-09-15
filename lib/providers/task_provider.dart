import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/task.dart';
import 'core_providers.dart';

class TaskListNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() {
    return ref.read(taskRepositoryProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(taskRepositoryProvider).getAll());
  }

  Future<void> addTask(Task task) async {
    try {
      final created = await ref.read(taskRepositoryProvider).create(task);
      state = AsyncData([...state.value ?? [], created]);
    } catch (_) {
      throw const ApiException('Não foi possível criar a tarefa.');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final updated = await ref.read(taskRepositoryProvider).update(task);
      final current = state.value ?? [];
      state = AsyncData([
        for (final t in current) if (t.id == updated.id) updated else t,
      ]);
    } catch (_) {
      throw const ApiException('Não foi possível atualizar a tarefa.');
    }
  }

  Future<void> toggleCompleted(Task task) async {
    await updateTask(task.copyWith(completed: !task.completed, updatedAt: DateTime.now()));
  }

  Future<void> deleteTask(String id) async {
    try {
      await ref.read(taskRepositoryProvider).delete(id);
      final current = state.value ?? [];
      state = AsyncData(current.where((t) => t.id != id).toList());
    } catch (_) {
      throw const ApiException('Não foi possível excluir a tarefa.');
    }
  }
}

final taskListProvider = AsyncNotifierProvider<TaskListNotifier, List<Task>>(
  TaskListNotifier.new,
);

enum TaskFilter { all, today, pending, completed, highPriority }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);
final taskSearchQueryProvider = StateProvider<String>((ref) => '');

/// Lista de tarefas já filtrada/pesquisada, pronta para a UI consumir.
final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(taskListProvider);
  final filter = ref.watch(taskFilterProvider);
  final query = ref.watch(taskSearchQueryProvider).trim().toLowerCase();
  final now = DateTime.now();

  return tasksAsync.whenData((tasks) {
    var result = tasks.where((t) {
      switch (filter) {
        case TaskFilter.all:
          return true;
        case TaskFilter.today:
          return t.dueDate.year == now.year &&
              t.dueDate.month == now.month &&
              t.dueDate.day == now.day;
        case TaskFilter.pending:
          return !t.completed;
        case TaskFilter.completed:
          return t.completed;
        case TaskFilter.highPriority:
          return t.priority == TaskPriority.high || t.priority == TaskPriority.urgent;
      }
    }).toList();

    if (query.isNotEmpty) {
      result = result.where((t) => t.title.toLowerCase().contains(query)).toList();
    }

    result.sort((a, b) => a.priority.sortWeight.compareTo(b.priority.sortWeight));
    return result;
  });
});
