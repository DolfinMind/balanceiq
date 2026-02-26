import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../../domain/entities/dashbaord_summary.dart';
import 'analysis_widgets/accounts_breakdown_widget.dart';
import 'analysis_widgets/analysis_carousel.dart';
import 'analysis_widgets/category_breakdown_widget.dart';
import 'dashboard_widgets/balance_card_widget.dart';
import 'dashboard_widgets/biggest_expense_widget.dart';
import 'dashboard_widgets/biggest_income_widget.dart';
import 'dashboard_widgets/financial_ratio_widget.dart';
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

              // Analysis Carousel
              if (summary.spendingTrend.isNotEmpty ||
                  summary.categories.isNotEmpty ||
                  (summary.totalIncome > 0 || summary.totalExpense > 0)) ...[
                SliverToBoxAdapter(
                  child: AnalysisCarousel(
                    summary: summary,
                  ),
                ),
                SliverToBoxAdapter(
                  child: const SizedBox(height: 16),
                ),
              ],

              // Category Breakdown (elevated for spending focus)
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

              // Transaction History (elevated for spending focus)
              SliverToBoxAdapter(
                child: TransactionHistoryWidget(
                  onViewAll: onViewAll,
                  onRefresh: onRefresh,
                ),
              ),

              SliverToBoxAdapter(
                child: const SizedBox(height: 16),
              ),

              // Financial Ratios
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FinancialRatiosWidget(
                    expenseRatio: summary.expenseRatio,
                    savingsRate: summary.savingsRate,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: const SizedBox(height: 16),
              ),

              // Accounts Breakdown
              if (summary.accountsBreakdown.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: AccountsBreakdownWidget(
                    accountsBreakdown: summary.accountsBreakdown,
                  ),
                ),
                SliverToBoxAdapter(
                  child: const SizedBox(height: 16),
                ),
              ],

              // Biggest Income & Expense
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 120,
                  ),
                  child: Column(
                    children: [
                      BiggestIncomeWidget(
                        amount: summary.biggestIncomeAmount,
                        description: summary.biggestIncomeDescription,
                      ),
                      if (summary.biggestIncomeAmount > 0)
                        const SizedBox(height: 16),
                      BiggestExpenseWidget(
                        amount: summary.biggestExpenseAmount,
                        description: summary.biggestExpenseDescription,
                        category: summary.expenseCategory,
                        account: summary.expenseAccount,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Positioned chat button at the bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Hero(
            tag: 'chat_input',
            child: FloatingChatButton(onReturn: onChatReturn),
          ),
        ),
      ],
    );
  }
}
