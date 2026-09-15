import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/task_provider.dart';
import '../../widgets/common/staggered_list_item.dart';
import '../../widgets/common/state_widgets.dart';
import '../../widgets/tasks/task_card.dart';
import '../../widgets/tasks/tasks_curved_header.dart';

extension on TaskFilter {
  String get label {
    switch (this) {
      case TaskFilter.all:
        return 'Todas';
      case TaskFilter.today:
        return 'Hoje';
      case TaskFilter.pending:
        return 'Pendentes';
      case TaskFilter.completed:
        return 'Concluídas';
      case TaskFilter.highPriority:
        return 'Alta prioridade';
    }
  }
}

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredTasksProvider);
    final currentFilter = ref.watch(taskFilterProvider);
    final allTasksAsync = ref.watch(taskListProvider);
    final allTasks = allTasksAsync.value ?? [];
    final completedCount = allTasks.where((t) => t.completed).length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Tarefas'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/new'),
        child: const Icon(CupertinoIcons.add),
      ),
      body: Column(
        children: [
          TasksCurvedHeader(completed: completedCount, total: allTasks.length),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '🔎 Buscar tarefa...',
                isDense: true,
              ),
              onChanged: (value) => ref.read(taskSearchQueryProvider.notifier).state = value,
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: TaskFilter.values.map((filter) {
                final selected = filter == currentFilter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(filter.label),
                    selected: selected,
                    onSelected: (_) => ref.read(taskFilterProvider.notifier).state = filter,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filteredAsync.when(
              loading: () => const LoadingState(),
              error: (error, stack) => ErrorState(
                onRetry: () => ref.read(taskListProvider.notifier).refresh(),
              ),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const EmptyState(
                    icon: CupertinoIcons.checkmark_alt_circle,
                    message: 'Nenhuma tarefa encontrada para este filtro.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(taskListProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return StaggeredListItem(
                        index: index,
                        child: TaskCard(
                          task: task,
                          onToggle: () => ref.read(taskListProvider.notifier).toggleCompleted(task),
                          onTap: () => context.push('/tasks/${task.id}/edit'),
                          onDelete: () => ref.read(taskListProvider.notifier).deleteTask(task.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
