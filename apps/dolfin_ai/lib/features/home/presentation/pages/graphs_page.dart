import 'package:flutter/material.dart';

import '../../domain/entities/dashbaord_summary.dart';
import '../widgets/analysis_widgets/category_bar_chart.dart';
import '../widgets/analysis_widgets/income_expense_pie_chart.dart';
import '../widgets/analysis_widgets/spending_trend_chart.dart';
import '../widgets/dashboard_widgets/floating_chat_button.dart';

/// Full-screen page showing all analysis charts.
/// Accessible via the Graphs button in the floating bottom nav.
class GraphsPage extends StatelessWidget {
  final DashboardSummary summary;
  final VoidCallback? onDashboardRefresh;

  const GraphsPage({
    super.key,
    required this.summary,
    this.onDashboardRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Analysis',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 100,
            ),
            children: [
              // Spending Trend Chart
              if (summary.spendingTrend.isNotEmpty) ...[
                _sectionTitle(context, 'Spending Trend'),
                const SizedBox(height: 12),
                SpendingTrendChart(
                  spendingTrend: summary.spendingTrend,
                ),
                const SizedBox(height: 24),
              ],

              // Income vs Expense Pie Chart
              if (summary.totalIncome > 0 || summary.totalExpense > 0) ...[
                _sectionTitle(context, 'Income vs Expense'),
                const SizedBox(height: 12),
                IncomeExpensePieChart(
                  totalIncome: summary.totalIncome,
                  totalExpense: summary.totalExpense,
                ),
                const SizedBox(height: 24),
              ],

              // Category Bar Chart
              if (summary.categories.isNotEmpty) ...[
                _sectionTitle(context, 'Top Categories'),
                const SizedBox(height: 12),
                CategoryBarChart(
                  categories: summary.categories,
                ),
              ],
            ],
          ),

          // Floating bottom nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              onDashboardRefresh: onDashboardRefresh,
              initialIndex: 2, // Graphs tab selected
              onNavigateHome: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
    );
  }
}
