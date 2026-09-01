import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import 'coin.dart';
import 'obstacle.dart';
import 'runner_game.dart';

class Player extends PositionComponent
    with CollisionCallbacks, HasGameReference<RunnerGame> {
  Player()
    : super(
        position: Vector2(120, RunnerGame.groundTop),
        size: Vector2(52, 62),
        anchor: Anchor.bottomLeft,
        priority: 10,
      );

  static const double _gravity = 2900;
  static const double _fallGravityBoost = 1.18;
  static const double _jumpVelocity = -940;
  static const int _maxJumps = 2;

  double _vy = 0;
  int _jumpsUsed = 0;
  double _runTime = 0;
  double _dustTimer = 0;

  bool get _onGround => y >= RunnerGame.groundTop - 0.5;

  @override
  Future<void> onLoad() async {
    // Slightly smaller than the visible body so near-misses feel fair.
    add(RectangleHitbox(position: Vector2(7, 8), size: Vector2(38, 50)));
  }

  void reset() {
    position = Vector2(120, RunnerGame.groundTop);
    _vy = 0;
    _jumpsUsed = 0;
  }

  void jump() {
    if (_jumpsUsed >= _maxJumps) return;
    _vy = _jumpVelocity * (_jumpsUsed == 0 ? 1 : 0.88);
    _jumpsUsed++;
    game.audio.jump(_jumpsUsed);
  }

  /// Releasing the tap early cuts the jump short for variable jump height.
  void endJump() {
    if (_vy < -320) _vy = -320;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state == GameState.gameOver) return;
    _vy += _gravity * (_vy > 0 ? _fallGravityBoost : 1) * dt;
    y += _vy * dt;
    if (y >= RunnerGame.groundTop) {
      y = RunnerGame.groundTop;
      _vy = 0;
      _jumpsUsed = 0;
    }
    _runTime += dt * math.max(1, game.scrollSpeed / 300);

    // Kick up dust while running on the ground.
    if (game.isPlaying && _onGround) {
      _dustTimer -= dt;
      if (_dustTimer <= 0) {
        game.world.add(
          DustPuff(start: Vector2(x + 8, RunnerGame.groundTop - 4)),
        );
        _dustTimer = 0.13;
      }
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (!game.isPlaying) return;
    if (other is Obstacle) game.onPlayerDeath();
    if (other is Coin) other.collect();
  }

  @override
  void render(Canvas canvas) {
    final onGround = _onGround;
    final tilt = onGround ? 0.0 : (_vy / 3200).clamp(-0.28, 0.32).toDouble();

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(tilt);
    canvas.translate(-size.x / 2, -size.y / 2);

    final bodyPaint = Paint()..color = const Color(0xFFFF7043);
    final darkPaint = Paint()..color = const Color(0xFFBF360C);

    // Ninja headband ribbons trailing behind the head.
    final flap = math.sin(_runTime * 15) * 5;
    final ribbonPaint = Paint()..color = const Color(0xFFD32F2F);
    final ribbonA = Path()
      ..moveTo(8, 9)
      ..lineTo(-14.0 - flap.abs(), 4 + flap)
      ..lineTo(-10.0 - flap.abs(), 9 + flap)
      ..lineTo(8, 14)
      ..close();
    final ribbonB = Path()
      ..moveTo(8, 11)
      ..lineTo(-12.0 + flap, 16 - flap)
      ..lineTo(-8.0 + flap, 20 - flap)
      ..lineTo(8, 16)
      ..close();
    canvas.drawPath(ribbonA, ribbonPaint);
    canvas.drawPath(ribbonB, ribbonPaint);

    // Legs: alternate while running, tucked while airborne.
    final phase = onGround ? math.sin(_runTime * 20) : 0.6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(12, 44, 12, 18 - 5 * phase),
        const Radius.circular(5),
      ),
      darkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(29, 44, 12, 18 + 5 * phase),
        const Radius.circular(5),
      ),
      darkPaint,
    );

    // Body.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(3, 2, 47, 46),
        const Radius.circular(15),
      ),
      bodyPaint,
    );
    // Belly highlight.
    canvas.drawOval(
      const Rect.fromLTWH(12, 22, 26, 22),
      Paint()..color = const Color(0xFFFFAB91),
    );
    // Headband across the forehead.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(3, 7, 47, 8),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFD32F2F),
    );
    // Eye, looking ahead.
    canvas.drawCircle(
      const Offset(37, 18),
      9,
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawCircle(
      const Offset(40, 18),
      4,
      Paint()..color = const Color(0xFF263238),
    );

    canvas.restore();
  }
}

/// A small fading puff of dust kicked up behind the runner's feet.
class DustPuff extends PositionComponent with HasGameReference<RunnerGame> {
  DustPuff({required Vector2 start})
    : super(position: start, anchor: Anchor.center, priority: 8);

  static const double _lifespan = 0.4;
  double _life = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;
    x -= game.scrollSpeed * dt;
    y -= 14 * dt;
    if (_life >= _lifespan) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = _life / _lifespan;
    canvas.drawCircle(
      Offset.zero,
      3 + 7 * t,
      Paint()..color = const Color(0xFFEFEBE9).withValues(alpha: 0.5 * (1 - t)),
    );
  }
}
