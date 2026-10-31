import 'dart:math' as math;
import 'package:flutter/material.dart';

// ── Токены «ретро-плакат» ────────────────────────────────────────────────
const paper = Color(0xFFEDE8DC);
const paper2 = Color(0xFFE3DCCB);
const ink = Color(0xFF16150F);
const red = Color(0xFFC0402B);
const petrol = Color(0xFF2C4A47);
const amber = Color(0xFFC9761F);
const olive = Color(0xFF5A5A33);
const gold = Color(0xFFC9A227);
const steel = Color(0xFF8C8C86);

TextStyle display(
  double size, {
  Color color = ink,
  double weight = 700,
  double spacing = 0.5,
}) =>
    TextStyle(
      fontFamily: 'Oswald',
      fontSize: size,
      color: color,
      letterSpacing: spacing,
      height: 1.02,
      fontVariations: [FontVariation('wght', weight)],
    );

TextStyle label(
  double size, {
  Color color = steel,
  double spacing = 2.4,
}) =>
    TextStyle(
      fontFamily: 'Golos',
      fontSize: size,
      color: color,
      letterSpacing: spacing,
      fontWeight: FontWeight.w500,
      height: 1.1,
    );

TextStyle mono(
  double size, {
  Color color = ink,
  double weight = 500,
}) =>
    TextStyle(
      fontFamily: 'Mono',
      fontSize: size,
      color: color,
      fontVariations: [FontVariation('wght', weight)],
      height: 1.1,
    );

void main() => runApp(const ApoluneProto());

class ApoluneProto extends StatelessWidget {
  const ApoluneProto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Apolune',
      home: const PosterPage(),
    );
  }
}

class PosterPage extends StatelessWidget {
  const PosterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: OrbitPainter())),
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 28, 36, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _TopBar(),
                const SizedBox(height: 26),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(flex: 46, child: _PosterCard()),
                      const SizedBox(width: 22),
                      const Expanded(flex: 33, child: _StatusPanel()),
                      const SizedBox(width: 22),
                      SizedBox(width: 250, child: _Ticket()),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const _BottomBar(),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.55,
                child: Image.asset(
                  'assets/grain.png',
                  repeat: ImageRepeat.repeat,
                  fit: BoxFit.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Верхняя навигация ────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _nav('ПОДКЛЮЧЕНИЕ', active: true),
        const SizedBox(width: 26),
        _nav('СЕРВЕРЫ'),
        const SizedBox(width: 26),
        _nav('ПОДПИСКА'),
        const SizedBox(width: 26),
        _nav('НАСТРОЙКИ'),
        const Spacer(),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 16, 8),
          decoration: BoxDecoration(
            color: petrol,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: gold, width: 1.5),
                ),
                child: const Icon(Icons.public, size: 14, color: paper),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('МОЯ ПОДПИСКА',
                      style: label(8.5, color: paper.withValues(alpha: 0.65), spacing: 2)),
                  const SizedBox(height: 2),
                  Text('29 ДНЕЙ',
                      style: display(13, color: paper, weight: 600, spacing: 1.4)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _nav(String text, {bool active = false}) {
    if (active) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 7, 16, 8),
        decoration: BoxDecoration(
          color: red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: display(15, color: paper, weight: 600, spacing: 1.6)),
      );
    }
    return Text(text, style: display(15, color: ink, weight: 600, spacing: 1.6));
  }
}

// ── Карточка-постер сервера ──────────────────────────────────────────────
class _PosterCard extends StatelessWidget {
  const _PosterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ink.withValues(alpha: 0.18),
            offset: const Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF27403C), Color(0xFF12110C)],
                ),
              ),
            ),
            Positioned.fill(child: CustomPaint(painter: PlanetPainter())),
            Positioned.fill(child: CustomPaint(painter: HalftonePainter())),
            Positioned.fill(child: CustomPaint(painter: StripePainter())),
            Positioned(
              right: -18,
              bottom: -46,
              child: Text(
                'DE',
                style: display(230,
                    color: paper.withValues(alpha: 0.055), weight: 700),
              ),
            ),
            Positioned(
              left: 22,
              top: 20,
              child: Text('01', style: mono(11, color: paper.withValues(alpha: 0.45))),
            ),
            Positioned(
              right: 18,
              top: 20,
              child: Transform.rotate(
                angle: -6 * math.pi / 180,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 7, 12, 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: red, width: 2),
                  ),
                  child: Text('ЗАЩИЩЕНО',
                      style: display(17, color: red, weight: 700, spacing: 3.2)),
                ),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('СЕРВЕР', style: label(9, color: paper.withValues(alpha: 0.5))),
                  const SizedBox(height: 6),
                  Text('ГЕРМАНИЯ',
                      style: display(38, color: paper, weight: 700, spacing: 1)),
                  const SizedBox(height: 6),
                  Text('ФРАНКФУРТ · VLESS + REALITY',
                      style: label(9,
                          color: paper.withValues(alpha: 0.55), spacing: 1.8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Панель состояния ─────────────────────────────────────────────────────
class _StatusPanel extends StatelessWidget {
  const _StatusPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('СОСТОЯНИЕ', style: label(9)),
        const SizedBox(height: 8),
        Text('ПОДКЛЮЧЕНО',
            style: display(46, color: ink, weight: 700, spacing: 1)),
        const SizedBox(height: 18),
        Text('00:12:47', style: mono(44, color: ink, weight: 600)),
        const SizedBox(height: 18),
        Container(height: 1, color: ink.withValues(alpha: 0.12)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _stat('СКАЧАНО', '1.24 ГБ')),
            Expanded(child: _stat('ОТДАНО', '214 МБ')),
          ],
        ),
        const SizedBox(height: 18),
        Container(height: 3, color: ink.withValues(alpha: 0.10)),
        const SizedBox(height: 10),
        Row(
          children: [
            Text('127.0.0.1 → DE-FRA-03 → ИНТЕРНЕТ',
                style: mono(9.5, color: steel)),
            const Spacer(),
            const _SignalLadder(),
          ],
        ),
        const Spacer(),
        _Capsule(
          text: 'ОТКЛЮЧИТЬ',
          background: red,
          foreground: paper,
        ),
        const SizedBox(height: 12),
        _Capsule(
          text: 'СМЕНИТЬ СЕРВЕР',
          background: Colors.transparent,
          foreground: ink,
          border: ink,
        ),
      ],
    );
  }

  Widget _stat(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: label(8.5)),
        const SizedBox(height: 4),
        Text(value, style: mono(18, color: ink, weight: 500)),
      ],
    );
  }
}

class _Capsule extends StatelessWidget {
  const _Capsule({
    required this.text,
    required this.background,
    required this.foreground,
    this.border,
  });

  final String text;
  final Color background;
  final Color foreground;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: border == null
            ? null
            : Border.all(color: border!.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Text(text,
          style: display(17, color: foreground, weight: 600, spacing: 2.6)),
    );
  }
}

// ── Билет подписки ───────────────────────────────────────────────────────
class _Ticket extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: paper2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ink.withValues(alpha: 0.12)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: PerforationPainter()),
          ),
          Positioned(
            right: 12,
            top: 54,
            child: Transform.rotate(
              angle: 8 * math.pi / 180,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 5),
                decoration: BoxDecoration(
                  border: Border.all(color: red, width: 1.5),
                ),
                child: Text('АКТИВНА',
                    style: display(11, color: red, weight: 700, spacing: 2)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ПОДПИСКА', style: label(9)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('29',
                        style: display(58, color: ink, weight: 700)),
                    const SizedBox(width: 8),
                    Text('ДНЕЙ', style: label(9)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('ДО 29 НОЯБРЯ 2026', style: label(8, spacing: 1.6)),
                const SizedBox(height: 10),
                Text('№ 000-29-11-А', style: mono(9, color: steel)),
                const Spacer(),
                const _Barcode(),
                const SizedBox(height: 16),
                Text('ТРАФИК', style: label(9)),
                const SizedBox(height: 8),
                const _TrafficTicks(filled: 7, total: 12),
                const SizedBox(height: 8),
                Text('124 / 500 ГБ', style: mono(11, color: ink)),
                const SizedBox(height: 18),
                Container(height: 1, color: ink.withValues(alpha: 0.12)),
                const SizedBox(height: 14),
                Text('ПРОДЛИТЬ',
                    style: display(14, color: red, weight: 600, spacing: 2.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Barcode extends StatelessWidget {
  const _Barcode();

  @override
  Widget build(BuildContext context) {
    const widths = [2.0, 5.0, 2.0, 3.0, 6.0, 2.0, 4.0, 2.0, 5.0, 3.0,
                    2.0, 6.0, 2.0, 3.0, 4.0, 2.0, 5.0, 2.0];
    return SizedBox(
      height: 26,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final w in widths)
            Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Container(width: w, color: ink.withValues(alpha: 0.72)),
            ),
        ],
      ),
    );
  }
}

class _SignalLadder extends StatelessWidget {
  const _SignalLadder();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Container(
              width: 3,
              height: 4.0 + i * 3,
              color: i < 4 ? ink : ink.withValues(alpha: 0.22),
            ),
          ),
      ],
    );
  }
}

class _TrafficTicks extends StatelessWidget {
  const _TrafficTicks({required this.filled, required this.total});

  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final on = i < filled;
        return Expanded(
          child: Container(
            height: 14,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 3),
            color: on ? ink : Colors.transparent,
            foregroundDecoration: on
                ? null
                : BoxDecoration(
                    border: Border.all(
                        color: ink.withValues(alpha: 0.25), width: 1)),
          ),
        );
      }),
    );
  }
}

// ── Нижняя строка ────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('APOLUNE BUILD 0.1 · NODE DE-FRA-03 · 124 МС',
            style: mono(10, color: steel)),
        const Spacer(),
        const _Hint('A', 'ПОДКЛЮЧИТЬ'),
        const SizedBox(width: 18),
        const _Hint('X', 'НАСТРОЙКИ'),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.glyph, this.text);

  final String glyph;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ink, shape: BoxShape.circle),
          child: Text(glyph, style: mono(10, color: paper, weight: 700)),
        ),
        const SizedBox(width: 7),
        Text(text, style: label(8.5, color: ink, spacing: 1.6)),
      ],
    );
  }
}

// ── Графика ──────────────────────────────────────────────────────────────
class OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink.withValues(alpha: 0.07);
    final center = Offset(size.width * 0.12, size.height * 1.05);
    for (final r in [380.0, 520.0, 680.0, 860.0]) {
      canvas.drawCircle(center, r, paint);
    }
    final dot = Paint()..color = red.withValues(alpha: 0.55);
    canvas.drawCircle(
      center + Offset(520 * math.cos(-1.15), 520 * math.sin(-1.15)),
      3.2,
      dot,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(
        Rect.fromLTWH(0, size.height * 0.60, size.width, size.height * 0.40));
    canvas.translate(size.width * 0.5, size.height * 0.80);
    canvas.rotate(-14 * math.pi / 180);
    void band(double dx, double w, Color c, double opacity) {
      final p = Paint()..color = c.withValues(alpha: opacity);
      canvas.drawRect(Rect.fromLTWH(dx, -size.height, w, size.height * 2), p);
    }

    band(-260, 210, olive, 0.55);
    band(-44, 26, gold, 0.85);
    band(-10, 12, paper, 0.45);
    band(14, 54, red, 0.9);
    band(76, 8, paper, 0.30);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Планета в дуотоне: светлый диск, вырезанная тень, кратеры, орбита.
class PlanetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.66, size.height * 0.33);
    final r = size.height * 0.27;

    final body = Paint()..color = const Color(0xFFDED7C4);
    canvas.drawCircle(c, r, body);

    final shadow = Paint()..color = const Color(0xFF16211F);
    canvas.drawCircle(c + Offset(-r * 0.42, -r * 0.08), r * 0.99, shadow);

    final crater = Paint()..color = const Color(0xFF8E8778).withValues(alpha: 0.35);
    final craters = <Offset>[
      Offset(0.30, -0.22),
      Offset(0.48, 0.10),
      Offset(0.22, 0.28),
      Offset(0.58, -0.30),
    ];
    for (final o in craters) {
      canvas.drawCircle(c + Offset(o.dx * r, o.dy * r), r * 0.075, crater);
    }

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = paper.withValues(alpha: 0.38);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 1.32),
      -2.75,
      2.1,
      false,
      orbitPaint,
    );

    final marker = Offset(
      c.dx + r * 1.32 * math.cos(-0.65),
      c.dy + r * 1.32 * math.sin(-0.65),
    );
    canvas.drawCircle(marker, 4.5, Paint()..color = red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HalftonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = paper.withValues(alpha: 0.05);
    const step = 9.0;
    for (double y = 14; y < size.height * 0.45; y += step) {
      for (double x = size.width * 0.55; x < size.width - 8; x += step) {
        final fade = 1 - (y / (size.height * 0.45));
        canvas.drawCircle(Offset(x, y), 1.3 * math.max(0.25, fade), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PerforationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = ink.withValues(alpha: 0.22)
      ..strokeWidth = 1.4;
    const dash = 6.0;
    const gap = 6.0;
    double y = 10;
    while (y < size.height - 10) {
      canvas.drawLine(Offset(12, y), Offset(12, y + dash), p);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
