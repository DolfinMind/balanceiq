import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:balance_iq/core/di/injection_container.dart';
import 'package:balance_iq/core/strings/dashboard_strings.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BalanceCard extends StatelessWidget {
  final double netBalance;
  final double totalIncome;
  final double totalExpense;
  final String period;

  const BalanceCard({
    super.key,
    required this.netBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currencyCubit = sl<CurrencyCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Net Balance — large centered amount
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Text(
                  GetIt.I<DashboardStrings>().netBalance,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyCubit.formatAmount(netBalance),
                  style: textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: -1.0,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Single card: Total Balance | Total Expense
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left: Total Income
                  Expanded(
                    child: _buildHalf(
                      context,
                      label: GetIt.I<DashboardStrings>().totalIncome,
                      amount: currencyCubit.formatAmount(totalIncome),
                    ),
                  ),
                  // Vertical divider
                  Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                  // Right: Total Expense
                  Expanded(
                    child: _buildHalf(
                      context,
                      label: GetIt.I<DashboardStrings>().totalExpense,
                      amount: currencyCubit.formatAmount(totalExpense),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHalf(
    BuildContext context, {
    required String label,
    required String amount,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
