import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../common/animated_progress_bar.dart';
import '../common/curved_gradient_header.dart';

/// Header curvo (mesmo estilo usado na Dashboard/Finanças/Relatórios)
/// para a aba de Tarefas, mostrando o progresso geral do dia.
class TasksCurvedHeader extends StatelessWidget {
  final int completed;
  final int total;

  const TasksCurvedHeader({super.key, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    final appBarClearance = MediaQuery.paddingOf(context).top + kToolbarHeight;

    return CurvedGradientHeader(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, appBarClearance + 12, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarefas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              Formatters.weekdayDay(DateTime.now()),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  total == 0 ? 'Nenhuma tarefa cadastrada' : '$completed de $total concluídas',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedProgressBar(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
