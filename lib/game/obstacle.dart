import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import 'runner_game.dart';

enum ObstacleKind { cactusSmall, cactusTall, cactusGroup, birdLow, birdHigh }

class Obstacle extends PositionComponent with HasGameReference<RunnerGame> {
  Obstacle(this.kind) : super(anchor: Anchor.bottomLeft, priority: 5);

  final ObstacleKind kind;

  bool get isBird =>
      kind == ObstacleKind.birdLow || kind == ObstacleKind.birdHigh;

  double _life = 0;
  late final double _baseBottom;

  @override
  Future<void> onLoad() async {
    size = switch (kind) {
      ObstacleKind.cactusSmall => Vector2(40, 58),
      ObstacleKind.cactusTall => Vector2(42, 86),
      ObstacleKind.cactusGroup => Vector2(104, 58),
      ObstacleKind.birdLow || ObstacleKind.birdHigh => Vector2(56, 40),
    };
    _baseBottom = switch (kind) {
      // Low birds must be jumped over; high birds must be run under.
      ObstacleKind.birdLow => RunnerGame.groundTop - 34,
      ObstacleKind.birdHigh => RunnerGame.groundTop - 128,
      _ => RunnerGame.groundTop,
    };
    position = Vector2(RunnerGame.worldWidth + 80, _baseBottom);
    add(RectangleHitbox(position: Vector2(5, 5), size: size - Vector2(10, 10)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) return;
    x -= (game.speed + (isBird ? 70 : 0)) * dt;
    if (isBird) {
      _life += dt;
      y = _baseBottom + math.sin(_life * 7) * 5;
    }
    if (x < -size.x - 40) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    if (isBird) {
      _renderBird(canvas);
      return;
    }
    switch (kind) {
      case ObstacleKind.cactusSmall:
        _renderCactus(canvas, const Rect.fromLTWH(2, 0, 36, 58));
      case ObstacleKind.cactusTall:
        _renderCactus(canvas, const Rect.fromLTWH(3, 0, 36, 86), arms: true);
      case ObstacleKind.cactusGroup:
        _renderCactus(canvas, const Rect.fromLTWH(0, 10, 32, 48));
        _renderCactus(canvas, const Rect.fromLTWH(36, 0, 32, 58));
        _renderCactus(canvas, const Rect.fromLTWH(72, 10, 32, 48));
      default:
        break;
    }
  }

  void _renderCactus(Canvas canvas, Rect body, {bool arms = false}) {
    final paint = Paint()..color = const Color(0xFF2E7D32);
    final lightPaint = Paint()..color = const Color(0xFF43A047);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(10)),
      paint,
    );
    if (arms) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(body.left - 3, body.top + 20, 14, 26),
          const Radius.circular(7),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(body.right - 11, body.top + 32, 14, 26),
          const Radius.circular(7),
        ),
        paint,
      );
    }
    // Vertical ridge highlight.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(body.center.dx - 3, body.top + 8, 6, body.height - 16),
        const Radius.circular(3),
      ),
      lightPaint,
    );
  }

  void _renderBird(Canvas canvas) {
    final bodyPaint = Paint()..color = const Color(0xFF5E35B1);
    // Body, facing left (direction of travel).
    canvas.drawOval(const Rect.fromLTWH(6, 10, 44, 24), bodyPaint);
    // Beak.
    final beak = Path()
      ..moveTo(8, 16)
      ..lineTo(-4, 22)
      ..lineTo(8, 27)
      ..close();
    canvas.drawPath(beak, Paint()..color = const Color(0xFFFFB300));
    // Eye.
    canvas.drawCircle(
      const Offset(15, 18),
      4.5,
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawCircle(
      const Offset(14, 18),
      2,
      Paint()..color = const Color(0xFF263238),
    );
    // Flapping wing.
    canvas.save();
    canvas.translate(30, 18);
    canvas.rotate(math.sin(_life * 16) * 0.7);
    final wing = Path()
      ..moveTo(-4, 0)
      ..lineTo(14, -16)
      ..lineTo(12, 2)
      ..close();
    canvas.drawPath(wing, Paint()..color = const Color(0xFF7E57C2));
    canvas.restore();
  }
}
