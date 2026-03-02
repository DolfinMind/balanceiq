import 'package:flutter/material.dart';
import '../../../domain/entities/dashbaord_summary.dart';

class SpendingHeatmapWidget extends StatelessWidget {
  final List<SpendingTrendPoint> spendingTrend;

  const SpendingHeatmapWidget({
    super.key,
    required this.spendingTrend,
  });

  @override
  Widget build(BuildContext context) {
    if (spendingTrend.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Filter to last 28 days for a perfect 4-week grid to look good
    // Or just use the data as provided if it fits nicely.
    final sortedTrend = List<SpendingTrendPoint>.from(spendingTrend)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Limit to the last ~35 points for a 5-week heatmap
    final recentPoints = sortedTrend.length > 35
        ? sortedTrend.sublist(sortedTrend.length - 35)
        : sortedTrend;

    if (recentPoints.isEmpty) return const SizedBox.shrink();

    double maxSpend = 0;
    for (var p in recentPoints) {
      if (p.amount > maxSpend) maxSpend = p.amount;
    }

    // Grid config
    const int crossAxisCount = 7; // days in a week (rows)
    final int columnCount = (recentPoints.length / crossAxisCount).ceil();

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
          Text(
            'Spending Intensity',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your daily spending footprint over the period. Darker blocks mean higher spending.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 16),
          // We lay this out visually as columns of weeks
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Y-Axis labels (optional, e.g., Mon, Wed, Fri) - skipping for cleaner look
                for (int col = 0; col < columnCount; col++)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Column(
                      children: List.generate(crossAxisCount, (row) {
                        final index = col * crossAxisCount + row;
                        if (index >= recentPoints.length) {
                          return const SizedBox(
                              width: 14, height: 14); // Empty placeholder
                        }

                        final point = recentPoints[index];
                        final intensity =
                            maxSpend > 0 ? (point.amount / maxSpend) : 0.0;

                        // Color scaling:
                        // 0 = subtle background
                        // 0.1 - 0.3 = light primary
                        // 0.3 - 0.7 = medium primary
                        // 0.7 - 1.0 = dark primary
                        Color cellColor;
                        if (intensity == 0) {
                          cellColor =
                              colorScheme.outlineVariant.withValues(alpha: 0.1);
                        } else if (intensity < 0.2) {
                          cellColor =
                              colorScheme.primary.withValues(alpha: 0.3);
                        } else if (intensity < 0.5) {
                          cellColor =
                              colorScheme.primary.withValues(alpha: 0.6);
                        } else if (intensity < 0.8) {
                          cellColor =
                              colorScheme.primary.withValues(alpha: 0.85);
                        } else {
                          cellColor = colorScheme.primary;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Tooltip(
                            message:
                                '${point.date.month}/${point.date.day}: \$${point.amount.toStringAsFixed(0)}',
                            preferBelow: false,
                            decoration: BoxDecoration(
                              color: colorScheme.inverseSurface
                                  .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: textTheme.labelSmall
                                ?.copyWith(color: colorScheme.onInverseSurface),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: cellColor,
                                borderRadius: BorderRadius.circular(3),
                                border: intensity == 0
                                    ? Border.all(
                                        color: colorScheme.outlineVariant
                                            .withValues(alpha: 0.2),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less',
                  style: textTheme.labelSmall?.copyWith(
                      fontSize: 10, color: colorScheme.onSurfaceVariant)),
              const SizedBox(width: 4),
              _buildLegendBox(
                  colorScheme.outlineVariant.withValues(alpha: 0.1)),
              const SizedBox(width: 4),
              _buildLegendBox(colorScheme.primary.withValues(alpha: 0.3)),
              const SizedBox(width: 4),
              _buildLegendBox(colorScheme.primary.withValues(alpha: 0.6)),
              const SizedBox(width: 4),
              _buildLegendBox(colorScheme.primary.withValues(alpha: 0.85)),
              const SizedBox(width: 4),
              _buildLegendBox(colorScheme.primary),
              const SizedBox(width: 4),
              Text('More',
                  style: textTheme.labelSmall?.copyWith(
                      fontSize: 10, color: colorScheme.onSurfaceVariant)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
