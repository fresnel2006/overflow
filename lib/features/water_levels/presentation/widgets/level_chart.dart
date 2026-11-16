import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/station.dart';

/// Courbe du niveau d'eau avec les seuils de vigilance et de danger.
class LevelChart extends StatelessWidget {
  const LevelChart({super.key, required this.readings, required this.vigilanceCm, required this.dangerCm, this.height = 180});

  final List<WaterReading> readings;
  final double vigilanceCm;
  final double dangerCm;
  final double height;

  @override
  Widget build(BuildContext context) {
    final last = readings.isEmpty ? null : readings.last;
    return Semantics(
      label: last == null ? null : 'Courbe du niveau d\'eau, dernière mesure ${Fmt.cm(last.levelCm)}',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _ChartPainter(readings, vigilanceCm, dangerCm)),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.data, this.vigilance, this.danger);

  final List<WaterReading> data;
  final double vigilance;
  final double danger;

  static const _left = 34.0;
  static const _bottom = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final chart = Rect.fromLTRB(_left, 6, size.width - 4, size.height - _bottom);
    final maxV = math.max(danger * 1.2, data.map((r) => r.levelCm).reduce(math.max) * 1.1);
    final t0 = data.first.time.millisecondsSinceEpoch.toDouble();
    final t1 = data.last.time.millisecondsSinceEpoch.toDouble();
    Offset pt(WaterReading r) => Offset(
      chart.left + (r.time.millisecondsSinceEpoch - t0) / math.max(1, t1 - t0) * chart.width,
      chart.bottom - (r.levelCm / maxV) * chart.height,
    );
    double y(double v) => chart.bottom - v / maxV * chart.height;

    // Grille et graduations.
    final grid = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;
    final label = AppText.caption.copyWith(fontSize: 9.5, color: AppColors.textMuted);
    for (var i = 0; i <= 4; i++) {
      final v = maxV * i / 4;
      canvas.drawLine(Offset(chart.left, y(v)), Offset(chart.right, y(v)), grid);
      _text(canvas, '${v.round()}', Offset(0, y(v) - 6), label, width: _left - 6, align: TextAlign.right);
    }
    for (var i = 0; i <= 4; i++) {
      final r = data[((data.length - 1) * i / 4).round()];
      final x = pt(r).dx;
      _text(canvas, Fmt.hour(r.time), Offset(x - 18, chart.bottom + 5), label, width: 36, align: TextAlign.center);
    }

    // Seuils.
    void threshold(double v, Color c) {
      final p = Paint()
        ..color = c
        ..strokeWidth = 1.2;
      for (var x = chart.left; x < chart.right; x += 8) {
        canvas.drawLine(Offset(x, y(v)), Offset(math.min(x + 4, chart.right), y(v)), p);
      }
    }

    threshold(vigilance, AppColors.warning);
    threshold(danger, AppColors.danger);

    // Aire et courbe.
    final line = Path()..moveTo(pt(data.first).dx, pt(data.first).dy);
    for (var i = 1; i < data.length; i++) {
      final a = pt(data[i - 1]);
      final b = pt(data[i]);
      final mid = (a.dx + b.dx) / 2;
      line.cubicTo(mid, a.dy, mid, b.dy, b.dx, b.dy);
    }
    final area = Path.from(line)
      ..lineTo(pt(data.last).dx, chart.bottom)
      ..lineTo(pt(data.first).dx, chart.bottom)
      ..close();
    canvas.drawPath(
      area,
      Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.primary.withValues(alpha: 0.25), AppColors.primary.withValues(alpha: 0.02)]).createShader(chart),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    final end = pt(data.last);
    canvas.drawCircle(end, 5.5, Paint()..color = Colors.white);
    canvas.drawCircle(end, 3.8, Paint()..color = AppColors.primary);
  }

  void _text(Canvas c, String s, Offset o, TextStyle style, {required double width, TextAlign align = TextAlign.left}) {
    final tp = TextPainter(text: TextSpan(text: s, style: style), textAlign: align, textDirection: TextDirection.ltr)..layout(minWidth: width, maxWidth: width);
    tp.paint(c, o);
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.data != data;
}
