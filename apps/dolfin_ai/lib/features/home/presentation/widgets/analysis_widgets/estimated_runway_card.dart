import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EstimatedRunwayCard extends StatelessWidget {
  final double netBalance;
  final double totalExpense;
  final int daysInPeriod;

  const EstimatedRunwayCard({
    super.key,
    required this.netBalance,
    required this.totalExpense,
    required this.daysInPeriod,
  });

  @override
  Widget build(BuildContext context) {
    if (daysInPeriod <= 0 || netBalance <= 0 || totalExpense <= 0) {
      return const SizedBox.shrink();
    }

    final currentDailySpend = totalExpense / daysInPeriod;
    final runwayDays = (netBalance / currentDailySpend).floor();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Determine health based on runway
    final isCritical = runwayDays < 30; // less than a month
    final isWarning = runwayDays >= 30 && runwayDays < 90; // 1-3 months
    // isHealthy is >= 90 days (3+ months Emergency fund rule of thumb)

    Color iconColor;
    IconData icon;
    if (isCritical) {
      iconColor = const Color(0xFFEF5350); // Red
      icon = LucideIcons.siren;
    } else if (isWarning) {
      iconColor = const Color(0xFFFFA726); // Orange
      icon = LucideIcons.triangleAlert;
    } else {
      iconColor = const Color(0xFF4CAF50); // Green
      icon = LucideIcons.shieldCheck;
    }

    String runwayText;
    if (runwayDays > 365) {
      final years = (runwayDays / 365).toStringAsFixed(1);
      runwayText = '$years years';
    } else if (runwayDays > 60) {
      final months = (runwayDays / 30).floor();
      runwayText = '$months months';
    } else {
      runwayText = '$runwayDays days';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Runway',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(
                          text:
                              'At your current spending rate, your total balance will last approximately '),
                      TextSpan(
                        text: runwayText,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: iconColor,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
