import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$value', style: AppText.title.copyWith(fontSize: 26)),
                  Text(label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment {
  const _Segment(this.value, this.color);
  final int value;
  final Color color;
}

/// Categorias mutuamente exclusivas: lido, lendo agora e salvo.
class StatusDonutChart extends StatelessWidget {
  const StatusDonutChart({
    super.key,
    required this.read,
    required this.reading,
    required this.saved,
    this.size = 190,
  });

  final int read;
  final int reading;
  final int saved;
  final double size;

  int get total => read + reading + saved;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Gráfico de rosca: $read lidas, $reading lendo agora, $saved salvas sem status',
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: _DonutPainter([
                _Segment(read, AppColors.success),
                _Segment(reading, AppColors.accent),
                _Segment(saved, AppColors.warning),
              ]),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$total', style: AppText.title.copyWith(fontSize: 34)),
                Text(total == 1 ? 'obra' : 'obras', style: AppText.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.segments);
  final List<_Segment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.16;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);

    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.border,
    );

    final total = segments.fold<int>(0, (sum, s) => sum + s.value);
    if (total == 0) return;

    var start = -math.pi / 2;
    for (final seg in segments) {
      if (seg.value <= 0) continue;
      final sweep = seg.value / total * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = seg.color,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) {
    if (old.segments.length != segments.length) return true;
    for (var i = 0; i < segments.length; i++) {
      if (old.segments[i].value != segments[i].value ||
          old.segments[i].color != segments[i].color) {
        return true;
      }
    }
    return false;
  }
}
