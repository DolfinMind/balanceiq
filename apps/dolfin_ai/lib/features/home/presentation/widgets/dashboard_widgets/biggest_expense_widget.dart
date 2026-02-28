import 'package:balance_iq/core/strings/dashboard_strings.dart';
import 'package:balance_iq/core/icons/app_icons.dart';
import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:balance_iq/core/di/injection_container.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';

class BiggestExpenseWidget extends StatelessWidget {
  final double amount;
  final String description;
  final String category;
  final String account;

  const BiggestExpenseWidget({
    super.key,
    required this.amount,
    required this.description,
    required this.category,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF97066).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: GetIt.I<AppIcons>().dashboard.expense(
                  size: 24,
                  color: const Color(0xFFF97066),
                ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  GetIt.I<DashboardStrings>().biggestExpense,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Amount
          Text(
            sl<CurrencyCubit>().formatAmountWithSign(amount, isIncome: false),
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
