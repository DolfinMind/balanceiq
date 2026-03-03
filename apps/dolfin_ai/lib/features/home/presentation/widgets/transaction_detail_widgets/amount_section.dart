import 'package:dolfin_core/constants/app_strings.dart';
import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:balance_iq/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Displays the transaction amount with colored styling
class AmountSection extends StatelessWidget {
  final double amount;
  final bool isIncome;

  static const Color _incomeColor = Color(0xFF34d399); // Soft Emerald
  static const Color _expenseColor = Color(0xFFf87171); // Soft Red

  const AmountSection({
    super.key,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isIncome ? AppStrings.common.income : AppStrings.common.expense,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
          Text(
            sl<CurrencyCubit>()
                .formatAmountWithSign(amount, isIncome: isIncome),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? _incomeColor : _expenseColor,
                ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .scaleXY(begin: 0.95, end: 1, delay: 200.ms, duration: 400.ms);
  }
}
