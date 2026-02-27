import 'package:equatable/equatable.dart';

class SpendingTrendPoint extends Equatable {
  final int day;
  final double amount;
  final DateTime date;

  const SpendingTrendPoint({
    required this.day,
    required this.amount,
    required this.date,
  });

  @override
  List<Object?> get props => [day, amount, date];
}

class DashboardSummary extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final double expenseRatio;
  final double savingsRate;

  final List<SpendingTrendPoint> spendingTrend;
  final Map<String, double> categories;
  final Map<String, double> accountsBreakdown;
  final double biggestExpenseAmount;
  final String biggestExpenseDescription;
  final String expenseCategory;
  final String expenseAccount;
  final String biggestCategoryName;
  final double biggestCategoryAmount;
  final double biggestIncomeAmount;
  final String biggestIncomeDescription;
  final String period;
  final int daysRemainingInMonth;
  final bool onboarded;

  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.expenseRatio,
    required this.savingsRate,
    required this.spendingTrend,
    required this.categories,
    required this.accountsBreakdown,
    required this.biggestExpenseAmount,
    required this.biggestExpenseDescription,
    required this.expenseCategory,
    required this.expenseAccount,
    required this.biggestCategoryName,
    required this.biggestCategoryAmount,
    required this.biggestIncomeAmount,
    required this.biggestIncomeDescription,
    required this.period,
    required this.daysRemainingInMonth,
    required this.onboarded,
  });

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        netBalance,
        expenseRatio,
        savingsRate,
        spendingTrend,
        categories,
        accountsBreakdown,
        biggestExpenseAmount,
        biggestExpenseDescription,
        expenseCategory,
        expenseAccount,
        biggestCategoryName,
        biggestCategoryAmount,
        biggestIncomeAmount,
        biggestIncomeDescription,
        period,
        daysRemainingInMonth,
        onboarded,
      ];
}
