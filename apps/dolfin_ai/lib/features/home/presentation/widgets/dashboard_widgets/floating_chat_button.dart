import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:feature_chat/presentation/pages/chat_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'add_transaction_bottom_sheet.dart';

/// Modern frosted glass floating bottom navigation bar.
/// Four icon-only items: Home (0), Analysis (1), Chat (2), Add (3).
/// Home and Analysis work as tabs via [onTabChanged].
/// Chat and Add open modals and return to the previous tab.
class FloatingBottomNav extends StatefulWidget {
  final VoidCallback? onDashboardRefresh;
  final ValueChanged<int>? onTabChanged;
  final int selectedTab;

  const FloatingBottomNav({
    super.key,
    this.onDashboardRefresh,
    this.onTabChanged,
    this.selectedTab = 0,
  });

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav> {
  /// Tracks visual selection (may differ from tab during modal actions)
  late int _visualIndex;

  @override
  void initState() {
    super.initState();
    _visualIndex = widget.selectedTab;
  }

  @override
  void didUpdateWidget(covariant FloatingBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTab != oldWidget.selectedTab) {
      _visualIndex = widget.selectedTab;
    }
  }

  void _onTapTab(int index) {
    if (_visualIndex == index) return;
    setState(() => _visualIndex = index);
    widget.onTabChanged?.call(index);
  }

  void _navigateToChat() async {
    setState(() => _visualIndex = 2);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          botId: "nai kichu",
          botName: 'Donfin AI',
        ),
      ),
    );
    if (mounted) setState(() => _visualIndex = widget.selectedTab);
    widget.onDashboardRefresh?.call();
  }

  void _showAddTransactionSheet() {
    setState(() => _visualIndex = 3);
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
      if (mounted) setState(() => _visualIndex = widget.selectedTab);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
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
                  onTap: () => _onTapTab(0),
                ),
                _navIcon(
                  index: 1,
                  icon: LucideIcons.chartLine,
                  colorScheme: colorScheme,
                  isDark: isDark,
                  onTap: () => _onTapTab(1),
                ),
                _navIcon(
                  index: 2,
                  icon: LucideIcons.messageCircle,
                  colorScheme: colorScheme,
                  isDark: isDark,
                  onTap: _navigateToChat,
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
    final isSelected = _visualIndex == index;

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
