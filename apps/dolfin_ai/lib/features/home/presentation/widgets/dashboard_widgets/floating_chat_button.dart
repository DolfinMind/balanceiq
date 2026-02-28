import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:feature_chat/presentation/pages/chat_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'add_transaction_bottom_sheet.dart';

/// Modern frosted glass floating bottom navigation bar.
/// Three icon-only items: History (left), Chat (center), Add (right).
class FloatingBottomNav extends StatelessWidget {
  final VoidCallback? onDashboardRefresh;
  final VoidCallback? onViewAllTransactions;

  const FloatingBottomNav({
    super.key,
    this.onDashboardRefresh,
    this.onViewAllTransactions,
  });

  void _navigateToChat(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          botId: "nai kichu",
          botName: 'Donfin AI',
        ),
      ),
    );
    onDashboardRefresh?.call();
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionBottomSheet(
        onSuccess: () {
          onDashboardRefresh?.call();
        },
      ),
    );
  }

  void _navigateToTransactions(BuildContext context) async {
    final hasChanges = await Navigator.pushNamed(context, '/transactions');
    if (hasChanges == true) {
      onDashboardRefresh?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = isDark
        ? Colors.white.withValues(alpha: 0.85)
        : colorScheme.onSurface.withValues(alpha: 0.7);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navIcon(
                  onTap: () => _navigateToTransactions(context),
                  icon: LucideIcons.clock,
                  color: iconColor,
                ),
                _navIcon(
                  onTap: () => _navigateToChat(context),
                  icon: LucideIcons.messageCircle,
                  color: iconColor,
                ),
                _navIcon(
                  onTap: () => _showAddTransactionSheet(context),
                  icon: LucideIcons.plus,
                  color: iconColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navIcon({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }
}
