import 'dart:ui';

import 'package:balance_iq/features/home/presentation/widgets/calendar_widgets/calendar_month_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomCalendarDateRangePicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Function(DateTime startDate, DateTime endDate) onDateRangeSelected;

  const CustomCalendarDateRangePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.minDate,
    this.maxDate,
    required this.onDateRangeSelected,
  });

  @override
  State<CustomCalendarDateRangePicker> createState() =>
      _CustomCalendarDateRangePickerState();
}

class _CustomCalendarDateRangePickerState
    extends State<CustomCalendarDateRangePicker> {
  late DateTime _displayedMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSelectingStart = true;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _displayedMonth = widget.initialStartDate ?? DateTime.now();
    if (_startDate != null && _endDate != null) {
      _isSelectingStart = false;
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      if (_isSelectingStart || _startDate == null) {
        // Selecting start date
        _startDate = date;
        _endDate = null;
        _isSelectingStart = false;
      } else {
        // Selecting end date
        if (date.isBefore(_startDate!)) {
          // If selected date is before start, swap them
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
      }
    });
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  void _onConfirm() {
    if (_startDate != null && _endDate != null) {
      widget.onDateRangeSelected(_startDate!, _endDate!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with month navigation
              _buildHeader(context, isDark),
              const SizedBox(height: 24),

              // Calendar month view
              CalendarMonthView(
                displayedMonth: _displayedMonth,
                startDate: _startDate,
                endDate: _endDate,
                today: DateTime.now(),
                onDateSelected: _onDateSelected,
                minDate: widget.minDate,
                maxDate: widget.maxDate,
              ),

              const SizedBox(height: 24),

              // Footer with range preview and actions
              _buildFooter(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous month button
        _buildNavigationButton(
          context,
          Icons.chevron_left_rounded,
          _previousMonth,
          isDark,
        ),

        // Month/Year display
        Text(
          DateFormat('MMMM yyyy').format(_displayedMonth),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.3,
              ),
        ),

        // Next month button
        _buildNavigationButton(
          context,
          Icons.chevron_right_rounded,
          _nextMonth,
          isDark,
        ),
      ],
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    final hasValidRange = _startDate != null && _endDate != null;

    return Column(
      children: [
        // Range preview
        if (hasValidRange) ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('MMM d').format(_startDate!),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Theme.of(context)
                        .iconTheme
                        .color
                        ?.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(_endDate!),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Action buttons
        Row(
          children: [
            // Cancel button
            Expanded(
              child: OutlinedButton(
                onPressed: _onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextTheme.of(context).bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Select button
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: hasValidRange
                      ? LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: hasValidRange ? null : Theme.of(context).disabledColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: hasValidRange
                      ? [
                          BoxShadow(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: hasValidRange ? _onConfirm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Select Range',
                    style: TextStyle(
                      color: hasValidRange
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).disabledColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
