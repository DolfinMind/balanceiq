import 'package:get_it/get_it.dart';
import 'package:balance_iq/core/strings/dashboard_strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DateSelectorBottomSheet extends StatefulWidget {
  final Function(DateTime start, DateTime end, String? label) onDateSelected;
  final VoidCallback? onCustomRangePressed;
  final String? currentLabel;

  const DateSelectorBottomSheet({
    super.key,
    required this.onDateSelected,
    this.onCustomRangePressed,
    this.currentLabel,
  });

  @override
  State<DateSelectorBottomSheet> createState() =>
      _DateSelectorBottomSheetState();
}

class _DateSelectorBottomSheetState extends State<DateSelectorBottomSheet> {
  String? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _initializeSelection();
  }

  void _initializeSelection() {
    if (widget.currentLabel == 'Last 30 Days') {
      _selectedPreset = 'last_30_days';
    } else if (widget.currentLabel == _getPresetLabel('this_month')) {
      _selectedPreset = 'this_month';
    } else if (widget.currentLabel == _getPresetLabel('last_month')) {
      _selectedPreset = 'last_month';
    } else if (widget.currentLabel == _getPresetLabel('last_3_months')) {
      _selectedPreset = 'last_3_months';
    } else if (widget.currentLabel == _getPresetLabel('this_year')) {
      _selectedPreset = 'this_year';
    } else {
      _selectedPreset = null;
    }
  }

  String _getPresetLabel(String key) {
    final now = DateTime.now();
    switch (key) {
      case 'this_month':
        return DateFormat('MMMM yyyy').format(now);
      case 'last_month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        return DateFormat('MMMM yyyy').format(lastMonth);
      case 'this_year':
        return DateFormat('yyyy').format(now);
      case 'last_3_months':
        final start = DateTime(now.year, now.month - 2, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        if (start.year == end.year) {
          return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
        }
        return '${DateFormat('MMM d, yyyy').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 32, left: 20, right: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            GetIt.I<DashboardStrings>().selectDateRange,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Presets Grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildPresetChip(
                context,
                label: 'This Month',
                presetKey: 'this_month',
                onTap: () {
                  final now = DateTime.now();
                  final start = DateTime(now.year, now.month, 1);
                  final end = DateTime(now.year, now.month + 1, 0);
                  widget.onDateSelected(
                      start, end, _getPresetLabel('this_month'));
                  Navigator.pop(context);
                },
              ),
              _buildPresetChip(
                context,
                label: 'Last Month',
                presetKey: 'last_month',
                onTap: () {
                  final now = DateTime.now();
                  final start = DateTime(now.year, now.month - 1, 1);
                  final end = DateTime(now.year, now.month, 0);
                  widget.onDateSelected(
                      start, end, _getPresetLabel('last_month'));
                  Navigator.pop(context);
                },
              ),
              _buildPresetChip(
                context,
                label: 'Last 3 Months',
                presetKey: 'last_3_months',
                onTap: () {
                  final now = DateTime.now();
                  final start = DateTime(now.year, now.month - 2, 1);
                  final end = DateTime(now.year, now.month + 1, 0);
                  widget.onDateSelected(
                      start, end, _getPresetLabel('last_3_months'));
                  Navigator.pop(context);
                },
              ),
              _buildPresetChip(
                context,
                label: 'Last 30 Days',
                presetKey: 'last_30_days',
                onTap: () {
                  final now = DateTime.now();
                  final start = now.subtract(const Duration(days: 30));
                  final end = now;
                  widget.onDateSelected(start, end, 'Last 30 Days');
                  Navigator.pop(context);
                },
              ),
              _buildPresetChip(
                context,
                label: 'This Year',
                presetKey: 'this_year',
                onTap: () {
                  final now = DateTime.now();
                  final start = DateTime(now.year, 1, 1);
                  final end = DateTime(now.year, 12, 31);
                  widget.onDateSelected(
                      start, end, _getPresetLabel('this_year'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Simple divider
          Divider(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            height: 1,
          ),

          const SizedBox(height: 16),

          // Custom range button
          InkWell(
            onTap: () {
              if (widget.onCustomRangePressed != null) {
                widget.onCustomRangePressed!();
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      LucideIcons.calendar,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      GetIt.I<DashboardStrings>().customRange,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(
    BuildContext context, {
    required String label,
    required String presetKey,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedPreset == presetKey;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPreset = presetKey;
        });
        Future.delayed(const Duration(milliseconds: 150), onTap);
      },
      borderRadius: BorderRadius.circular(50),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
