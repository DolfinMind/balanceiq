import 'package:flutter/material.dart';

/// Single source of truth for category colors and icons.
/// Used by donut chart, category breakdown, transaction list,
/// analysis graphs, and any future category-aware widget.
class CategoryStyles {
  CategoryStyles._();

  /// Returns a consistent color for the given category name.
  /// Uses keyword matching; falls back to a deterministic palette
  /// index based on the category's hashCode so the same unknown
  /// category always gets the same color.
  static Color colorFor(String category) {
    final name = category.toLowerCase();

    if (name.contains('food') || name.contains('dining')) {
      return const Color(0xFFF44336); // Red
    }
    if (name.contains('grocery')) {
      return const Color(0xFF4CAF50); // Green
    }
    if (name.contains('transport')) {
      return const Color(0xFF2196F3); // Blue
    }
    if (name.contains('shop')) {
      return const Color(0xFF673AB7); // Deep Purple
    }
    if (name.contains('entertain')) {
      return const Color(0xFFFFC107); // Amber
    }
    if (name.contains('travel')) {
      return const Color(0xFF00BCD4); // Cyan
    }
    if (name.contains('bill') ||
        name.contains('util') ||
        name.contains('recharge')) {
      return const Color(0xFFE91E63); // Pink
    }
    if (name.contains('rent') || name.contains('house')) {
      return const Color(0xFF795548); // Brown
    }
    if (name.contains('health') || name.contains('med')) {
      return const Color(0xFF009688); // Teal
    }
    if (name.contains('salary') || name.contains('income')) {
      return const Color(0xFF3F51B5); // Indigo
    }
    if (name.contains('education') || name.contains('school')) {
      return const Color(0xFFFF9800); // Orange
    }
    if (name.contains('gift') || name.contains('donate')) {
      return const Color(0xFFFF5722); // Deep Orange
    }
    if (name.contains('insurance')) {
      return const Color(0xFF607D8B); // Blue Grey
    }
    if (name.contains('invest') || name.contains('saving')) {
      return const Color(0xFF8BC34A); // Light Green
    }
    if (name.contains('subscription') || name.contains('member')) {
      return const Color(0xFF9C27B0); // Purple
    }
    if (name.contains('water')) {
      return const Color(0xFF03A9F4); // Light Blue
    }
    if (name.contains('electric') || name.contains('power')) {
      return const Color(0xFFFBC02D); // Yellow 700 (More visible)
    }
    if (name.contains('internet') || name.contains('wifi')) {
      return const Color(0xFF9E9E9E); // Grey
    }
    if (name.contains('phone') || name.contains('mobile')) {
      return const Color(0xFFCDDC39); // Lime
    }

    // Deterministic fallback — same category always maps to same color
    const fallbackPalette = [
      Color(0xFFF44336), // Red
      Color(0xFFE91E63), // Pink
      Color(0xFF9C27B0), // Purple
      Color(0xFF673AB7), // Deep Purple
      Color(0xFF3F51B5), // Indigo
      Color(0xFF2196F3), // Blue
      Color(0xFF03A9F4), // Light Blue
      Color(0xFF00BCD4), // Cyan
      Color(0xFF009688), // Teal
      Color(0xFF4CAF50), // Green
      Color(0xFF8BC34A), // Light Green
      Color(0xFFCDDC39), // Lime
      Color(0xFFFFEB3B), // Yellow
      Color(0xFFFFC107), // Amber
      Color(0xFFFF9800), // Orange
      Color(0xFFFF5722), // Deep Orange
      Color(0xFF795548), // Brown
      Color(0xFF9E9E9E), // Grey
      Color(0xFF607D8B), // Blue Grey
    ];
    return fallbackPalette[category.hashCode.abs() % fallbackPalette.length];
  }

  /// Returns a consistent icon for the given category name.
  static IconData iconFor(String category) {
    final name = category.toLowerCase();

    if (name.contains('food') || name.contains('dining')) {
      return Icons.restaurant_rounded;
    }
    if (name.contains('grocery')) {
      return Icons.local_grocery_store_rounded;
    }
    if (name.contains('transport')) {
      return Icons.directions_car_rounded;
    }
    if (name.contains('shop')) {
      return Icons.shopping_bag_rounded;
    }
    if (name.contains('entertain')) {
      return Icons.movie_rounded;
    }
    if (name.contains('travel')) {
      return Icons.flight_rounded;
    }
    if (name.contains('bill') ||
        name.contains('util') ||
        name.contains('recharge')) {
      return Icons.receipt_long_rounded;
    }
    if (name.contains('rent') || name.contains('house')) {
      return Icons.home_rounded;
    }
    if (name.contains('health') || name.contains('med')) {
      return Icons.medical_services_rounded;
    }
    if (name.contains('salary') || name.contains('income')) {
      return Icons.account_balance_rounded;
    }
    if (name.contains('education') || name.contains('school')) {
      return Icons.school_rounded;
    }
    if (name.contains('gift') || name.contains('donate')) {
      return Icons.card_giftcard_rounded;
    }
    if (name.contains('insurance')) {
      return Icons.security_rounded;
    }
    if (name.contains('invest') || name.contains('saving')) {
      return Icons.trending_up_rounded;
    }
    if (name.contains('subscription') || name.contains('member')) {
      return Icons.subscriptions_rounded;
    }
    if (name.contains('water')) {
      return Icons.water_drop_rounded;
    }
    if (name.contains('electric') || name.contains('power')) {
      return Icons.bolt_rounded;
    }
    if (name.contains('internet') || name.contains('wifi')) {
      return Icons.wifi_rounded;
    }
    if (name.contains('phone') || name.contains('mobile')) {
      return Icons.phone_android_rounded;
    }

    return Icons.category_rounded;
  }
}
