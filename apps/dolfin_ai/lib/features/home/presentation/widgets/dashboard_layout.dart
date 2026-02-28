import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../../domain/entities/dashbaord_summary.dart';
import 'analysis_widgets/spending_donut_chart.dart';
import 'analysis_widgets/category_breakdown_widget.dart';
import 'dashboard_widgets/balance_card_widget.dart';
import 'dashboard_widgets/highlights_insight_card.dart';
import 'dashboard_widgets/floating_chat_button.dart';
import 'dashboard_widgets/home_appbar.dart';
import 'dashboard_widgets/transaction_history_widget.dart';

class DashboardLayout extends StatelessWidget {
  final DashboardSummary summary;
  final Future<void> Function() onRefresh;
  final VoidCallback onTapProfileIcon;
  final VoidCallback onTapDateRange;
  final VoidCallback onViewAll;
  final VoidCallback? onChatReturn;
  final ValueChanged<int>? onTabChanged;
  final int selectedTab;
  final String profileUrl;
  final String userName;
  final String displayDate;
  final GlobalKey? profileIconKey;

  const DashboardLayout({
    super.key,
    required this.summary,
    required this.onRefresh,
    required this.onTapProfileIcon,
    required this.onTapDateRange,
    required this.onViewAll,
    this.onChatReturn,
    this.onTabChanged,
    this.selectedTab = 0,
    required this.profileUrl,
    required this.userName,
    required this.displayDate,
    this.profileIconKey,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LiquidPullToRefresh(
          onRefresh: onRefresh,
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          showChildOpacityTransition: false,
          springAnimationDurationInMilliseconds: 500,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // --- Animated AppBar ---
              HomeAppbar(
                summary: summary,
                onTapProfileIcon: onTapProfileIcon,
                profileUrl: profileUrl,
                userName: userName,
                displayDate: displayDate,
                onTapDateRange: onTapDateRange,
                profileIconKey: profileIconKey,
              ),

              // --- Dashboard Body ---
              SliverToBoxAdapter(
                child: const SizedBox(height: 16),
              ),

              // Balance Card
              SliverToBoxAdapter(
                child: BalanceCard(
                  netBalance: summary.netBalance,
                  totalIncome: summary.totalIncome,
                  totalExpense: summary.totalExpense,
                  period: summary.period,
                ),
              ),

              SliverToBoxAdapter(
                child: const SizedBox(height: 16),
              ),

              // Spending Donut Chart
              if (summary.categories.isNotEmpty &&
                  summary.totalExpense > 0) ...[
                SliverToBoxAdapter(
                  child: SpendingDonutChart(
                    categories: summary.categories,
                    totalExpense: summary.totalExpense,
                  ),
                ),
                SliverToBoxAdapter(
                  child: const SizedBox(height: 16),
                ),
              ],

              // Transaction History
              SliverToBoxAdapter(
                child: TransactionHistoryWidget(
                  onViewAll: onViewAll,
                  onRefresh: onRefresh,
                ),
              ),

              SliverToBoxAdapter(
                child: const SizedBox(height: 16),
              ),

              // Category Breakdown (analysis-style vertical bars)
              if (summary.categories.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CategoryBreakdownWidget(
                      categories: summary.categories,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: const SizedBox(height: 16),
                ),
              ],

              // Highlights — Biggest Income & Expense combined
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 120,
                  ),
                  child: HighlightsInsightCard(
                    biggestIncomeAmount: summary.biggestIncomeAmount,
                    biggestIncomeDescription: summary.biggestIncomeDescription,
                    biggestExpenseAmount: summary.biggestExpenseAmount,
                    biggestExpenseDescription:
                        summary.biggestExpenseDescription,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Positioned bottom nav
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Hero(
            tag: 'bottom_nav',
            child: FloatingBottomNav(
              onDashboardRefresh: onChatReturn,
              onTabChanged: onTabChanged,
              selectedTab: selectedTab,
            ),
          ),
        ),
      ],
    );
  }
}
