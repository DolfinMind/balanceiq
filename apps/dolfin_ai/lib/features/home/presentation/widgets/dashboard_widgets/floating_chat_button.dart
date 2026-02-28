import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:feature_chat/presentation/pages/chat_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'add_transaction_bottom_sheet.dart';

/// Modern frosted glass floating bottom navigation bar.
/// Four icon-only items: Home (0), Chat (1), Graphs (2), Add (3).
class FloatingBottomNav extends StatefulWidget {
  final VoidCallback? onDashboardRefresh;
  final VoidCallback? onNavigateToGraphs;
  final VoidCallback? onNavigateHome;
  final int initialIndex;

  const FloatingBottomNav({
    super.key,
    this.onDashboardRefresh,
    this.onNavigateToGraphs,
    this.onNavigateHome,
    this.initialIndex = 0,
  });

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _navigateToChat() async {
    setState(() => _selectedIndex = 1);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          botId: "nai kichu",
          botName: 'Donfin AI',
        ),
      ),
    );
    if (mounted) setState(() => _selectedIndex = widget.initialIndex);
    widget.onDashboardRefresh?.call();
  }

  void _showAddTransactionSheet() {
    setState(() => _selectedIndex = 3);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionBottomSheet(
        onSuccess: () {
          widget.onDashboardRefresh?.call();
        },
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _selectedIndex = widget.initialIndex);
    });
  }

  void _onTapHome() {
    if (_selectedIndex == 0) return;
    setState(() => _selectedIndex = 0);
    widget.onNavigateHome?.call();
  }

  void _onTapGraphs() {
    if (_selectedIndex == 2) return;
    setState(() => _selectedIndex = 2);
    widget.onNavigateToGraphs?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
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
                  index: 0,
                  icon: LucideIcons.house,
                  colorScheme: colorScheme,
                  isDark: isDark,
                  onTap: _onTapHome,
                ),
                _navIcon(
                  index: 1,
                  icon: LucideIcons.messageCircle,
                  colorScheme: colorScheme,
                  isDark: isDark,
                  onTap: _navigateToChat,
                ),
                _navIcon(
                  index: 2,
                  icon: LucideIcons.chartLine,
                  colorScheme: colorScheme,
                  isDark: isDark,
                  onTap: _onTapGraphs,
                ),
                _navIcon(
                  index: 3,
                  icon: LucideIcons.plus,
                  colorScheme: colorScheme,
                  isDark: isDark,
                  onTap: _showAddTransactionSheet,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navIcon({
    required int index,
    required IconData icon,
    required ColorScheme colorScheme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isSelected
              ? colorScheme.primary
              : isDark
                  ? Colors.white.withValues(alpha: 0.55)
                  : colorScheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
