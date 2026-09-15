import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/domain_icons.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final String? taskId;

  const TaskFormScreen({super.key, this.taskId});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  TaskPriority _priority = TaskPriority.medium;
  bool _loading = false;
  Task? _editingTask;

  bool get isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final tasks = ref.read(taskListProvider).value ?? [];
      final task = tasks.where((t) => t.id == widget.taskId).firstOrNull;
      if (task != null) {
        _editingTask = task;
        _titleController.text = task.title;
        _descriptionController.text = task.description ?? '';
        _dueDate = task.dueDate;
        _priority = task.priority;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final now = DateTime.now();
    try {
      if (isEditing && _editingTask != null) {
        final updated = _editingTask!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _dueDate,
          priority: _priority,
          updatedAt: now,
        );
        await ref.read(taskListProvider.notifier).updateTask(updated);
      } else {
        final task = Task(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _dueDate,
          priority: _priority,
          createdAt: now,
          updatedAt: now,
        );
        await ref.read(taskListProvider.notifier).addTask(task);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? '✓ Alterações salvas.' : '✓ Tarefa criada.')),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível salvar.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: const Text('Esta ação não poderá ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmed == true && _editingTask != null) {
      await ref.read(taskListProvider.notifier).deleteTask(_editingTask!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar tarefa' : 'Criar tarefa'),
        actions: [
          if (isEditing)
            IconButton(icon: const Icon(CupertinoIcons.delete), onPressed: _delete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              label: 'Título',
              controller: _titleController,
              validator: Validators.requiredField,
              prefixIcon: const Icon(CupertinoIcons.textformat),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Descrição',
              controller: _descriptionController,
              maxLines: 3,
              prefixIcon: const Icon(CupertinoIcons.text_alignleft),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Data',
              controller: TextEditingController(text: Formatters.shortDate(_dueDate)),
              readOnly: true,
              onTap: _pickDate,
              prefixIcon: const Icon(CupertinoIcons.calendar),
              suffixIcon: const Icon(CupertinoIcons.chevron_down, size: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(CupertinoIcons.flag, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text('Prioridade', style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskPriority.values.map((priority) {
                return ChoiceChip(
                  avatar: Icon(DomainIcons.priority(priority), size: 18),
                  label: Text(priority.label),
                  selected: _priority == priority,
                  onSelected: (_) => setState(() => _priority = priority),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            AppButton(
              label: isEditing ? 'Salvar alterações' : 'Criar tarefa',
              loading: _loading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
