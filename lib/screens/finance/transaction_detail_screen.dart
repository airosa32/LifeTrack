import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/formatters.dart';
import '../../models/transaction.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/state_widgets.dart';
import '../../widgets/finance/category_avatar.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir lançamento?'),
        content: const Text('Esta ação não poderá ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(transactionListProvider.notifier).deleteTransaction(transactionId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Lançamento excluído.')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: transactionsAsync.when(
        loading: () => const LoadingState(),
        error: (_, __) => const ErrorState(),
        data: (transactions) {
          final transaction = transactions.where((t) => t.id == transactionId).firstOrNull;
          if (transaction == null) {
            return const EmptyState(message: 'Lançamento não encontrado.');
          }
          final categories = categoriesAsync.value ?? [];
          final category = categories.where((c) => c.id == transaction.categoryId).firstOrNull;
          final isIncome = transaction.type == TransactionType.income;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(child: CategoryAvatar(category: category, size: 64)),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  Formatters.signedCurrency(transaction.amount, isIncome: isIncome),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: isIncome ? const Color(0xFF2E9E5B) : const Color(0xFFD64545),
                      ),
                ),
              ),
              const SizedBox(height: 28),
              _DetailRow(
                icon: CupertinoIcons.tag,
                label: 'Categoria',
                value: category?.name ?? 'Sem categoria',
              ),
              _DetailRow(
                icon: CupertinoIcons.calendar,
                label: 'Data',
                value: Formatters.shortDate(transaction.date),
              ),
              if (transaction.paymentMethod != null)
                _DetailRow(
                  icon: CupertinoIcons.creditcard,
                  label: 'Pagamento',
                  value: transaction.paymentMethod!.label,
                ),
              if (transaction.isRecurring)
                _DetailRow(
                  icon: CupertinoIcons.repeat,
                  label: 'Recorrência',
                  value: transaction.recurrence.label,
                ),
              if (transaction.note != null && transaction.note!.isNotEmpty)
                _DetailRow(
                  icon: CupertinoIcons.text_alignleft,
                  label: 'Observação',
                  value: transaction.note!,
                ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Editar',
                outlined: true,
                icon: CupertinoIcons.pencil,
                onPressed: () => context.push('/finance/${transaction.id}/edit'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Excluir',
                icon: CupertinoIcons.delete,
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
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
