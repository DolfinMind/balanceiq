import 'package:dolfin_core/constants/app_strings.dart';
import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:balance_iq/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Displays the transaction amount with colored styling
class AmountSection extends StatelessWidget {
  final double amount;
  final bool isIncome;

  static const Color _incomeColor = Color(0xFF10b981);
  static const Color _expenseColor = Color(0xFFef4444);

  const AmountSection({
    super.key,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isIncome
              ? [
                  _incomeColor.withValues(alpha: 0.1),
                  _incomeColor.withValues(alpha: 0.05)
                ]
              : [
                  _expenseColor.withValues(alpha: 0.1),
                  _expenseColor.withValues(alpha: 0.05)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isIncome
              ? _incomeColor.withValues(alpha: 0.2)
              : _expenseColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            isIncome ? AppStrings.common.income : AppStrings.common.expense,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isIncome ? _incomeColor : _expenseColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            sl<CurrencyCubit>()
                .formatAmountWithSign(amount, isIncome: isIncome),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
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
