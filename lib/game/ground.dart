import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import 'runner_game.dart';

class Ground extends PositionComponent with HasGameReference<RunnerGame> {
  Ground()
    : super(
        position: Vector2(0, RunnerGame.groundTop),
        size: Vector2(RunnerGame.worldWidth, RunnerGame.groundHeight),
        priority: -5,
      );

  static const double _patternWidth = 96;

  double _offset = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _offset = (_offset + game.scrollSpeed * dt) % _patternWidth;
  }

  /// Darkens a base colour as night falls.
  Color _shade(Color base) =>
      Color.lerp(base, const Color(0xFF141E33), game.nightness * 0.6)!;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()..color = _shade(const Color(0xFF795548)),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, 16),
      Paint()..color = _shade(const Color(0xFF66BB6A)),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 14, size.x, 4),
      Paint()..color = _shade(const Color(0xFF43A047)),
    );

    // Scrolling dirt streaks and pebbles sell the ground speed.
    final streakPaint = Paint()..color = _shade(const Color(0xFF5D4037));
    for (
      double x = -_patternWidth;
      x < size.x + _patternWidth;
      x += _patternWidth
    ) {
      final dx = x - _offset;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(dx, 38, 30, 7),
          const Radius.circular(4),
        ),
        streakPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(dx + 52, 62, 14, 6),
          const Radius.circular(3),
        ),
        streakPaint,
      );
    }
  }
}
