import 'dart:math' as math;

import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../presentation/utils/category_styles.dart';

class CategoryBarChart extends StatelessWidget {
  final Map<String, double> categories;

  const CategoryBarChart({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Process data: Top 5 categories
    final sortedEntries = categories.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    final topEntries = sortedEntries.take(5).toList();
    final maxAmount = topEntries.isEmpty ? 0.0 : topEntries.first.value.abs();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: RepaintBoundary(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Categories',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(
                  Icons.bar_chart_rounded,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) =>
                          colorScheme.inverseSurface.withValues(alpha: 0.9),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final entry = topEntries[group.x.toInt()];
                        return BarTooltipItem(
                          entry.key,
                          TextStyle(
                            color: colorScheme.onInverseSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '\n${sl<CurrencyCubit>().formatAmount(entry.value.abs())}',
                              style: TextStyle(
                                color: colorScheme.onInverseSurface
                                    .withValues(alpha: 0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= topEntries.length) {
                            return const SizedBox.shrink();
                          }
                          final entry = topEntries[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              entry.key.length > 4
                                  ? '${entry.key.substring(0, 3)}..'
                                  : entry.key,
                              style: textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).hintColor,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: topEntries.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value.abs(),
                          color: CategoryStyles.colorFor(entry.value.key),
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxAmount * 1.05,
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  maxY: maxAmount * 1.05,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
