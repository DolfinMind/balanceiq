import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/di/injection_container.dart';

/// Spending donut chart with category breakdown.
/// Uses fl_chart PieChart with thick segments, spacing, and center label.
class SpendingDonutChart extends StatelessWidget {
  final Map<String, double> categories;
  final double totalExpense;

  const SpendingDonutChart({
    super.key,
    required this.categories,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty || totalExpense <= 0) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currencyCubit = sl<CurrencyCubit>();

    final sortedEntries = categories.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    final total = sortedEntries.fold<double>(
      0,
      (sum, e) => sum + e.value.abs(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Donut chart with center text
          SizedBox(
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 65,
                    startDegreeOffset: -90,
                    sections: _buildSections(sortedEntries, total, textTheme),
                    pieTouchData: PieTouchData(enabled: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
                // Center label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Expense',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyCubit.formatAmount(totalExpense),
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: -0.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Legend — 2-column grid
          Wrap(
            spacing: 8,
            runSpacing: 14,
            children: sortedEntries.asMap().entries.map((mapEntry) {
              final index = mapEntry.key;
              final entry = mapEntry.value;
              final color = _getCategoryColor(entry.key, index);

              return SizedBox(
                width: (MediaQuery.of(context).size.width - 64) / 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 13,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
    List<MapEntry<String, double>> entries,
    double total,
    TextTheme textTheme,
  ) {
    return entries.asMap().entries.map((mapEntry) {
      final index = mapEntry.key;
      final entry = mapEntry.value;
      final percentage = total > 0 ? (entry.value.abs() / total * 100) : 0.0;
      final color = _getCategoryColor(entry.key, index);

      return PieChartSectionData(
        color: color,
        value: entry.value.abs(),
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 45,
        showTitle: percentage >= 5,
        titlePositionPercentageOffset: 0.55,
        titleStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontSize: 12,
          shadows: [
            Shadow(
              blurRadius: 4,
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(String category, int index) {
    final name = category.toLowerCase();
    if (name.contains('food') || name.contains('dining')) {
      return const Color(0xFF4CAF50);
    }
    if (name.contains('grocery')) return const Color(0xFFEF5350);
    if (name.contains('transport')) return const Color(0xFF42A5F5);
    if (name.contains('shop')) return const Color(0xFFFFA726);
    if (name.contains('entertain')) return const Color(0xFFAB47BC);
    if (name.contains('travel')) return const Color(0xFF5C6BC0);
    if (name.contains('bill') ||
        name.contains('util') ||
        name.contains('recharge')) {
      return const Color(0xFF26C6DA);
    }
    if (name.contains('rent') || name.contains('house')) {
      return const Color(0xFF7E57C2);
    }
    if (name.contains('health') || name.contains('med')) {
      return const Color(0xFFEC407A);
    }
    final colors = [
      const Color(0xFFFFCA28),
      const Color(0xFF66BB6A),
      const Color(0xFFFF7043),
      const Color(0xFF29B6F6),
      const Color(0xFFD4E157),
      const Color(0xFF8D6E63),
    ];
    return colors[index % colors.length];
  }
}
