import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:balance_iq/core/di/injection_container.dart';
import 'package:balance_iq/features/home/domain/entities/transaction.dart';
import 'package:balance_iq/features/home/presentation/utils/category_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final int index;
  final Function(Transaction) onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final catColor = CategoryStyles.colorFor(transaction.category);

    final staggerDelay = Duration(milliseconds: 20 * (index < 6 ? index : 6));

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(transaction),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Category icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    CategoryStyles.iconFor(transaction.category),
                    size: 18,
                    color: catColor,
                  ),
                ),
                const SizedBox(width: 10),

                // Category + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.category,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${DateFormat('MMM d').format(transaction.transactionDate)} • ${transaction.description}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  sl<CurrencyCubit>().formatAmountWithSign(transaction.amount,
                      isIncome: isIncome),
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color:
                        isIncome ? colorScheme.primary : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: staggerDelay)
        .fadeIn(duration: 300.ms, curve: Curves.easeOutQuad)
        .slideY(
            begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }
}
