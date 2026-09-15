import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/financial_alert.dart';
import '../../providers/alert_provider.dart';
import '../../widgets/alerts/alert_card.dart';
import '../../widgets/common/section_title.dart';
import '../../widgets/common/state_widgets.dart';

class AlertCenterScreen extends ConsumerWidget {
  const AlertCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(alertResultsProvider);
    final readIds = ref.watch(readAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Central de Alertas'),
        actions: [
          resultsAsync.maybeWhen(
            data: (results) => results.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () => ref
                        .read(readAlertsProvider.notifier)
                        .markAllAsRead(results.map((r) => r.alert.id)),
                    child: const Text('Marcar tudo como lido'),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: resultsAsync.when(
        loading: () => const LoadingState(),
        error: (_, __) => const ErrorState(),
        data: (results) {
          if (results.isEmpty) {
            return const EmptyState(
              icon: CupertinoIcons.bell_slash,
              message: 'Nenhum alerta no momento. Tudo tranquilo por aqui.',
            );
          }

          final unread = results.where((r) => !readIds.contains(r.alert.id)).toList();
          final read = results.where((r) => readIds.contains(r.alert.id)).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (unread.isNotEmpty) ...[
                const SectionTitle(title: 'Novos'),
                ...unread.map((result) => _AlertInboxItem(result: result, isRead: false)),
                const SizedBox(height: 12),
              ],
              if (read.isNotEmpty) ...[
                const SectionTitle(title: 'Lidos'),
                ...read.map((result) => _AlertInboxItem(result: result, isRead: true)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AlertInboxItem extends ConsumerWidget {
  final AlertResult result;
  final bool isRead;

  const _AlertInboxItem({required this.result, required this.isRead});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(result.alert.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final notifier = ref.read(readAlertsProvider.notifier);
        if (isRead) {
          notifier.markAsUnread(result.alert.id);
        } else {
          notifier.markAsRead(result.alert.id);
        }
        return false; // apenas alterna o estado, não remove o item da lista
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isRead ? CupertinoIcons.arrow_uturn_left : CupertinoIcons.checkmark_alt,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      child: Opacity(
        opacity: isRead ? 0.55 : 1,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AlertCard(result: result),
        ),
      ),
    );
  }
}
