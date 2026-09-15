import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../core/utils/domain_icons.dart';
import '../../core/utils/formatters.dart';
import '../../models/task.dart';
import '../common/animated_task_check.dart';
import '../common/app_card.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  Color _priorityColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (task.priority) {
      case TaskPriority.urgent:
        return const Color(0xFFD64545);
      case TaskPriority.high:
        return const Color(0xFFE0A32E);
      case TaskPriority.medium:
        return scheme.primary;
      case TaskPriority.low:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(CupertinoIcons.delete, color: scheme.onErrorContainer),
      ),
      onDismissed: (_) => onDelete(),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            AnimatedTaskCheck(
              checked: task.completed,
              color: _priorityColor(context),
              onTap: onToggle,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: textTheme.titleMedium?.copyWith(
                      decoration: task.completed ? TextDecoration.lineThrough : null,
                      color: task.completed ? scheme.onSurfaceVariant : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(DomainIcons.priority(task.priority), size: 14, color: _priorityColor(context)),
                      const SizedBox(width: 4),
                      Text(
                        task.priority.label,
                        style: textTheme.labelSmall?.copyWith(color: _priorityColor(context)),
                      ),
                      const SizedBox(width: 10),
                      Icon(CupertinoIcons.calendar, size: 12, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        Formatters.shortDate(task.dueDate),
                        style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
