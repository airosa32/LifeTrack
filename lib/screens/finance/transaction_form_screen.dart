import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/domain_icons.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/finance/category_chip.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final bool isIncome;
  final String? transactionId;

  const TransactionFormScreen({
    super.key,
    required this.isIncome,
    this.transactionId,
  });

  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  String? _categoryId;
  PaymentMethod _paymentMethod = PaymentMethod.pix;
  RecurrenceType _recurrence = RecurrenceType.none;
  bool _loading = false;
  Transaction? _editingTransaction;

  bool get isEditing => widget.transactionId != null;
  bool get isIncome => _editingTransaction?.type == TransactionType.income || (!isEditing && widget.isIncome);

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final transactions = ref.read(transactionListProvider).value ?? [];
      final t = transactions.where((e) => e.id == widget.transactionId).firstOrNull;
      if (t != null) {
        _editingTransaction = t;
        _descriptionController.text = t.description;
        _amountController.text = t.amount.toStringAsFixed(2).replaceAll('.', ',');
        _noteController.text = t.note ?? '';
        _date = t.date;
        _categoryId = t.categoryId;
        _paymentMethod = t.paymentMethod ?? PaymentMethod.pix;
        _recurrence = t.recurrence;
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria.')),
      );
      return;
    }

    setState(() => _loading = true);
    final amount = Validators.parseAmount(_amountController.text);

    try {
      if (isEditing && _editingTransaction != null) {
        final updated = _editingTransaction!.copyWith(
          description: _descriptionController.text.trim(),
          amount: amount,
          categoryId: _categoryId,
          date: _date,
          paymentMethod: isIncome ? null : _paymentMethod,
          note: _noteController.text.trim(),
        );
        await ref.read(transactionListProvider.notifier).updateTransaction(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✓ Alterações salvas.')),
          );
        }
      } else {
        final transaction = Transaction(
          id: const Uuid().v4(),
          description: _descriptionController.text.trim(),
          amount: amount,
          type: isIncome ? TransactionType.income : TransactionType.expense,
          categoryId: _categoryId!,
          date: _date,
          paymentMethod: isIncome ? null : _paymentMethod,
          note: _noteController.text.trim(),
          recurrence: _recurrence,
        );
        final generatedCount = await ref.read(transactionListProvider.notifier).addTransaction(transaction);

        if (mounted) {
          final baseMessage = isIncome ? '✓ Entrada adicionada.' : '✓ Gasto registrado.';
          final message = generatedCount > 0
              ? '$baseMessage $generatedCount ocorrências futuras foram criadas.'
              : baseMessage;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        }
      }

      if (mounted) Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final wantedType = isIncome ? CategoryType.income : CategoryType.expense;

    return Scaffold(
      appBar: AppBar(title: Text(isIncome ? 'Nova entrada' : 'Novo gasto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              label: 'Descrição',
              controller: _descriptionController,
              validator: Validators.requiredField,
              prefixIcon: const Icon(CupertinoIcons.textformat),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Valor',
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.positiveAmount,
              prefixIcon: const Icon(CupertinoIcons.money_dollar_circle),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Data',
              controller: TextEditingController(text: Formatters.shortDate(_date)),
              readOnly: true,
              onTap: _pickDate,
              prefixIcon: const Icon(CupertinoIcons.calendar),
              suffixIcon: const Icon(CupertinoIcons.chevron_down, size: 16),
            ),
            const SizedBox(height: 20),
            _FieldLabel(icon: CupertinoIcons.tag, text: 'Categoria'),
            const SizedBox(height: 8),
            categoriesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(),
              ),
              error: (_, __) => const Text('Não foi possível carregar categorias.'),
              data: (categories) {
                final filtered = categories.where((c) => c.type == wantedType).toList();
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: filtered.map((category) {
                    return CategoryChip(
                      category: category,
                      selected: _categoryId == category.id,
                      onTap: () => setState(() => _categoryId = category.id),
                    );
                  }).toList(),
                );
              },
            ),
            if (!isIncome) ...[
              const SizedBox(height: 20),
              _FieldLabel(icon: CupertinoIcons.creditcard, text: 'Forma de pagamento'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PaymentMethod.values.map((method) {
                  return ChoiceChip(
                    avatar: Icon(DomainIcons.paymentMethod(method), size: 18),
                    label: Text(method.label),
                    selected: _paymentMethod == method,
                    onSelected: (_) => setState(() => _paymentMethod = method),
                  );
                }).toList(),
              ),
            ],
            if (!isEditing) ...[
              const SizedBox(height: 20),
              _FieldLabel(icon: CupertinoIcons.repeat, text: 'Repetir'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: RecurrenceType.values.map((type) {
                  return ChoiceChip(
                    avatar: Icon(DomainIcons.recurrence(type), size: 18),
                    label: Text(type.label),
                    selected: _recurrence == type,
                    onSelected: (_) => setState(() => _recurrence = type),
                  );
                }).toList(),
              ),
              if (_recurrence != RecurrenceType.none) ...[
                const SizedBox(height: 10),
                _RecurrenceHint(recurrence: _recurrence),
              ],
            ],
            const SizedBox(height: 16),
            AppTextField(
              label: 'Observação (opcional)',
              controller: _noteController,
              maxLines: 2,
              prefixIcon: const Icon(CupertinoIcons.text_alignleft),
            ),
            const SizedBox(height: 28),
            AppButton(
              label: isEditing ? 'Salvar alterações' : (isIncome ? 'Adicionar entrada' : 'Registrar gasto'),
              loading: _loading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FieldLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}

class _RecurrenceHint extends StatelessWidget {
  final RecurrenceType recurrence;

  const _RecurrenceHint({required this.recurrence});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final count = switch (recurrence) {
      RecurrenceType.daily => 14,
      RecurrenceType.weekly => 8,
      RecurrenceType.monthly => 12,
      RecurrenceType.none => 0,
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.info_circle, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Serão criados automaticamente $count lançamentos futuros com esta recorrência.',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
