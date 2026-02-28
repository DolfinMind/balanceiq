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
                    thickness: 42,
                    gapDegrees: 8,
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
  final double thickness;
  final double gapDegrees;

  _DonutPainter({
    required this.segments,
    this.thickness = 42,
    this.gapDegrees = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = min(size.width, size.height) / 2 - 4;
    final innerRadius = outerRadius - thickness;

    final totalGap = gapDegrees * segments.length;
    final availableDegrees = 360.0 - totalGap;

    final totalValue = segments.fold<double>(0, (s, seg) => s + seg.value);
    if (totalValue == 0) return;

    // Half gap in radians for the rounded-end inset

    final capRadius = thickness / 2; // radius for rounded ends

    double currentAngle = -90.0; // Start from top

    for (final seg in segments) {
      final sweepDeg = (seg.value / totalValue) * availableDegrees;
      final startRad = _toRadians(currentAngle);
      final sweepRad = _toRadians(sweepDeg);

      // Build filled path: outer arc → end cap → inner arc (reversed) → start cap
      final path = Path();

      // Outer arc
      final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
      path.addArc(outerRect, startRad, sweepRad);

      // End rounded cap: small semicircle connecting outer→inner at end angle
      final endAngle = startRad + sweepRad;
      final endCapCenter = Offset(
        center.dx + (outerRadius - capRadius) * cos(endAngle),
        center.dy + (outerRadius - capRadius) * sin(endAngle),
      );
      path.addArc(
        Rect.fromCircle(center: endCapCenter, radius: capRadius),
        endAngle,
        pi,
      );

      // Inner arc (reversed)
      final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
      path.addArc(innerRect, endAngle, -sweepRad);

      // Start rounded cap: semicircle connecting inner→outer at start angle
      final startCapCenter = Offset(
        center.dx + (outerRadius - capRadius) * cos(startRad),
        center.dy + (outerRadius - capRadius) * sin(startRad),
      );
      path.addArc(
        Rect.fromCircle(center: startCapCenter, radius: capRadius),
        startRad + pi,
        pi,
      );

      path.close();

      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      canvas.drawPath(path, paint);

      // Draw percentage label at midpoint of arc
      if (seg.percentage >= 5) {
        final midAngle = currentAngle + sweepDeg / 2;
        final midRad = _toRadians(midAngle);
        // Position label at the middle of the arc thickness
        final labelRadius = innerRadius + thickness / 2;
        final labelX = center.dx + labelRadius * cos(midRad);
        final labelY = center.dy + labelRadius * sin(midRad);

        final textSpan = TextSpan(
          text: '${seg.percentage.toStringAsFixed(0)}%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black.withValues(alpha: 0.4),
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

      currentAngle += sweepDeg + gapDegrees;
    }
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}
