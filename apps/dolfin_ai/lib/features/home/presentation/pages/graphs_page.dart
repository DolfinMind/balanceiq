import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/di/injection_container.dart';
import '../../domain/entities/dashbaord_summary.dart';
import '../utils/category_styles.dart';
import '../widgets/analysis_widgets/spending_trend_chart.dart';
import '../widgets/analysis_widgets/pacing_card_widget.dart';
import '../widgets/analysis_widgets/estimated_runway_card.dart';
import '../widgets/dashboard_widgets/highlights_insight_card.dart';
import '../widgets/analysis_widgets/category_radar_chart.dart';
import '../widgets/analysis_widgets/spending_heatmap_widget.dart';

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

          // ─── 2. Top Insights & Projections ──────────────
          if (summary.categories.isNotEmpty || summary.totalExpense > 0) ...[
            _sectionTitle(context, 'Key Insights'),
            const SizedBox(height: 12),
            if (summary.categories.isNotEmpty) ...[
              _buildTopSpendingInsight(context, colorScheme, textTheme),
              const SizedBox(height: 12),
            ],
            // Pacing Card
            SpendingPacingCard(
              totalIncome: summary.totalIncome,
              totalExpense: summary.totalExpense,
              daysInPeriod: summary.daysRemainingInMonth > 0
                  ? 30
                  : 30, // Rough estimate if not available accurately from summary
            ),
            const SizedBox(height: 12),

            // Runway Card
            EstimatedRunwayCard(
              netBalance: summary.netBalance,
              totalExpense: summary.totalExpense,
              daysInPeriod: 30, // Normalized to monthly velocity
            ),
            const SizedBox(height: 12),

            // Biggest Income/Expense Highlights
            HighlightsInsightCard(
              biggestIncomeAmount: summary.biggestIncomeAmount,
              biggestIncomeDescription: summary.biggestIncomeDescription,
              biggestExpenseAmount: summary.biggestExpenseAmount,
              biggestExpenseDescription: summary.biggestExpenseDescription,
            ),
            const SizedBox(height: 28),
          ],

          // ─── 3. Spending Trend ─────────────────────────
          if (summary.spendingTrend.isNotEmpty) ...[
            _sectionTitle(context, 'Spending Trend'),
            const SizedBox(height: 12),
            SpendingTrendChart(
              spendingTrend: summary.spendingTrend,
            ),
            const SizedBox(height: 16),
            SpendingHeatmapWidget(
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
            CategoryRadarChart(categories: summary.categories),
            const SizedBox(height: 28),
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

  Widget _buildFinancialHealth(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // 1. Savings Rate
    final savingsRate = summary.savingsRate;

    // 2. Cash Flow Ratio = Income / Expense
    final cashFlowRatio = summary.totalExpense > 0
        ? (summary.totalIncome / summary.totalExpense)
        : (summary.totalIncome > 0 ? 5.0 : 0.0);

    // 3. Financial Cushion = Net Balance / Average Daily Expense
    final dailyExpense = summary.totalExpense / 30; // normalized to 30 days
    final cushionDays =
        dailyExpense > 0 ? (summary.netBalance / dailyExpense) : 0.0;

    // 4. Daily Burn Rate
    final burnRate = dailyExpense;

    // 5. Expense Concentration
    double maxCategoryExpense = 0.0;
    if (summary.categories.isNotEmpty) {
      maxCategoryExpense = summary.categories.values
          .map((v) => v.abs())
          .reduce((a, b) => a > b ? a : b);
    }
    final expenseConcentration = summary.totalExpense > 0
        ? (maxCategoryExpense / summary.totalExpense) * 100
        : 0.0;

    // 6. Budget Utilization (Expense Ratio)
    final budgetUtil = summary.totalIncome > 0
        ? (summary.totalExpense / summary.totalIncome * 100).clamp(0.0, 200.0)
        : 0.0;

    final currencyCubit = sl<CurrencyCubit>();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGaugeCard(
                context,
                colorScheme: colorScheme,
                textTheme: textTheme,
                label: 'Budget Used',
                value: (budgetUtil / 100).clamp(0.0, 1.0),
                displayValue: '${budgetUtil.toStringAsFixed(0)}%',
                color: _getSavingsColor(
                    100 - budgetUtil), // Invert for color (high budget = bad)
                description:
                    'The percentage of your income consumed by expenses. Keeping this low gives you more financial breathing room.',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildGaugeCard(
                context,
                colorScheme: colorScheme,
                textTheme: textTheme,
                label: 'Savings Rate',
                value: savingsRate / 100,
                displayValue: '${savingsRate.toStringAsFixed(0)}%',
                color: _getSavingsColor(savingsRate),
                description:
                    'The percentage of your income that you saved instead of spent over this period. Higher is better for building wealth.',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildGaugeCard(
                context,
                colorScheme: colorScheme,
                textTheme: textTheme,
                label: 'Cash Flow',
                value: (cashFlowRatio / 2.0).clamp(0.0, 1.0),
                displayValue: '${cashFlowRatio.toStringAsFixed(1)}x',
                color: _getCashFlowColor(cashFlowRatio),
                description:
                    'The ratio of your income to expenses. A score of 1.0x means you broke even. Above 1.0x means you are cash-flow positive.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGaugeCard(
                context,
                colorScheme: colorScheme,
                textTheme: textTheme,
                label: 'Cushion',
                value: (cushionDays / 180.0).clamp(0.0, 1.0),
                displayValue: cushionDays > 30
                    ? '${(cushionDays / 30).toStringAsFixed(1)}m'
                    : '${cushionDays.toStringAsFixed(0)}d',
                color: _getCushionColor(cushionDays),
                description:
                    'How long your current net balance covers your average daily expenses. E.g. "2.5m" means your savings could sustain your lifestyle for 2.5 months without income.',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildGaugeCard(
                context,
                colorScheme: colorScheme,
                textTheme: textTheme,
                label: 'Burn Rate',
                value:
                    (burnRate / 500).clamp(0.0, 1.0), // Arbitrary gauge scale
                displayValue:
                    currencyCubit.formatAmount(burnRate).split('.').first,
                color: colorScheme.error,
                description:
                    'Your average daily spending over the last 30 days. This measures how fast you "burn" through cash. A lower burn rate extends your financial runway.',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildGaugeCard(
                context,
                colorScheme: colorScheme,
                textTheme: textTheme,
                label: 'Discipline',
                value: (1 - (expenseConcentration / 100)).clamp(
                    0.0, 1.0), // Invert so low concentration = full gauge
                displayValue: '${expenseConcentration.toStringAsFixed(0)}%',
                color: _getSavingsColor(
                    100 - expenseConcentration), // Re-use savings color logic
                description:
                    'Expense Concentration: The percentage of your total spending consumed by your single highest category. High concentration indicates risk if that top category is discretionary.',
              ),
            ),
          ],
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
    required String description,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showMetricDetailsModal(
          context,
          title: label,
          value: displayValue,
          description: description,
          color: color,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
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
                        fontSize: 10,
                        color: color,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
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
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.info_outline,
                    size: 11,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMetricDetailsModal(
    BuildContext context, {
    required String title,
    required String value,
    required String description,
    required Color color,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final textTheme = Theme.of(ctx).textTheme;
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.analytics_outlined,
                          color: color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            value,
                            style: textTheme.headlineSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'What does this mean?',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Got it, thanks!',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCashFlowColor(double ratio) {
    if (ratio >= 1.2) return const Color(0xFF4CAF50);
    if (ratio >= 1.0) return const Color(0xFFFFA726);
    return const Color(0xFFEF5350);
  }

  Color _getSavingsColor(double rate) {
    if (rate >= 30) return const Color(0xFF4CAF50);
    if (rate >= 10) return const Color(0xFFFFA726);
    return const Color(0xFFEF5350);
  }

  Color _getCushionColor(double days) {
    if (days >= 90) return const Color(0xFF4CAF50);
    if (days >= 30) return const Color(0xFFFFA726);
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

          if (summary.totalIncome > 0 || summary.totalExpense > 0) ...[
            const SizedBox(height: 16),
            Divider(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  summary.totalIncome >= summary.totalExpense
                      ? LucideIcons.trendingUp
                      : LucideIcons.trendingDown,
                  size: 16,
                  color: summary.totalIncome >= summary.totalExpense
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF5350),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    summary.totalIncome >= summary.totalExpense
                        ? 'You saved ${(incomeRatio * 100).toStringAsFixed(0)}% of your income this period.'
                        : 'You spent ${currencyCubit.formatAmount(summary.totalExpense - summary.totalIncome)} more than you earned.',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
