import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryRadarChart extends StatelessWidget {
  final Map<String, double> categories;

  const CategoryRadarChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Get top 5 categories
    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    // Need at least 3 for a valid radar shape, cap at 6 to avoid clutter
    final topCategories = sortedCategories.take(6).toList();
    if (topCategories.length < 3) return const SizedBox.shrink();

    final maxVal = topCategories.first.value.abs();
    if (maxVal == 0) return const SizedBox.shrink();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Spending Footprint',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: RadarChart(
              RadarChartData(
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: const BorderSide(color: Colors.transparent),
                tickCount: 3,
                ticksTextStyle:
                    const TextStyle(color: Colors.transparent, fontSize: 10),
                tickBorderData: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                  width: 1,
                  style: BorderStyle.solid,
                ),
                gridBorderData: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                  width: 1,
                ),
                radarShape: RadarShape.polygon,
                getTitle: (index, angle) {
                  if (index >= topCategories.length) {
                    return const RadarChartTitle(text: '');
                  }
                  final catName = topCategories[index].key;
                  // Truncate long names slightly
                  final displayName = catName.length > 10
                      ? '${catName.substring(0, 9)}.'
                      : catName;
                  return RadarChartTitle(
                    text: displayName,
                    angle: angle,
                    positionPercentageOffset: 0.1,
                  );
                },
                titleTextStyle: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
                dataSets: [
                  RadarDataSet(
                    fillColor: colorScheme.primary.withValues(alpha: 0.25),
                    borderColor: colorScheme.primary,
                    entryRadius: 4,
                    dataEntries: topCategories.map((e) {
                      return RadarEntry(value: e.value.abs());
                    }).toList(),
                    borderWidth: 2,
                  ),
                ],
              ),
              swapAnimationDuration: const Duration(milliseconds: 250),
            ),
          ),
        ],
      ),
    );
  }
}
