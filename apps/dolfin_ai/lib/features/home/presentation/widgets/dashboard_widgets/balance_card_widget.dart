import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:balance_iq/core/di/injection_container.dart';
import 'package:balance_iq/core/strings/dashboard_strings.dart';
import 'package:balance_iq/core/icons/app_icons.dart';
import 'package:dolfin_ui_kit/theme/app_palette.dart';
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
          // Net Balance Section — clean, flat
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

          // Income and Expense Cards — flat containers
          Row(
            children: [
              Expanded(
                child: _buildIncomeExpenseCard(
                  context,
                  currencyCubit: currencyCubit,
                  iconWidget: GetIt.I<AppIcons>().dashboard.income(size: 14),
                  label: GetIt.I<DashboardStrings>().totalIncome,
                  amount: totalIncome,
                  isIncome: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildIncomeExpenseCard(
                  context,
                  currencyCubit: currencyCubit,
                  iconWidget: GetIt.I<AppIcons>().dashboard.expense(size: 14),
                  label: GetIt.I<DashboardStrings>().totalExpense,
                  amount: totalExpense,
                  isIncome: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseCard(
    BuildContext context, {
    required CurrencyCubit currencyCubit,
    required Widget iconWidget,
    required String label,
    required double amount,
    required bool isIncome,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final iconColor = isIncome
        ? GetIt.instance<AppPalette>().income
        : GetIt.instance<AppPalette>().expense;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    iconColor,
                    BlendMode.srcIn,
                  ),
                  child: iconWidget,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyCubit.formatAmount(amount),
            style: textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
