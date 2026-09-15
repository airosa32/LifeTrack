import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/domain_icons.dart';
import '../../models/financial_alert.dart';
import '../common/animated_progress_bar.dart';
import '../common/app_card.dart';

class AlertCard extends StatelessWidget {
  final AlertResult result;

  const AlertCard({super.key, required this.result});

  Color _color(BuildContext context, bool dark) {
    switch (result.level) {
      case AlertLevel.normal:
        return dark ? AppStatusColors.normalDark : AppStatusColors.normal;
      case AlertLevel.attention:
        return dark ? AppStatusColors.attentionDark : AppStatusColors.attention;
      case AlertLevel.critical:
        return dark ? AppStatusColors.criticalDark : AppStatusColors.critical;
    }
  }

  IconData get _levelIcon {
    switch (result.level) {
      case AlertLevel.normal:
        return CupertinoIcons.checkmark_circle_fill;
      case AlertLevel.attention:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case AlertLevel.critical:
        return CupertinoIcons.exclamationmark_octagon_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _color(context, isDark);
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color.withOpacity(0.14), shape: BoxShape.circle),
            child: Icon(DomainIcons.alertType(result.alert.type), size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(result.alert.name, style: textTheme.titleMedium)),
                    Icon(_levelIcon, size: 15, color: color),
                  ],
                ),
                const SizedBox(height: 2),
                Text(result.message, style: textTheme.bodyMedium),
                const SizedBox(height: 10),
                AnimatedProgressBar(
                  value: result.percentage / 100,
                  minHeight: 6,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
