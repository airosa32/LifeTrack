import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/category_icons.dart';
import '../../core/utils/validators.dart';
import '../../models/category.dart';
import '../../models/financial_alert.dart';
import '../../providers/alert_provider.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/state_widgets.dart';

class AlertsSettingsScreen extends ConsumerWidget {
  const AlertsSettingsScreen({super.key});

  Future<void> _openCreateDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    AlertType type = AlertType.minimumBalance;
    String? categoryId;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final categories = ref.read(categoryListProvider).value ?? const <Category>[];
            final expenseCategories = categories.where((c) => c.type == CategoryType.expense).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Novo alerta', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Nome do alerta',
                        controller: nameController,
                        validator: Validators.requiredField,
                      ),
                      const SizedBox(height: 16),
                      Text('Tipo', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AlertType.values.map((t) {
                          return ChoiceChip(
                            label: Text(t.label),
                            selected: type == t,
                            onSelected: (_) => setModalState(() => type = t),
                          );
                        }).toList(),
                      ),
                      if (type == AlertType.categoryLimit) ...[
                        const SizedBox(height: 16),
                        Text('Categoria', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: expenseCategories.map((c) {
                            return ChoiceChip(
                              avatar: Icon(
                                CategoryIconRegistry.resolve(c.iconKey),
                                size: 16,
                                color: categoryId == c.id ? Colors.white : c.color,
                              ),
                              label: Text(c.name),
                              selected: categoryId == c.id,
                              selectedColor: c.color,
                              labelStyle: TextStyle(color: categoryId == c.id ? Colors.white : null),
                              onSelected: (_) => setModalState(() => categoryId = c.id),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      AppTextField(
                        label: type == AlertType.balancePercentage ? 'Percentual (%)' : 'Valor (R\$)',
                        controller: valueController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: Validators.positiveAmount,
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'Salvar alerta',
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          if (type == AlertType.categoryLimit && categoryId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Selecione uma categoria.')),
                            );
                            return;
                          }
                          final alert = FinancialAlert(
                            id: const Uuid().v4(),
                            name: nameController.text.trim(),
                            type: type,
                            value: Validators.parseAmount(valueController.text),
                            categoryId: categoryId,
                          );
                          await ref.read(alertListProvider.notifier).addAlert(alert);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, FinancialAlert alert) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir alerta?'),
        content: Text('"${alert.name}" será removido.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(alertListProvider.notifier).deleteAlert(alert.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateDialog(context, ref),
        child: const Icon(CupertinoIcons.add),
      ),
      body: alertsAsync.when(
        loading: () => const LoadingState(),
        error: (_, __) => const ErrorState(),
        data: (alerts) {
          if (alerts.isEmpty) {
            return const EmptyState(
              icon: CupertinoIcons.bell_slash,
              message: 'Nenhuma regra de alerta configurada.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alert.name, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            alert.type.label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: alert.active,
                      onChanged: (_) => ref.read(alertListProvider.notifier).toggleActive(alert),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.delete),
                      onPressed: () => _confirmDelete(context, ref, alert),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
