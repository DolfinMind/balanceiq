import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:balance_iq/core/di/injection_container.dart';
import 'package:balance_iq/features/home/presentation/pages/transactions_page.dart';
import 'package:balance_iq/core/strings/dashboard_strings.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '../../../presentation/utils/category_styles.dart';

class CategoryBreakdownWidget extends StatelessWidget {
  final Map<String, double> categories;

  const CategoryBreakdownWidget({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currencyCubit = sl<CurrencyCubit>();

    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    final total = sorted.fold<double>(0, (sum, e) => sum + e.value.abs());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          GetIt.I<DashboardStrings>().spendingByCategory,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: sorted.asMap().entries.map((mapEntry) {
              final index = mapEntry.key;
              final entry = mapEntry.value;
              final pct = total > 0 ? (entry.value.abs() / total * 100) : 0.0;
              final color = CategoryStyles.colorFor(entry.key);

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          TransactionsPage(category: entry.key),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: index < sorted.length - 1 ? 14 : 0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(0)}%',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            currencyCubit.formatAmount(entry.value.abs()),
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (pct / 100).clamp(0, 1),
                          minHeight: 5,
                          backgroundColor: colorScheme.outlineVariant
                              .withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
