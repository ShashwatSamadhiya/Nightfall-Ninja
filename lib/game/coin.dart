import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import 'runner_game.dart';

class Coin extends PositionComponent with HasGameReference<RunnerGame> {
  Coin({required Vector2 position})
    : super(
        position: position,
        size: Vector2.all(30),
        anchor: Anchor.center,
        priority: 4,
      );

  double _spin = 0;
  bool _collected = false;

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(radius: 13, position: Vector2.all(2)));
  }

  void collect() {
    if (_collected) return;
    _collected = true;
    game.collectCoin();
    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) return;
    _spin += dt;
    x -= game.speed * dt;
    if (x < -60) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    // Spin by squashing horizontally.
    final squash = math.cos(_spin * 6).abs().clamp(0.25, 1.0);
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(squash, 1);

    canvas.drawCircle(
      Offset.zero,
      15,
      Paint()..color = const Color(0xFFF9A825),
    );
    canvas.drawCircle(
      Offset.zero,
      11,
      Paint()..color = const Color(0xFFFDD835),
    );
    canvas.drawCircle(
      const Offset(-4, -5),
      3.5,
      Paint()..color = const Color(0xFFFFF9C4),
    );
    canvas.restore();
  }
}
