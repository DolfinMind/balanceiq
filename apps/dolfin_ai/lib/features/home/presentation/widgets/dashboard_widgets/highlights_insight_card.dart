import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:balance_iq/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Combined biggest income & expense insight card — compact, single card.
class HighlightsInsightCard extends StatelessWidget {
  final double biggestIncomeAmount;
  final String biggestIncomeDescription;
  final double biggestExpenseAmount;
  final String biggestExpenseDescription;

  const HighlightsInsightCard({
    super.key,
    required this.biggestIncomeAmount,
    required this.biggestIncomeDescription,
    required this.biggestExpenseAmount,
    required this.biggestExpenseDescription,
  });

  @override
  Widget build(BuildContext context) {
    final hasIncome = biggestIncomeAmount > 0;
    final hasExpense = biggestExpenseAmount > 0;

    if (!hasIncome && !hasExpense) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currencyCubit = sl<CurrencyCubit>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.sparkles, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Highlights',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Biggest Income
          if (hasIncome) ...[
            _insightRow(
              context,
              icon: LucideIcons.trendingUp,
              iconColor: const Color(0xFF5B8DEF),
              label: 'Top Income',
              description: biggestIncomeDescription.isEmpty
                  ? 'Income'
                  : biggestIncomeDescription,
              amount: currencyCubit.formatAmount(biggestIncomeAmount),
              prefix: '+',
              amountColor: colorScheme.primary,
            ),
          ],

          if (hasIncome && hasExpense)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),

          // Biggest Expense
          if (hasExpense) ...[
            _insightRow(
              context,
              icon: LucideIcons.trendingDown,
              iconColor: const Color(0xFFF97066),
              label: 'Top Expense',
              description: biggestExpenseDescription,
              amount: currencyCubit.formatAmount(biggestExpenseAmount),
              prefix: '-',
              amountColor: colorScheme.onSurface,
            ),
          ],
        ],
      ),
    );
  }

  Widget _insightRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String description,
    required String amount,
    required String prefix,
    required Color amountColor,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Text(
          '$prefix$amount',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: amountColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
