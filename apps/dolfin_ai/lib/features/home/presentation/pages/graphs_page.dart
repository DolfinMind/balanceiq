import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/di/injection_container.dart';
import '../../domain/entities/dashbaord_summary.dart';
import '../utils/category_styles.dart';
import '../widgets/analysis_widgets/spending_trend_chart.dart';

/// Analysis tab content – embeddable inside a parent Stack.
/// No Scaffold, AppBar, or FloatingBottomNav – those live in the parent.
class GraphsPage extends StatelessWidget {
  final DashboardSummary summary;
  final String displayDate;
  final VoidCallback? onTapDateRange;

  const GraphsPage({
    super.key,
    required this.summary,
    this.displayDate = '',
    this.onTapDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currencyCubit = sl<CurrencyCubit>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 100,
        ),
        children: [
          // Page title + date range selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analysis',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (onTapDateRange != null)
                GestureDetector(
                  onTap: onTapDateRange,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.calendar,
                            size: 14, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          displayDate.isNotEmpty ? displayDate : 'Select Date',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // ─── 0. Quick Stats Row ─────────────────────────
          _buildQuickStats(context, colorScheme, textTheme, currencyCubit),
          const SizedBox(height: 24),

          // ─── 1. Financial Health Overview ───────────────
          _sectionTitle(context, 'Financial Health'),
          const SizedBox(height: 12),
          _buildFinancialHealth(context, colorScheme, textTheme),
          const SizedBox(height: 28),

          // ─── 2. Top Spending Insight ────────────────────
          if (summary.categories.isNotEmpty) ...[
            _buildTopSpendingInsight(context, colorScheme, textTheme),
            const SizedBox(height: 28),
          ],

          // ─── 3. Spending Trend ─────────────────────────
          if (summary.spendingTrend.isNotEmpty) ...[
            _sectionTitle(context, 'Spending Trend'),
            const SizedBox(height: 12),
            SpendingTrendChart(
              spendingTrend: summary.spendingTrend,
            ),
            const SizedBox(height: 28),
          ],

          // ─── 4. Income vs Expense Bar ──────────────────
          if (summary.totalIncome > 0 || summary.totalExpense > 0) ...[
            _sectionTitle(context, 'Income vs Expense'),
            const SizedBox(height: 12),
            _buildIncomeVsExpense(
                context, colorScheme, textTheme, currencyCubit),
            const SizedBox(height: 28),
          ],

          // ─── 5. Category Breakdown ─────────────────────
          if (summary.categories.isNotEmpty) ...[
            _sectionTitle(context, 'Spending by Category'),
            const SizedBox(height: 12),
            _buildCategoryBreakdown(
                context, colorScheme, textTheme, currencyCubit),
            const SizedBox(height: 28),
          ],

          // ─── 6. Accounts Distribution ──────────────────
          if (summary.accountsBreakdown.isNotEmpty) ...[
            _sectionTitle(context, 'Accounts'),
            const SizedBox(height: 12),
            _buildAccountsDistribution(
                context, colorScheme, textTheme, currencyCubit),
          ],
        ],
      ),
    );
  }

  // ─── Section title ──────────────────────────────────────────

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
    );
  }

  // ─── 0. Quick Stats Row ─────────────────────────────────────

  Widget _buildQuickStats(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    CurrencyCubit currencyCubit,
  ) {
    // Calculate daily average spending
    final days =
        summary.spendingTrend.isNotEmpty ? summary.spendingTrend.length : 30;
    final dailyAvg = days > 0 ? summary.totalExpense / days : 0.0;

    // Net cash flow
    final netFlow = summary.totalIncome - summary.totalExpense;
    final isPositive = netFlow >= 0;

    return Row(
      children: [
        Expanded(
          child: _statCard(
            context,
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon: LucideIcons.trendingDown,
            iconColor: const Color(0xFFEF5350),
            label: 'Daily Avg Spend',
            value: currencyCubit.formatAmount(dailyAvg),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            context,
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon:
                isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
            iconColor:
                isPositive ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
            label: 'Net Cash Flow',
            value: currencyCubit.formatAmount(netFlow.abs()),
            prefix: isPositive ? '+' : '-',
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context, {
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String prefix = '',
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            '$prefix$value',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 1. Financial Health ────────────────────────────────────

  Widget _buildFinancialHealth(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // Budget utilization — how much of income is consumed by expenses
    final budgetUtil = summary.totalIncome > 0
        ? (summary.totalExpense / summary.totalIncome * 100).clamp(0.0, 200.0)
        : 0.0;

    return Row(
      children: [
        // Expense Ratio
        Expanded(
          child: _buildGaugeCard(
            context,
            colorScheme: colorScheme,
            textTheme: textTheme,
            label: 'Expense Ratio',
            value: summary.expenseRatio / 100,
            displayValue: '${summary.expenseRatio.toStringAsFixed(0)}%',
            color: _getRatioColor(summary.expenseRatio),
          ),
        ),
        const SizedBox(width: 12),
        // Savings Rate
        Expanded(
          child: _buildGaugeCard(
            context,
            colorScheme: colorScheme,
            textTheme: textTheme,
            label: 'Savings Rate',
            value: summary.savingsRate / 100,
            displayValue: '${summary.savingsRate.toStringAsFixed(0)}%',
            color: _getSavingsColor(summary.savingsRate),
          ),
        ),
        const SizedBox(width: 12),
        // Budget Utilization (replaces Days Left)
        Expanded(
          child: _buildGaugeCard(
            context,
            colorScheme: colorScheme,
            textTheme: textTheme,
            label: 'Budget Used',
            value: (budgetUtil / 100).clamp(0.0, 1.0),
            displayValue: '${budgetUtil.toStringAsFixed(0)}%',
            color: _getBudgetColor(budgetUtil),
          ),
        ),
      ],
    );
  }

  Widget _buildGaugeCard(
    BuildContext context, {
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required String label,
    required double value,
    required String displayValue,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: value.clamp(0, 1),
                  strokeWidth: 5,
                  backgroundColor:
                      colorScheme.outlineVariant.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  displayValue,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getRatioColor(double ratio) {
    if (ratio <= 50) return const Color(0xFF4CAF50);
    if (ratio <= 75) return const Color(0xFFFFA726);
    return const Color(0xFFEF5350);
  }

  Color _getSavingsColor(double rate) {
    if (rate >= 30) return const Color(0xFF4CAF50);
    if (rate >= 10) return const Color(0xFFFFA726);
    return const Color(0xFFEF5350);
  }

  Color _getBudgetColor(double utilization) {
    if (utilization <= 60) return const Color(0xFF4CAF50);
    if (utilization <= 85) return const Color(0xFFFFA726);
    return const Color(0xFFEF5350);
  }

  // ─── 2. Top Spending Insight ────────────────────────────────

  Widget _buildTopSpendingInsight(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final sorted = summary.categories.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    if (sorted.isEmpty) return const SizedBox.shrink();

    final top = sorted.first;
    final total = sorted.fold<double>(0, (s, e) => s + e.value.abs());
    final pct = total > 0 ? (top.value.abs() / total * 100) : 0.0;
    final topColor = CategoryStyles.colorFor(top.key);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: topColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: topColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: topColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.lightbulb, color: topColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Spending',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(
                        text: top.key,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: topColor,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' takes ${pct.toStringAsFixed(0)}% of your spending',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 3. Income vs Expense ───────────────────────────────────

  Widget _buildIncomeVsExpense(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    CurrencyCubit currencyCubit,
  ) {
    final total = summary.totalIncome + summary.totalExpense;
    final incomeRatio = total > 0 ? summary.totalIncome / total : 0.5;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: (incomeRatio * 100).round().clamp(1, 99),
                    child: Container(color: const Color(0xFF4CAF50)),
                  ),
                  Expanded(
                    flex: ((1 - incomeRatio) * 100).round().clamp(1, 99),
                    child: Container(color: const Color(0xFFEF5350)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Labels
          Row(
            children: [
              Expanded(
                child: _incomeExpenseLabel(
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                  dotColor: const Color(0xFF4CAF50),
                  label: 'Income',
                  amount: currencyCubit.formatAmount(summary.totalIncome),
                ),
              ),
              Expanded(
                child: _incomeExpenseLabel(
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                  dotColor: const Color(0xFFEF5350),
                  label: 'Expense',
                  amount: currencyCubit.formatAmount(summary.totalExpense),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _incomeExpenseLabel({
    required TextTheme textTheme,
    required ColorScheme colorScheme,
    required Color dotColor,
    required String label,
    required String amount,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              amount,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── 4. Category Breakdown ──────────────────────────────────

  Widget _buildCategoryBreakdown(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    CurrencyCubit currencyCubit,
  ) {
    final sorted = summary.categories.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    final total = sorted.fold<double>(0, (sum, e) => sum + e.value.abs());

    return Container(
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

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < sorted.length - 1 ? 16 : 0,
            ),
            child: Column(
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      currencyCubit.formatAmount(entry.value.abs()),
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (pct / 100).clamp(0, 1),
                    minHeight: 6,
                    backgroundColor:
                        colorScheme.outlineVariant.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── 5. Accounts Distribution ───────────────────────────────

  Widget _buildAccountsDistribution(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    CurrencyCubit currencyCubit,
  ) {
    final sorted = summary.accountsBreakdown.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    final maxVal = sorted.isNotEmpty ? sorted.first.value.abs() : 1.0;

    final accountColors = [
      const Color(0xFF42A5F5),
      const Color(0xFF66BB6A),
      const Color(0xFFFFA726),
      const Color(0xFFAB47BC),
      const Color(0xFFEF5350),
      const Color(0xFF26C6DA),
    ];

    return Container(
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
          final ratio = maxVal > 0 ? entry.value.abs() / maxVal : 0.0;
          final color = accountColors[index % accountColors.length];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < sorted.length - 1 ? 16 : 0,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        const SizedBox(width: 10),
                        Text(
                          entry.key,
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currencyCubit.formatAmount(entry.value.abs()),
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0, 1),
                    minHeight: 6,
                    backgroundColor:
                        colorScheme.outlineVariant.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
