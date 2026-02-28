import 'package:balance_iq/core/strings/dashboard_strings.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';

class FinancialRatiosWidget extends StatelessWidget {
  final double expenseRatio;
  final double savingsRate;

  const FinancialRatiosWidget({
    super.key,
    required this.expenseRatio,
    required this.savingsRate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildRatioCard(
            context,
            title: GetIt.I<DashboardStrings>().expenseRatio,
            value: expenseRatio,
            backgroundColor: const Color(0xFFF97066).withValues(alpha: 0.3),
            textColor: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildRatioCard(
            context,
            title: GetIt.I<DashboardStrings>().savingsRate,
            value: savingsRate,
            backgroundColor: const Color(0xFF5B8DEF).withValues(alpha: 0.3),
            textColor: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildRatioCard(
    BuildContext context, {
    required String title,
    required double value,
    required Color backgroundColor,
    required Color textColor,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${value.toStringAsFixed(1)}%',
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
