import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../core/utils/domain_icons.dart';
import '../../core/utils/formatters.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../common/app_card.dart';
import 'category_avatar.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? const Color(0xFF2E9E5B) : const Color(0xFFD64545);

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          CategoryAvatar(category: category, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        transaction.description,
                        style: textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (transaction.isRecurring) ...[
                      const SizedBox(width: 6),
                      Icon(CupertinoIcons.repeat, size: 14, color: scheme.onSurfaceVariant),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      category?.name ?? 'Sem categoria',
                      style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    if (transaction.paymentMethod != null) ...[
                      const SizedBox(width: 6),
                      Icon(
                        DomainIcons.paymentMethod(transaction.paymentMethod!),
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            Formatters.signedCurrency(transaction.amount, isIncome: isIncome),
            style: textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
