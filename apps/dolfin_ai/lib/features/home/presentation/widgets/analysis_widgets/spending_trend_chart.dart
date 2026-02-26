import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/strings/dashboard_strings.dart';
import '../../../domain/entities/dashbaord_summary.dart';

class SpendingTrendChart extends StatelessWidget {
  final List<SpendingTrendPoint> spendingTrend;

  const SpendingTrendChart({
    super.key,
    required this.spendingTrend,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 1. Sort data by date to ensure chronology
    final sortedTrend = List<SpendingTrendPoint>.from(spendingTrend)
      ..sort((a, b) => a.date.compareTo(b.date));

    // 2. Determine aggregation strategy
    if (sortedTrend.isEmpty) return const SizedBox.shrink();

    final startDate = sortedTrend.first.date;
    final endDate = sortedTrend.last.date;
    final totalDays = endDate.difference(startDate).inDays;

    List<_ChartPoint> aggregatedPoints = [];

    if (totalDays <= 35) {
      // Daily: Show all points as is (mapped to dates)
      aggregatedPoints = sortedTrend.map((e) {
        return _ChartPoint(
          amount: e.amount,
          label: '${_getMonthName(e.date.month)} ${e.date.day}',
          date: e.date,
        );
      }).toList();
    } else if (totalDays <= 120) {
      // Weekly logic
      Map<String, _ChartPoint> groups = {};
      for (var p in sortedTrend) {
        final daysSinceEpoch = p.date.difference(DateTime(1970, 1, 1)).inDays;
        final weekNum = (daysSinceEpoch / 7).floor();
        final key = weekNum.toString();

        if (!groups.containsKey(key)) {
          groups[key] =
              _ChartPoint(amount: 0, label: '', date: p.date, count: 0);
        }
        final current = groups[key]!;
        groups[key] = _ChartPoint(
          amount: current.amount + p.amount,
          label: '',
          date: current.date,
          count: current.count + 1,
        );
      }
      // Post-process labels
      int wIndex = 1;
      aggregatedPoints = groups.values.map((p) {
        final label = 'W${wIndex++}';
        return _ChartPoint(amount: p.amount, label: label, date: p.date);
      }).toList();
    } else {
      // Monthly logic
      Map<String, _ChartPoint> groups = {};
      for (var p in sortedTrend) {
        final key = '${p.date.year}-${p.date.month}';
        if (!groups.containsKey(key)) {
          groups[key] = _ChartPoint(
              amount: 0, label: _getMonthName(p.date.month), date: p.date);
        }
        final current = groups[key]!;
        groups[key] = _ChartPoint(
          amount: current.amount + p.amount,
          label: current.label,
          date: current.date,
        );
      }
      aggregatedPoints = groups.values.toList();
    }

    // Double check we have points
    if (aggregatedPoints.isEmpty) return const SizedBox.shrink();

    // Fix for sparse data: Add preceding 0-point if only 1 point exists
    if (aggregatedPoints.length == 1) {
      final first = aggregatedPoints.first;
      final prevDate = first.date.subtract(const Duration(days: 1));
      aggregatedPoints.insert(
        0,
        _ChartPoint(
          amount: 0,
          label: '${_getMonthName(prevDate.month)} ${prevDate.day}',
          date: prevDate,
        ),
      );
    }

    // Determine frequency label
    String frequencyLabel = '';
    if (totalDays <= 35) {
      frequencyLabel = ' (per day)';
    } else if (totalDays <= 120) {
      frequencyLabel = ' (per week)';
    } else {
      frequencyLabel = ' (per month)';
    }

    // Calculate chart stats
    double totalAmount = 0;
    double maxAmount = 0;

    for (var p in aggregatedPoints) {
      totalAmount += p.amount;
      if (p.amount > maxAmount) maxAmount = p.amount;
    }

    final averageAmount =
        aggregatedPoints.isEmpty ? 0.0 : totalAmount / aggregatedPoints.length;
    final xMax = (aggregatedPoints.length - 1).toDouble();
    final currencyCubit = sl<CurrencyCubit>();

    // Calculate visible indices
    final Set<int> visibleIndices = {};
    if (aggregatedPoints.isNotEmpty) {
      if (aggregatedPoints.length <= 7) {
        for (int i = 0; i < aggregatedPoints.length; i++) {
          visibleIndices.add(i);
        }
      } else {
        final step = (aggregatedPoints.length / 5).ceil();
        visibleIndices.add(aggregatedPoints.length - 1);
        for (int i = aggregatedPoints.length - 1 - step; i >= 0; i -= step) {
          visibleIndices.add(i);
        }
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      GetIt.I<DashboardStrings>().spendingTrend,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Legend: Spending
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Spending',
                          style: textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: 10,
                          ),
                        ),
                        if (averageAmount > 0) ...[
                          const SizedBox(width: 12),
                          // Legend: Average
                          Container(
                            width: 12,
                            height: 2,
                            color: colorScheme.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Avg: ${currencyCubit.formatAmount(averageAmount)}$frequencyLabel',
                            style: textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= aggregatedPoints.length) {
                            return const SizedBox.shrink();
                          }

                          if (visibleIndices.contains(index)) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                aggregatedPoints[index].label,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .hintColor
                                      .withValues(alpha: 0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: xMax,
                  minY: 0,
                  maxY: maxAmount == 0 ? 100 : maxAmount * 1.05,
                  extraLinesData: ExtraLinesData(
                    horizontalLines: averageAmount > 0
                        ? [
                            HorizontalLine(
                              y: averageAmount,
                              color:
                                  colorScheme.tertiary.withValues(alpha: 0.5),
                              strokeWidth: 1.5,
                              dashArray: [5, 5],
                              label: HorizontalLineLabel(
                                show: true,
                                alignment: Alignment.topRight,
                                padding:
                                    const EdgeInsets.only(right: 5, bottom: 2),
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.tertiary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                labelResolver: (line) => 'Avg',
                              ),
                            ),
                          ]
                        : [],
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: aggregatedPoints
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
                          .toList(),
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        checkToShowDot: (spot, barData) {
                          return spot.y == maxAmount && maxAmount > 0;
                        },
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: colorScheme.surface,
                            strokeWidth: 2,
                            strokeColor: colorScheme.primary,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorScheme.primary.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) =>
                          colorScheme.inverseSurface.withValues(alpha: 0.9),
                      tooltipRoundedRadius: 16,
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      getTooltipItems: (touchedSpots) {
                        if (touchedSpots.isNotEmpty) {
                          HapticFeedback.lightImpact();
                        }
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            currencyCubit.formatAmount(spot.y),
                            textTheme.labelLarge!.copyWith(
                              color: colorScheme.onInverseSurface,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    '\n${aggregatedPoints[spot.x.toInt()].label}',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onInverseSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                    getTouchedSpotIndicator: (barData, spotIndexes) {
                      return spotIndexes.map((spotIndex) {
                        return TouchedSpotIndicatorData(
                          FlLine(
                            color: colorScheme.primary.withValues(alpha: 0.5),
                            strokeWidth: 2,
                            dashArray: [5, 5],
                          ),
                          FlDotData(
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 6,
                                color: colorScheme.surface,
                                strokeWidth: 3,
                                strokeColor: colorScheme.secondary,
                              );
                            },
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }
}

class _ChartPoint {
  final double amount;
  final String label;
  final DateTime date;
  final int count;

  _ChartPoint({
    required this.amount,
    required this.label,
    required this.date,
    this.count = 1,
  });
}
