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
      return const Color(0xFFFF9800); // orange
    }
    if (name.contains('grocery')) {
      return const Color(0xFF66BB6A); // green
    }
    if (name.contains('transport')) {
      return const Color(0xFF42A5F5); // blue
    }
    if (name.contains('shop')) {
      return const Color(0xFFE91E63); // pink
    }
    if (name.contains('entertain')) {
      return const Color(0xFFAB47BC); // purple
    }
    if (name.contains('travel')) {
      return const Color(0xFF5C6BC0); // indigo
    }
    if (name.contains('bill') ||
        name.contains('util') ||
        name.contains('recharge')) {
      return const Color(0xFF26C6DA); // cyan
    }
    if (name.contains('rent') || name.contains('house')) {
      return const Color(0xFF7E57C2); // deep purple
    }
    if (name.contains('health') || name.contains('med')) {
      return const Color(0xFFEC407A); // rose
    }
    if (name.contains('salary') || name.contains('income')) {
      return const Color(0xFF5B8DEF); // soft blue
    }
    if (name.contains('education') || name.contains('school')) {
      return const Color(0xFF29B6F6); // light blue
    }
    if (name.contains('gift') || name.contains('donate')) {
      return const Color(0xFFFF7043); // deep orange
    }
    if (name.contains('insurance')) {
      return const Color(0xFF78909C); // blue-grey
    }
    if (name.contains('invest') || name.contains('saving')) {
      return const Color(0xFF009688); // teal
    }
    if (name.contains('subscription') || name.contains('member')) {
      return const Color(0xFFD4E157); // lime
    }
    if (name.contains('water')) {
      return const Color(0xFF00BCD4); // teal-cyan
    }
    if (name.contains('electric') || name.contains('power')) {
      return const Color(0xFFFFA726); // amber
    }
    if (name.contains('internet') || name.contains('wifi')) {
      return const Color(0xFF8D6E63); // brown
    }
    if (name.contains('phone') || name.contains('mobile')) {
      return const Color(0xFF4DB6AC); // teal light
    }

    // Deterministic fallback — same category always maps to same color
    const fallbackPalette = [
      Color(0xFFFFCA28), // amber
      Color(0xFF66BB6A), // green
      Color(0xFFFF7043), // deep orange
      Color(0xFF29B6F6), // light blue
      Color(0xFFD4E157), // lime
      Color(0xFF8D6E63), // brown
      Color(0xFF78909C), // blue-grey
      Color(0xFF4DB6AC), // teal
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
