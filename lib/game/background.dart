import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import 'runner_game.dart';

class Sky extends PositionComponent with HasGameReference<RunnerGame> {
  Sky()
    : super(
        size: Vector2(RunnerGame.worldWidth, RunnerGame.worldHeight),
        priority: -30,
      );

  @override
  void render(Canvas canvas) {
    final theme = game.skyTheme;
    final night = theme.night;
    final rect = size.toRect();
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.top, theme.bottom],
        ).createShader(rect),
    );

    // Sun fades out as night falls.
    if (night < 0.95) {
      final sunAlpha = (1 - night).clamp(0.0, 1.0);
      canvas.drawCircle(
        const Offset(830, 92),
        46,
        Paint()..color = const Color(0xFFFFF59D).withValues(alpha: sunAlpha),
      );
      canvas.drawCircle(
        const Offset(830, 92),
        34,
        Paint()..color = const Color(0xFFFFEE58).withValues(alpha: sunAlpha),
      );
    }

    // Stars and moon fade in with the night.
    if (night > 0.05) {
      final starPaint = Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.9 * night);
      for (var i = 0; i < 28; i++) {
        final sx = (i * 137.53) % RunnerGame.worldWidth;
        final sy = 12 + (i * 89.7) % 230;
        canvas.drawCircle(Offset(sx, sy), 1.0 + (i % 3) * 0.7, starPaint);
      }
      canvas.drawCircle(
        const Offset(150, 100),
        30,
        Paint()..color = const Color(0xFFF5F3CE).withValues(alpha: night),
      );
      canvas.drawCircle(
        const Offset(162, 92),
        24,
        Paint()..color = theme.top.withValues(alpha: night),
      );
    }
  }
}

/// A parallax hill silhouette built from overlapping sine waves.
class HillLayer extends PositionComponent with HasGameReference<RunnerGame> {
  HillLayer({
    required Color color,
    required this.factor,
    required this.baseHeight,
    required this.amplitude,
    required super.priority,
  }) : _baseColor = color,
       super(size: Vector2(RunnerGame.worldWidth, RunnerGame.worldHeight));

  final double factor;
  final double baseHeight;
  final double amplitude;
  final Color _baseColor;
  final Paint _paint = Paint();

  double _offset = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _offset += game.scrollSpeed * factor * dt;
  }

  @override
  void render(Canvas canvas) {
    _paint.color = Color.lerp(
      _baseColor,
      const Color(0xFF1B2A4A),
      game.nightness * 0.7,
    )!;
    final path = Path()..moveTo(0, RunnerGame.worldHeight);
    for (double x = 0; x <= size.x + 16; x += 16) {
      final t = x + _offset;
      final y =
          RunnerGame.groundTop -
          baseHeight +
          math.sin(t * 0.0042) * amplitude +
          math.sin(t * 0.0117 + 1.7) * amplitude * 0.35;
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.x, RunnerGame.worldHeight)
      ..close();
    canvas.drawPath(path, _paint);
  }
}

class CloudSpawner extends Component with HasGameReference<RunnerGame> {
  final math.Random _rng = math.Random();
  double _untilNext = 2;

  @override
  Future<void> onLoad() async {
    for (var i = 0; i < 3; i++) {
      parent?.add(
        Cloud(
          start: Vector2(
            _rng.nextDouble() * RunnerGame.worldWidth,
            30 + _rng.nextDouble() * 160,
          ),
          sizeFactor: 0.7 + _rng.nextDouble() * 0.6,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _untilNext -= dt;
    if (_untilNext <= 0) {
      parent?.add(
        Cloud(
          start: Vector2(
            RunnerGame.worldWidth + 120,
            30 + _rng.nextDouble() * 160,
          ),
          sizeFactor: 0.7 + _rng.nextDouble() * 0.6,
        ),
      );
      _untilNext = 2.5 + _rng.nextDouble() * 3;
    }
  }
}

class Cloud extends PositionComponent with HasGameReference<RunnerGame> {
  Cloud({required Vector2 start, required double sizeFactor})
    : super(
        position: start,
        size: Vector2(96, 44) * sizeFactor,
        scale: Vector2.all(sizeFactor),
        priority: -25,
      );

  static final Paint _paint = Paint()..color = const Color(0xE6FFFFFF);

  @override
  void update(double dt) {
    super.update(dt);
    x -= (game.scrollSpeed * 0.35 + 12) * dt;
    if (x < -160) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(const Offset(22, 28), 16, _paint);
    canvas.drawCircle(const Offset(48, 20), 21, _paint);
    canvas.drawCircle(const Offset(74, 28), 15, _paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 24, 76, 18),
        const Radius.circular(9),
      ),
      _paint,
    );
  }
}
