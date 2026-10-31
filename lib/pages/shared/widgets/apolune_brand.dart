import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:apolune/pages/theme/color.dart';
import 'package:apolune/pages/theme/font.dart';

/// Знак Apolune: планета с кольцом и точка на орбите — «аполуна».
///
/// Кольцо проходит за планетой, а спереди вырезается цветом фона [bg].
/// Знак рассчитан на размер от 32 px; ниже кольцо сливается.
class ApoluneMark extends StatelessWidget {
  const ApoluneMark({
    super.key,
    this.size = 26,
    this.color,
    this.accent,
    this.bg,
  });

  final double size;
  final Color? color;
  final Color? accent;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    final palette = ColorManager.palette(context);
    return SizedBox(
      width: size,
      height: size * 0.62,
      child: CustomPaint(
        painter: _ApoluneMarkPainter(
          color: color ?? palette.foreground,
          accent: accent ?? palette.primary,
          bg: bg ?? palette.background,
        ),
      ),
    );
  }
}

/// Логотип в сборе: знак и слово.
class ApoluneBrand extends StatelessWidget {
  const ApoluneBrand({
    super.key,
    this.size = 26,
    this.style,
    this.centered = false,
    this.color,
    this.bg,
  });

  final double size;
  final TextStyle? style;
  final bool centered;
  final Color? color;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    final palette = ColorManager.palette(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        ApoluneMark(
          size: size,
          color: color ?? palette.foreground,
          accent: palette.primary,
          bg: bg ?? palette.background,
        ),
        SizedBox(width: size * 0.18),
        Flexible(
          child: Text(
            'Apolune',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: style ?? AppTypography.setupBrand,
          ),
        ),
      ],
    );
  }
}

class _ApoluneMarkPainter extends CustomPainter {
  _ApoluneMarkPainter({
    required this.color,
    required this.accent,
    required this.bg,
  });

  final Color color;
  final Color accent;
  final Color bg;

  static const _tilt = -20 * math.pi / 180;

  // Пропорции взяты из design/logo/apolune-mark.svg (viewBox 1024).
  static const _planet = 0.209;
  static const _rx = 0.344;
  static const _ry = 0.129;
  static const _stroke = 0.033;
  static const _dotX = 0.823;
  static const _dotY = 0.383;
  static const _dotR = 0.035;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final c = Offset(w * 0.5, size.height * 0.5);
    final r = w * _planet;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * _stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: w * _rx * 2,
      height: w * _ry * 2,
    );

    // Задняя половина кольца
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(_tilt);
    canvas.drawOval(rect, ring);
    canvas.restore();

    // Планета
    canvas.drawCircle(c, r, Paint()..color = color);

    // Передняя дуга: вырезаем только пересечение с планетой
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    canvas.translate(c.dx, c.dy);
    canvas.rotate(_tilt);
    canvas.clipRect(Rect.fromLTWH(-w, 0, w * 2, w));
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * _stroke
        ..strokeCap = StrokeCap.round
        ..color = bg,
    );
    canvas.restore();

    // Точка на орбите
    canvas.drawCircle(
      c + Offset((_dotX - 0.5) * w, (_dotY - 0.5) * w),
      w * _dotR,
      Paint()..color = accent,
    );
  }

  @override
  bool shouldRepaint(covariant _ApoluneMarkPainter old) =>
      old.color != color || old.accent != accent || old.bg != bg;
}
