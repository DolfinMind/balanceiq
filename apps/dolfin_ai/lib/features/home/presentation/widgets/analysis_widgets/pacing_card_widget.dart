import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:balance_iq/core/di/injection_container.dart';

class SpendingPacingCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final int daysInPeriod;

  const SpendingPacingCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.daysInPeriod,
  });

  @override
  Widget build(BuildContext context) {
    if (daysInPeriod <= 0 || totalIncome <= 0) return const SizedBox.shrink();

    final safeDailyLimit = totalIncome / daysInPeriod;
    final currentDailySpend = totalExpense / daysInPeriod;
    final isPacingWell = currentDailySpend <= safeDailyLimit;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currencyCubit = sl<CurrencyCubit>();

    final iconColor =
        isPacingWell ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);
    final icon = isPacingWell ? LucideIcons.check : LucideIcons.info;

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
                  'Spending Pacing',
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
                      const TextSpan(text: 'You are spending '),
                      TextSpan(
                        text:
                            '${currencyCubit.formatAmount(currentDailySpend)}/day',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isPacingWell
                              ? colorScheme.onSurface
                              : const Color(0xFFEF5350),
                        ),
                      ),
                      const TextSpan(
                          text:
                              '. To break even this period, your safe limit is '),
                      TextSpan(
                        text:
                            '${currencyCubit.formatAmount(safeDailyLimit)}/day',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
