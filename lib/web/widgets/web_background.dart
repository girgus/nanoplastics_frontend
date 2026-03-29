import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../web_state.dart';

class WebBackground extends StatefulWidget {
  const WebBackground({super.key, required this.domain});
  final WebDomain domain;

  @override
  State<WebBackground> createState() => _WebBackgroundState();
}

class _WebBackgroundState extends State<WebBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rng = math.Random(42);

  late final List<_BgStar> _stars;
  late final List<_CityDot> _cityDots;
  final List<_Meteor> _meteors = [];
  double _prevSeconds = 0;

  static const double _cycleSec = 60.0;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _cycleSec ~/ 1),
    )..repeat();

    _stars = List.generate(210, (_) => _BgStar(_rng));
    _cityDots = List.generate(88, (_) => _CityDot(_rng));

    _ctrl.addListener(_onTick);
  }

  void _onTick() {
    final t = _ctrl.value * _cycleSec;
    double dt = t - _prevSeconds;
    if (dt < 0) dt += _cycleSec;
    _prevSeconds = t;

    for (final m in _meteors) {
      m.elapsed += dt;
    }
    _meteors.removeWhere((m) => m.elapsed >= m.lifetime);

    final isHuman = widget.domain == WebDomain.human;
    final maxM = isHuman ? 9 : 6;
    final rate = isHuman ? 0.55 : 0.35;
    if (_meteors.length < maxM && _rng.nextDouble() < dt * rate) {
      _meteors.add(_Meteor(_rng));
    }
    if (_meteors.length < maxM - 1 &&
        _rng.nextDouble() < dt * (isHuman ? 0.16 : 0.08)) {
      _meteors.add(_Meteor(_rng));
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTick);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _BackgroundPainter(
          t: _ctrl.value,
          stars: _stars,
          meteors: _meteors,
          cityDots: _cityDots,
          domain: widget.domain,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BgStar {
  final double x;
  final double y;
  final double radius;
  final double twinkleSpeed;
  final double twinklePhase;
  final double baseOpacity;

  _BgStar(math.Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble() * 0.83,
        radius = 0.3 + rng.nextDouble() * 1.7,
        twinkleSpeed = 0.3 + rng.nextDouble() * 2.0,
        twinklePhase = rng.nextDouble() * math.pi * 2,
        baseOpacity = 0.40 + rng.nextDouble() * 0.60;
}

class _Meteor {
  final double startX;
  final double startY;
  final double angle;
  final double speed;
  final double trailLength;
  final double maxOpacity;
  final double lifetime;
  double elapsed = 0;

  _Meteor(math.Random rng)
      : startX = 0.05 + rng.nextDouble() * 0.80,
        startY = 0.01 + rng.nextDouble() * 0.50,
        angle = (22 + rng.nextDouble() * 32) * math.pi / 180,
        speed = 0.10 + rng.nextDouble() * 0.24,
        trailLength = 0.05 + rng.nextDouble() * 0.15,
        maxOpacity = 0.55 + rng.nextDouble() * 0.45,
        lifetime = 1.6 + rng.nextDouble() * 2.8;
}

class _CityDot {
  final double relX;
  final double arcFraction;
  final double size;
  final Color color;
  final double flickerSpeed;
  final double flickerPhase;

  static const _c1 = Color(0xFFFF9030);
  static const _c2 = Color(0xFFFFE566);
  static const _c3 = Color(0xFFFFF5E0);

  _CityDot(math.Random rng)
      : relX = rng.nextDouble(),
        arcFraction = rng.nextDouble(),
        size = 0.8 + rng.nextDouble() * 2.8,
        color = [_c1, _c2, _c3][rng.nextInt(3)],
        flickerSpeed = 0.25 + rng.nextDouble() * 1.1,
        flickerPhase = rng.nextDouble() * math.pi * 2;
}

class _BackgroundPainter extends CustomPainter {
  final double t;
  final List<_BgStar> stars;
  final List<_Meteor> meteors;
  final List<_CityDot> cityDots;
  final WebDomain domain;

  const _BackgroundPainter({
    required this.t,
    required this.stars,
    required this.meteors,
    required this.cityDots,
    required this.domain,
  });

  static const _cycleSec = 60.0;
  double get _sec => t * _cycleSec;
  bool get _isHuman => domain == WebDomain.human;

  @override
  bool shouldRepaint(_BackgroundPainter old) =>
      old.t != t || old.domain != domain;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    _paintNebula(canvas, size);
    _paintStars(canvas, size);
    _paintMeteors(canvas, size);
    if (_isHuman) {
      _paintOrganicArc(canvas, size);
    } else {
      _paintEarth(canvas, size);
    }
    _paintAtmosphere(canvas, size);
  }

  void _paintBackground(Canvas canvas, Size size) {
    final colors = _isHuman
        ? const [
            Color(0xFF0C0A02),
            Color(0xFF130F03),
            Color(0xFF1A1405),
            Color(0xFF201807)
          ]
        : const [
            Color(0xFF020810),
            Color(0xFF030E1E),
            Color(0xFF04142C),
            Color(0xFF06193A)
          ];
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: const [0.0, 0.35, 0.70, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  void _paintNebula(Canvas canvas, Size size) {
    final blobs = _isHuman
        ? const [
            (rx: 0.22, ry: 0.14, rr: 0.40, hue: Color(0xFF4A3200), a: 0.11),
            (rx: 0.75, ry: 0.28, rr: 0.34, hue: Color(0xFF3A2500), a: 0.09),
            (rx: 0.50, ry: 0.56, rr: 0.30, hue: Color(0xFF5A3D00), a: 0.08),
          ]
        : const [
            (rx: 0.22, ry: 0.14, rr: 0.40, hue: Color(0xFF0B2D65), a: 0.10),
            (rx: 0.75, ry: 0.28, rr: 0.34, hue: Color(0xFF0E1F52), a: 0.08),
            (rx: 0.50, ry: 0.56, rr: 0.30, hue: Color(0xFF091D48), a: 0.07),
          ];
    const breathRate = 0.09;
    for (final b in blobs) {
      final cx = b.rx * size.width;
      final cy = b.ry * size.height;
      final r = b.rr * size.width;
      final breath = 0.88 + 0.12 * math.sin(_sec * breathRate + b.rx * 4);
      canvas.drawCircle(
        Offset(cx, cy),
        r * breath,
        Paint()
          ..color = b.hue.withValues(alpha: b.a)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.65),
      );
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    for (final s in stars) {
      final twinkle = 0.5 +
          0.5 * math.sin(_sec * s.twinkleSpeed * math.pi * 2 + s.twinklePhase);
      final opacity = s.baseOpacity * (0.35 + 0.65 * twinkle);
      final r = s.radius * (0.88 + 0.12 * twinkle);
      final x = s.x * size.width;
      final y = s.y * size.height;

      if (s.radius > 1.15) {
        final haloColor =
            _isHuman ? const Color(0xFFFFD080) : const Color(0xFFB0D0FF);
        canvas.drawCircle(
          Offset(x, y),
          r * 2.8,
          Paint()
            ..color = haloColor.withValues(alpha: opacity * 0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
        );
      }
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
    }
  }

  void _paintMeteors(Canvas canvas, Size size) {
    for (final m in meteors) {
      if (m.elapsed <= 0) continue;
      final progress = (m.elapsed / m.lifetime).clamp(0.0, 1.0);
      final opacity =
          progress < 0.15 ? progress / 0.15 : 1.0 - (progress - 0.15) / 0.85;

      final dist = m.elapsed * m.speed;
      final cosA = math.cos(m.angle);
      final sinA = math.sin(m.angle);
      final headX = (m.startX + dist * cosA) * size.width;
      final headY = (m.startY + dist * sinA) * size.height;
      final trailPx = m.trailLength * size.width;
      final tailX = headX - trailPx * cosA;
      final tailY = headY - trailPx * sinA;

      if (headX < -trailPx || headX > size.width + trailPx) continue;
      if (headY < -trailPx || headY > size.height + trailPx) continue;

      final alpha = (opacity * m.maxOpacity).clamp(0.0, 1.0);

      final streakColor = _isHuman ? const Color(0xFFFFB060) : Colors.white;
      canvas.drawLine(
        Offset(tailX, tailY),
        Offset(headX, headY),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4 + m.trailLength * 3.5
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(
            Offset(tailX, tailY),
            Offset(headX, headY),
            [
              Colors.transparent,
              streakColor.withValues(alpha: alpha * 0.22),
              streakColor.withValues(alpha: alpha),
            ],
            [0.0, 0.55, 1.0],
          ),
      );

      canvas.drawCircle(
        Offset(headX, headY),
        1.6,
        Paint()
          ..color = streakColor.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
    }
  }

  void _paintEarth(Canvas canvas, Size size) {
    final r = size.width * 1.10;
    final cx = size.width / 2;
    final cy = size.height + r * 0.695;
    final centre = Offset(cx, cy);
    final earthRect = Rect.fromCircle(center: centre, radius: r);

    canvas.save();
    canvas.clipPath(Path()..addOval(earthRect));

    canvas.drawPaint(Paint()..color = const Color(0xFF010A16));

    canvas.drawCircle(
      Offset(cx * 0.65, cy - r * 0.78),
      r * 0.28,
      Paint()
        ..color = const Color(0xFF041424).withValues(alpha: 0.9)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
    );
    canvas.drawCircle(
      Offset(cx * 1.35, cy - r * 0.74),
      r * 0.22,
      Paint()
        ..color = const Color(0xFF041424).withValues(alpha: 0.85)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.10),
    );

    final scrollX = (_sec / _cycleSec) * r * 0.80;
    final beltW = r * 1.90;

    for (final dot in cityDots) {
      final rawX = dot.relX * beltW;
      final dotX = cx - r * 0.95 + ((rawX - scrollX) % beltW);
      final arcDist = (0.695 + dot.arcFraction * 0.245) * r;
      final dotY = cy - arcDist;

      if (dotX < -8 || dotX > size.width + 8) continue;
      if (dotY < -8 || dotY > size.height + 8) continue;
      final dx = dotX - cx;
      final dy = dotY - cy;
      if (dx * dx + dy * dy > r * r * 0.998) continue;

      final flicker = 0.55 +
          0.45 *
              math.sin(
                  _sec * dot.flickerSpeed * math.pi * 2 + dot.flickerPhase);

      canvas.drawCircle(
        Offset(dotX, dotY),
        dot.size * 2.0,
        Paint()
          ..color = dot.color.withValues(alpha: 0.16 * flicker)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, dot.size * 1.8),
      );
      canvas.drawCircle(
        Offset(dotX, dotY),
        dot.size * 0.48,
        Paint()..color = dot.color.withValues(alpha: 0.80 * flicker),
      );
    }

    canvas.restore();
  }

  void _paintOrganicArc(Canvas canvas, Size size) {
    final r = size.width * 1.10;
    final cx = size.width / 2;
    final cy = size.height + r * 0.695;
    final centre = Offset(cx, cy);
    final earthRect = Rect.fromCircle(center: centre, radius: r);

    canvas.save();
    canvas.clipPath(Path()..addOval(earthRect));

    canvas.drawPaint(Paint()..color = const Color(0xFF0A0800));

    canvas.drawCircle(
      Offset(cx, cy - r * 0.82),
      r * 0.50,
      Paint()
        ..color = const Color(0xFF3A2800).withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.22),
    );

    const bioColors = [
      Color(0xFFFFCC00),
      Color(0xFFFFAA20),
      Color(0xFFFFE080),
      Color(0xFFFFF5C0),
    ];
    final scrollX = (_sec / _cycleSec) * r * 0.30;
    final beltW = r * 1.90;

    for (final dot in cityDots) {
      final rawX = dot.relX * beltW;
      final dotX = cx - r * 0.95 + ((rawX - scrollX) % beltW);
      final arcDist = (0.695 + dot.arcFraction * 0.245) * r;
      final dotY = cy - arcDist;

      if (dotX < -8 || dotX > size.width + 8) continue;
      if (dotY < -8 || dotY > size.height + 8) continue;
      final dx = dotX - cx;
      final dy = dotY - cy;
      if (dx * dx + dy * dy > r * r * 0.998) continue;

      final sway = 0.70 +
          0.30 * math.sin(_sec * dot.flickerSpeed * 0.25 + dot.flickerPhase);
      final colorIndex =
          (dot.relX * bioColors.length).floor().clamp(0, bioColors.length - 1);
      final bioColor = bioColors[colorIndex];

      canvas.drawCircle(
        Offset(dotX, dotY),
        dot.size * 2.2,
        Paint()
          ..color = bioColor.withValues(alpha: 0.16 * sway)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, dot.size * 2.0),
      );
      canvas.drawCircle(
        Offset(dotX, dotY),
        dot.size * 0.48,
        Paint()..color = bioColor.withValues(alpha: 0.75 * sway),
      );
    }

    canvas.restore();

    canvas.drawCircle(
      centre,
      r * 1.018,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF8A6000).withValues(alpha: 0.0),
            const Color(0xFFB88000).withValues(alpha: 0.12),
            const Color(0xFFFFCC30).withValues(alpha: 0.28),
            const Color(0xFFFFE080).withValues(alpha: 0.10),
            Colors.transparent,
          ],
          stops: const [0.0, 0.88, 0.93, 0.970, 0.988, 1.0],
        ).createShader(
          Rect.fromCircle(center: centre, radius: r * 1.018),
        ),
    );

    canvas.drawCircle(
      centre,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = const Color(0xFFCC9920).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
    );
  }

  void _paintAtmosphere(Canvas canvas, Size size) {
    final r = size.width * 1.10;
    final cx = size.width / 2;
    final cy = size.height + r * 0.695;
    final centre = Offset(cx, cy);

    if (_isHuman) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              const Color(0xFF120E00).withValues(alpha: 0.65),
              Colors.transparent,
            ],
            stops: const [0.0, 0.30],
          ).createShader(Offset.zero & size),
      );
      return;
    }

    canvas.drawCircle(
      centre,
      r * 1.022,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF1A5CB8).withValues(alpha: 0.0),
            const Color(0xFF2B80F0).withValues(alpha: 0.16),
            const Color(0xFF60AAFF).withValues(alpha: 0.30),
            const Color(0xFF90CCFF).withValues(alpha: 0.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.91, 0.95, 0.975, 0.990, 1.0],
        ).createShader(
          Rect.fromCircle(center: centre, radius: r * 1.022),
        ),
    );

    canvas.drawCircle(
      centre,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = const Color(0xFF4499DD).withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5),
    );

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFF050F22).withValues(alpha: 0.60),
            Colors.transparent,
          ],
          stops: const [0.0, 0.30],
        ).createShader(Offset.zero & size),
    );
  }
}
