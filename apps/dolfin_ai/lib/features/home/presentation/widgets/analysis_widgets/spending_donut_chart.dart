import 'dart:math';

import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:flutter/material.dart';

import '../../../../../core/di/injection_container.dart';

/// Spending donut chart with thick rounded arc segments.
/// Custom painted to match the reference design exactly.
class SpendingDonutChart extends StatelessWidget {
  final Map<String, double> categories;
  final double totalExpense;

  const SpendingDonutChart({
    super.key,
    required this.categories,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty || totalExpense <= 0) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currencyCubit = sl<CurrencyCubit>();

    final sortedEntries = categories.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    final total = sortedEntries.fold<double>(
      0,
      (sum, e) => sum + e.value.abs(),
    );

    // Build segment data with colors
    final segments = sortedEntries.asMap().entries.map((mapEntry) {
      final index = mapEntry.key;
      final entry = mapEntry.value;
      final pct = total > 0 ? (entry.value.abs() / total * 100) : 0.0;
      return _DonutSegment(
        label: entry.key,
        value: entry.value.abs(),
        percentage: pct,
        color: _getCategoryColor(entry.key, index),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Donut with center text
          SizedBox(
            height: 280,
            width: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(280, 280),
                  painter: _DonutPainter(
                    segments: segments,
                    strokeWidth: 38,
                    gapDegrees: 5,
                  ),
                ),
                // Center label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Expense',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyCubit.formatAmount(totalExpense),
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        letterSpacing: -0.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Legend — 2-column grid
          Wrap(
            spacing: 8,
            runSpacing: 14,
            children: segments.map((seg) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 64) / 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: seg.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        seg.label,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category, int index) {
    final name = category.toLowerCase();
    if (name.contains('food') || name.contains('dining')) {
      return const Color(0xFF4CAF50);
    }
    if (name.contains('grocery')) return const Color(0xFFEF5350);
    if (name.contains('transport')) return const Color(0xFF42A5F5);
    if (name.contains('shop')) return const Color(0xFFFFA726);
    if (name.contains('entertain')) return const Color(0xFFAB47BC);
    if (name.contains('travel')) return const Color(0xFF5C6BC0);
    if (name.contains('bill') ||
        name.contains('util') ||
        name.contains('recharge')) {
      return const Color(0xFF26C6DA);
    }
    if (name.contains('rent') || name.contains('house')) {
      return const Color(0xFF7E57C2);
    }
    if (name.contains('health') || name.contains('med')) {
      return const Color(0xFFEC407A);
    }

    final colors = [
      const Color(0xFFFFCA28),
      const Color(0xFF66BB6A),
      const Color(0xFFFF7043),
      const Color(0xFF29B6F6),
      const Color(0xFFD4E157),
      const Color(0xFF8D6E63),
    ];
    return colors[index % colors.length];
  }
}

// ─── Data model ──────────────────────────────────────────────

class _DonutSegment {
  final String label;
  final double value;
  final double percentage;
  final Color color;

  const _DonutSegment({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });
}

// ─── CustomPainter ───────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final double strokeWidth;
  final double gapDegrees;

  _DonutPainter({
    required this.segments,
    this.strokeWidth = 38,
    this.gapDegrees = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final totalGap = gapDegrees * segments.length;
    final availableDegrees = 360.0 - totalGap;

    // Calculate total value
    final totalValue = segments.fold<double>(0, (s, seg) => s + seg.value);
    if (totalValue == 0) return;

    double startAngle = -90; // Start from top

    for (final seg in segments) {
      final sweepAngle = (seg.value / totalValue) * availableDegrees;

      // Draw arc
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
          rect, _toRadians(startAngle), _toRadians(sweepAngle), false, paint);

      // Draw percentage label at midpoint of arc
      if (seg.percentage >= 5) {
        final midAngle = startAngle + sweepAngle / 2;
        final labelRadius = radius; // On the arc
        final labelX = center.dx + labelRadius * cos(_toRadians(midAngle));
        final labelY = center.dy + labelRadius * sin(_toRadians(midAngle));

        final textSpan = TextSpan(
          text: '${seg.percentage.toStringAsFixed(0)}%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                blurRadius: 6,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ],
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(
            labelX - textPainter.width / 2,
            labelY - textPainter.height / 2,
          ),
        );
      }

      startAngle += sweepAngle + gapDegrees;
    }
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}
