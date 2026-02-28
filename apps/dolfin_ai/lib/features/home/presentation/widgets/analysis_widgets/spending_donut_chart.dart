import 'dart:math';

import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:flutter/material.dart';

import '../../../../../core/di/injection_container.dart';

/// Spending donut chart with thick rounded arc segments.
/// Custom painted to match the reference design.
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
          SizedBox(
            height: 260,
            width: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(260, 260),
                  painter: _DonutPainter(segments: segments),
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
                        fontSize: 22,
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

/// Simple, clean donut painter.
/// Draws each segment as a stroked arc (butt cap) + two filled circles
/// at the endpoints to create rounded ends without overlap.
class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;

  static const double _strokeWidth = 36;
  static const double _gapDeg = 6;

  _DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - _strokeWidth) / 2;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final totalGapDeg = _gapDeg * segments.length;
    final usableDeg = 360.0 - totalGapDeg;

    final totalVal = segments.fold<double>(0, (s, seg) => s + seg.value);
    if (totalVal == 0) return;

    final capR = _strokeWidth / 2;
    double angle = -90.0; // 12 o'clock

    for (final seg in segments) {
      final sweepDeg = (seg.value / totalVal) * usableDeg;
      final startRad = angle * pi / 180;
      final endRad = (angle + sweepDeg) * pi / 180;

      // 1) Draw the arc with butt caps (no overlap)
      final arcPaint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(arcRect, startRad, sweepDeg * pi / 180, false, arcPaint);

      // 2) Draw filled circles at both endpoints for rounded ends
      final capPaint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.fill;

      // Start cap
      canvas.drawCircle(
        Offset(
          center.dx + radius * cos(startRad),
          center.dy + radius * sin(startRad),
        ),
        capR,
        capPaint,
      );

      // End cap
      canvas.drawCircle(
        Offset(
          center.dx + radius * cos(endRad),
          center.dy + radius * sin(endRad),
        ),
        capR,
        capPaint,
      );

      // 3) Percentage label at midpoint
      if (seg.percentage >= 5) {
        final midRad = (angle + sweepDeg / 2) * pi / 180;
        final lx = center.dx + radius * cos(midRad);
        final ly = center.dy + radius * sin(midRad);

        final tp = TextPainter(
          text: TextSpan(
            text: '${seg.percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
      }

      angle += sweepDeg + _gapDeg;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => true;
}
