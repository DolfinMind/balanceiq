import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:feature_chat/presentation/pages/chat_page.dart';

import 'package:dolfin_ui_kit/dolfin_ui_kit.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'add_transaction_bottom_sheet.dart';

/// Modern frosted glass floating bottom navigation bar.
/// Three items: History (left), Chat (center, primary), Add (right).
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(28),
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
                // --- History ---
                _NavItem(
                  onTap: () => _navigateToTransactions(context),
                  icon: LucideIcons.clock,
                  label: 'History',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  isDark: isDark,
                ),

                // --- Chat (Primary) ---
                _PrimaryChatItem(
                  onTap: () => _navigateToChat(context),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  isDark: isDark,
                ),

                // --- Add Transaction ---
                _NavItem(
                  onTap: () => _showAddTransactionSheet(context),
                  icon: LucideIcons.plus,
                  label: 'Add',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Standard nav item (History, Add)
class _NavItem extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isDark;

  const _NavItem({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.textTheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.85)
                    : colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.6)
                    : colorScheme.onSurface.withValues(alpha: 0.55),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Primary center nav item — Chat with emphasized circle
class _PrimaryChatItem extends StatelessWidget {
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isDark;

  const _PrimaryChatItem({
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Center(
                  child: AppLogo(
                    size: 24,
                    fit: BoxFit.cover,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Chat',
              style: textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
