import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Modern frosted glass floating bottom navigation bar.
/// Three icon-only items: Home (0), Analysis (1), Add (2).
/// Home and Analysis work as tabs via [onTabChanged].
/// Add opens a modal and returns to the previous tab.
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 48, // Reduced visual space
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.75), // Darker in light mode
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.1),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              _navIcon(
                index: 0,
                icon: LucideIcons.layoutDashboard,
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: () => _onTapTab(0),
              ),
              const SizedBox(width: 16),
              _navIcon(
                index: 1,
                icon: LucideIcons.chartPie,
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: () => _onTapTab(1),
              ),
              const SizedBox(width: 16),
              _navIcon(
                index: 2,
                icon: LucideIcons.circlePlus,
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: () => _onTapTab(2),
              ),
            ],
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
        width: 36, // Reduced to take less visual space
        height: 36, // Reduced to take less visual space
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          size: 20, // Slightly smaller icon
          color: isSelected
              ? colorScheme.primary
              : Colors.white.withValues(
                  alpha:
                      0.55), // Always white-ish since background is dark in both modes
        ),
      ),
    );
  }
}
