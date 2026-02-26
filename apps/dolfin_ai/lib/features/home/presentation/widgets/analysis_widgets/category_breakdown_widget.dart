import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:balance_iq/core/di/injection_container.dart';
import 'package:balance_iq/features/home/presentation/pages/transactions_page.dart';
import 'package:balance_iq/core/strings/dashboard_strings.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';

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

    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Calculate total for percentage
    final total = sortedCategories.fold<double>(
      0,
      (sum, entry) => sum + entry.value.abs(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                GetIt.I<DashboardStrings>().spendingByCategory,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${sortedCategories.length}',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedCategories.length,
            itemBuilder: (context, index) {
              final entry = sortedCategories[index];
              final percentage =
                  total > 0 ? (entry.value.abs() / total * 100) : 0.0;

              return Padding(
                padding: EdgeInsets.only(
                  right: index == sortedCategories.length - 1 ? 0 : 12,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            TransactionsPage(category: entry.key),
                      ),
                    );
                  },
                  child: _buildCategoryCard(
                    context,
                    categoryName: entry.key,
                    amount: entry.value,
                    percentage: percentage,
                    index: index,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String categoryName,
    required double amount,
    required double percentage,
    required int index,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = _getCategoryColor(categoryName, index);
    final icon = _getCategoryIcon(categoryName);

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: textTheme.labelSmall?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.2,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  sl<CurrencyCubit>().formatAmount(amount.abs()),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: -0.3,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category, int index) {
    final name = category.toLowerCase();
    if (name.contains('food') || name.contains('dining')) {
      return const Color(0xFFFF9800);
    }
    if (name.contains('transport')) {
      return const Color(0xFF2196F3);
    }
    if (name.contains('shop')) {
      return const Color(0xFFE91E63);
    }
    if (name.contains('bill') || name.contains('util')) {
      return const Color(0xFF00BCD4);
    }
    if (name.contains('rent') || name.contains('house')) {
      return const Color(0xFF3F51B5);
    }
    if (name.contains('health') || name.contains('med')) {
      return const Color(0xFFF44336);
    }
    if (name.contains('entertain')) {
      return const Color(0xFF9C27B0);
    }

    final colors = [
      const Color(0xFF009688),
      const Color(0xFFCDDC39),
      const Color(0xFFFFC107),
      const Color(0xFFFF5722),
      const Color(0xFF03A9F4),
    ];
    return colors[index % colors.length];
  }

  IconData _getCategoryIcon(String category) {
    final name = category.toLowerCase();
    if (name.contains('food') || name.contains('dining')) {
      return Icons.restaurant_rounded;
    }
    if (name.contains('transport')) {
      return Icons.directions_car_rounded;
    }
    if (name.contains('shop')) {
      return Icons.shopping_bag_rounded;
    }
    if (name.contains('bill') || name.contains('util')) {
      return Icons.receipt_long_rounded;
    }
    if (name.contains('rent') || name.contains('house')) {
      return Icons.home_rounded;
    }
    if (name.contains('health') || name.contains('med')) {
      return Icons.medical_services_rounded;
    }
    if (name.contains('entertain')) {
      return Icons.movie_rounded;
    }

    return Icons.category_rounded;
  }
}
