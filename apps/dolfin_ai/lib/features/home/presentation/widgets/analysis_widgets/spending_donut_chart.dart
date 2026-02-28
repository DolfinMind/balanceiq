import 'dart:math';

import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:flutter/material.dart';

import '../../../../../core/di/injection_container.dart';

/// Spending donut chart with thick, rounded, separated segments.
/// Uses a CustomPainter with quadratic Bézier rounded corners
/// for each segment (inspired by the PandaPie approach).
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
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 12,
            children: segments.map((seg) {
              return Row(
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
                  const SizedBox(width: 6),
                  Text(
                    seg.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                        ),
                  ),
                ],
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

// ─── CustomPainter — rounded donut slices ────────────────────

class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;

  /// Ring thickness in logical pixels
  static const double _thickness = 40.0;

  /// Gap between segments in radians
  static const double _gapRad = 0.08;

  /// Corner rounding radius
  static const double _cornerRadius = 8.0;

  _DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = min(size.width, size.height) / 2;
    final innerR = outerR - _thickness;

    final totalVal = segments.fold<double>(0, (s, seg) => s + seg.value);
    if (totalVal == 0) return;

    double startAngle = -pi / 2; // 12 o'clock

    for (final seg in segments) {
      final sweep = (seg.value / totalVal) * 2 * pi;
      final realSweep = sweep - _gapRad;

      if (realSweep > 0) {
        final a0 = startAngle + _gapRad / 2;
        final a1 = a0 + realSweep;

        // Build rounded donut slice path
        final path = _roundedDonutSlice(
          center: center,
          rOuter: outerR,
          rInner: innerR,
          a0: a0,
          a1: a1,
          radius: _cornerRadius,
        );

        // Fill segment
        canvas.drawPath(
          path,
          Paint()
            ..color = seg.color
            ..style = PaintingStyle.fill
            ..isAntiAlias = true,
        );

        // % label at midpoint of arc
        if (seg.percentage >= 5) {
          final midAngle = a0 + realSweep / 2;
          final labelR = innerR + _thickness / 2;
          final lx = center.dx + labelR * cos(midAngle);
          final ly = center.dy + labelR * sin(midAngle);

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
      }

      startAngle += sweep;
    }
  }

  /// Constructs a closed Path for a single donut segment with
  /// rounded corners using quadratic Bézier curves.
  Path _roundedDonutSlice({
    required Offset center,
    required double rOuter,
    required double rInner,
    required double a0,
    required double a1,
    required double radius,
  }) {
    final path = Path();

    Offset p(double r, double a) =>
        Offset(center.dx + r * cos(a), center.dy + r * sin(a));

    final r = radius.clamp(0.0, (rOuter - rInner) / 2);

    // Start point: slightly inset along outer arc for corner rounding
    final o0s = p(rOuter, a0 + r / rOuter);
    path.moveTo(o0s.dx, o0s.dy);

    // Outer arc (between the two rounded corners)
    path.arcTo(
      Rect.fromCircle(center: center, radius: rOuter),
      a0 + r / rOuter,
      (a1 - a0) - 2 * r / rOuter,
      false,
    );

    // End corner: outer → radial transition (rounded)
    final o1 = p(rOuter, a1);
    final endInset = p(rOuter - r, a1);
    path.quadraticBezierTo(o1.dx, o1.dy, endInset.dx, endInset.dy);

    // Radial line: outer→inner at end angle
    final innerEndInset = p(rInner + r, a1);
    path.lineTo(innerEndInset.dx, innerEndInset.dy);

    // End corner: radial → inner arc transition (rounded)
    final i1 = p(rInner, a1);
    final innerEndArc = p(rInner, a1 - r / rInner);
    path.quadraticBezierTo(i1.dx, i1.dy, innerEndArc.dx, innerEndArc.dy);

    // Inner arc (reversed, between the two rounded corners)
    path.arcTo(
      Rect.fromCircle(center: center, radius: rInner),
      a1 - r / rInner,
      -((a1 - a0) - 2 * r / rInner),
      false,
    );

    // Start corner: inner → radial transition (rounded)
    final i0 = p(rInner, a0);
    final innerStartInset = p(rInner + r, a0);
    path.quadraticBezierTo(
        i0.dx, i0.dy, innerStartInset.dx, innerStartInset.dy);

    // Radial line: inner→outer at start angle
    final outerStartInset = p(rOuter - r, a0);
    path.lineTo(outerStartInset.dx, outerStartInset.dy);

    // Start corner: radial → outer arc transition (rounded)
    final o0 = p(rOuter, a0);
    path.quadraticBezierTo(o0.dx, o0.dy, o0s.dx, o0s.dy);

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => true;
}
