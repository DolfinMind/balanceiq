import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/di/injection_container.dart';

class IncomeExpensePieChart extends StatefulWidget {
  final double totalIncome;
  final double totalExpense;

  const IncomeExpensePieChart({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  State<IncomeExpensePieChart> createState() => _IncomeExpensePieChartState();
}

class _IncomeExpensePieChartState extends State<IncomeExpensePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final currencyCubit = sl<CurrencyCubit>();

    final double income = widget.totalIncome;
    final double expense = widget.totalExpense;
    final double total = income + expense;

    // Handle zero state
    if (total == 0) {
      return const SizedBox.shrink();
    }

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
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 2,
                    centerSpaceRadius: 20,
                    sections:
                        showingSections(colorScheme, income, expense, total),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cash Flow',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLegendItem(
                    context,
                    color: const Color(0xFF4CAF50),
                    // Income Green
                    label: 'Income',
                    amount: currencyCubit.formatAmount(income),
                    percentage: total > 0 ? (income / total * 100) : 0,
                    isTouched: touchedIndex == 0,
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                    context,
                    color: const Color(0xFFF44336),
                    // Expense Red
                    label: 'Expense',
                    amount: currencyCubit.formatAmount(expense),
                    percentage: total > 0 ? (expense / total * 100) : 0,
                    isTouched: touchedIndex == 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(
      ColorScheme colorScheme, double income, double expense, double total) {
    if (total == 0) return [];

    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize =
          isTouched ? 16.0 : 0.0; // Hide value on chart, show in legend
      final radius = isTouched ? 35.0 : 30.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xFF4CAF50),
            value: income,
            title: '${(income / total * 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xFFF44336),
            value: expense,
            title: '${(expense / total * 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
    required String amount,
    required double percentage,
    required bool isTouched,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(isTouched ? 8 : 0),
      decoration: isTouched
          ? BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const Spacer(),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              amount,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
