import 'package:balance_iq/features/home/domain/entities/dashbaord_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.totalIncome,
    required super.totalExpense,
    required super.netBalance,
    required super.expenseRatio,
    required super.savingsRate,
    required super.spendingTrend,
    required super.categories,
    required super.accountsBreakdown,
    required super.biggestExpenseAmount,
    required super.biggestExpenseDescription,
    required super.expenseCategory,
    required super.expenseAccount,
    required super.biggestCategoryName,
    required super.biggestCategoryAmount,
    required super.biggestIncomeAmount,
    required super.biggestIncomeDescription,
    required super.period,
    required super.daysRemainingInMonth,
    required super.onboarded,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    try {
      // API returns camelCase fields
      // Parse dailySpendingTrend array
      final List<SpendingTrendPoint> spendingTrend = [];
      final dynamic spendingTrendData = json['dailySpendingTrend'];

      if (spendingTrendData != null && spendingTrendData is List) {
        for (final dynamic point in spendingTrendData) {
          if (point is Map<String, dynamic>) {
            // Parse date "2025-12-01"
            int day = 0;
            DateTime date = DateTime.now(); // Default fallback
            final dateStr = point['date'];
            if (dateStr != null) {
              try {
                date = DateTime.parse(dateStr.toString());
                day = date.day;
              } catch (_) {}
            }

            spendingTrend.add(SpendingTrendPoint(
              day: day,
              amount: _parseDoubleNullable(point['amount']) ?? 0.0,
              date: date,
            ));
          }
        }
      }

      // Parse categoryBreakdown array into map for backward compatibility
      final Map<String, double> categories = {};
      final dynamic categoriesData = json['categoryBreakdown'];

      if (categoriesData != null && categoriesData is List) {
        for (final dynamic item in categoriesData) {
          if (item is Map<String, dynamic>) {
            final category = item['category'] as String?;
            final amount = _parseDoubleNullable(item['amount']);
            if (category != null && amount != null) {
              categories[category] = amount;
            }
          }
        }
      }

      // Parse accountBalances array into map for backward compatibility
      final Map<String, double> accountsBreakdown = {};
      final dynamic accountsData = json['accountBalances'];

      if (accountsData != null && accountsData is List) {
        for (final dynamic item in accountsData) {
          if (item is Map<String, dynamic>) {
            final accountName = item['accountName'] as String?;
            final balance = _parseDoubleNullable(item['balance']);
            if (accountName != null && balance != null) {
              accountsBreakdown[accountName] = balance;
            }
          }
        }
      }

      // Parse biggestExpense object
      final dynamic biggestExpense = json['biggestExpense'];
      final double biggestExpenseAmount = biggestExpense != null
          ? _parseDoubleNullable(biggestExpense['amount']) ?? 0.0
          : 0.0;
      final String biggestExpenseDescription = biggestExpense != null
          ? _parseStringNullable(biggestExpense['description']) ?? ''
          : '';
      final String expenseCategory = biggestExpense != null
          ? _parseStringNullable(biggestExpense['category']) ?? ''
          : '';
      // API doesn't return account for biggest expense anymore
      final String expenseAccount = '';

      // Parse biggestCategory (now returns string name only)
      final String biggestCategoryName =
          _parseStringNullable(json['biggestCategory']) ?? '';

      // Find amount for biggest category from categories map
      final double biggestCategoryAmount =
          categories[biggestCategoryName] ?? 0.0;

      // Parse biggestIncome object
      final dynamic biggestIncome = json['biggestIncome'];
      final double biggestIncomeAmount = biggestIncome != null
          ? _parseDoubleNullable(biggestIncome['amount']) ?? 0.0
          : 0.0;
      final String biggestIncomeDescription = biggestIncome != null
          ? _parseStringNullable(biggestIncome['description']) ?? ''
          : '';

      return DashboardSummaryModel(
        totalIncome: _parseDoubleNullable(json['totalIncome']) ?? 0.0,
        totalExpense: _parseDoubleNullable(json['totalExpense']) ?? 0.0,
        netBalance: _parseDoubleNullable(json['netBalance']) ?? 0.0,
        expenseRatio: _parseDoubleNullable(json['expenseRatio']) ?? 0.0,
        savingsRate: _parseDoubleNullable(json['savingsRate']) ?? 0.0,
        spendingTrend: spendingTrend,
        categories: categories,
        accountsBreakdown: accountsBreakdown,
        biggestExpenseAmount: biggestExpenseAmount,
        biggestExpenseDescription: biggestExpenseDescription,
        expenseCategory: expenseCategory,
        expenseAccount: expenseAccount,
        biggestCategoryName: biggestCategoryName,
        biggestCategoryAmount: biggestCategoryAmount,
        biggestIncomeAmount: biggestIncomeAmount,
        biggestIncomeDescription: biggestIncomeDescription,
        period: _parseStringNullable(json['period']) ?? '',
        daysRemainingInMonth:
            _parseIntNullable(json['daysRemainingInMonth']) ?? 0,
        onboarded: json['onboarded'] == true,
      );
    } catch (e) {
      throw FormatException('Failed to parse DashboardSummaryModel: $e');
    }
  }

  /// Nullable int parser
  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Nullable double parser
  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Nullable string parser
  static String? _parseStringNullable(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'net_balance': netBalance,
      'expense_ratio': expenseRatio,
      'savings_rate': savingsRate,
      'spending_trend': spendingTrend
          .map((SpendingTrendPoint point) => <String, dynamic>{
                'day': point.day,
                'amount': point.amount,
                'date': point.date.toIso8601String(),
              })
          .toList(),
      'categories': categories,
      'accounts_breakdown': accountsBreakdown,
      'biggest_expense_amount': biggestExpenseAmount,
      'biggest_expense_description': biggestExpenseDescription,
      'expense_category': expenseCategory,
      'expense_account': expenseAccount,
      'biggest_category_name': biggestCategoryName,
      'biggest_category_amount': biggestCategoryAmount,
      'biggest_income_amount': biggestIncomeAmount,
      'biggest_income_description': biggestIncomeDescription,
      'period': period,
      'days_remaining_in_month': daysRemainingInMonth,
    };
  }
}
