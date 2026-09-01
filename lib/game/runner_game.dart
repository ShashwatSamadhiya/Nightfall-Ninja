import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show AppLifecycleState;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_manager.dart';
import 'background.dart';
import 'coin.dart';
import 'ground.dart';
import 'obstacle.dart';
import 'player.dart';

enum GameState { menu, playing, gameOver }

class RunnerGame extends FlameGame with HasCollisionDetection {
  RunnerGame()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: worldWidth,
          height: worldHeight,
        ),
      );

  static const String overlayMainMenu = 'main_menu';
  static const String overlayHud = 'hud';
  static const String overlayGameOver = 'game_over';
  static const String overlayPause = 'pause';

  static const double worldWidth = 960;
  static const double worldHeight = 540;
  static const double groundHeight = 88;
  static const double groundTop = worldHeight - groundHeight;

  static const double _startSpeed = 320;
  static const double _maxSpeed = 880;
  static const double _acceleration = 9;
  static const double _idleScrollSpeed = 130;

  // Obstacle variety unlocks progressively so early runs stay gentle.
  static const double _groupUnlockSpeed = 400;
  static const double _birdUnlockSpeed = 480;
  static const double _highBirdUnlockSpeed = 530;

  /// World-pixels for one full day -> sunset -> night -> day cycle.
  static const double _cyclePixels = 22000;

  final math.Random rng = math.Random();
  final AudioManager audio = AudioManager();
  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> coins = ValueNotifier<int>(0);
  int highScore = 0;
  int totalCoins = 0;
  bool newBest = false;

  GameState state = GameState.menu;
  double speed = _startSpeed;
  double _distance = 0;
  double _untilNextSpawn = 1.4;
  double _sinceGameOver = 0;

  late final Player player;

  bool get isPlaying => state == GameState.playing;

  /// How fast the world scrolls: full speed in a run, a gentle drift on the
  /// menu so the scene feels alive, and frozen on the game-over screen.
  double get scrollSpeed => switch (state) {
    GameState.menu => _idleScrollSpeed,
    GameState.playing => speed,
    GameState.gameOver => 0,
  };

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    player = Player();
    world.addAll([
      Sky(),
      CloudSpawner(),
      HillLayer(
        color: const Color(0xFFA5D6A7),
        factor: 0.15,
        baseHeight: 132,
        amplitude: 46,
        priority: -20,
      ),
      HillLayer(
        color: const Color(0xFF81C784),
        factor: 0.3,
        baseHeight: 68,
        amplitude: 32,
        priority: -19,
      ),
      Ground(),
      player,
    ]);
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('high_score') ?? 0;
    totalCoins = prefs.getInt('total_coins') ?? 0;
    // Load audio in the background so startup never blocks on it.
    unawaited(audio.init());
    overlays.add(overlayMainMenu);
  }

  void startGame() {
    if (isPlaying) return;
    _clearField();
    player.reset();
    speed = _startSpeed;
    _distance = 0;
    _untilNextSpawn = 1.9;
    score.value = 0;
    coins.value = 0;
    newBest = false;
    state = GameState.playing;
    overlays.remove(overlayMainMenu);
    overlays.remove(overlayGameOver);
    overlays.add(overlayHud);
    audio.startMusic();
  }

  void onPlayerDeath() {
    if (!isPlaying) return;
    state = GameState.gameOver;
    _sinceGameOver = 0;
    audio.stopMusic();
    audio.hit();
    if (coins.value > 0) {
      totalCoins += coins.value;
      SharedPreferences.getInstance().then(
        (prefs) => prefs.setInt('total_coins', totalCoins),
      );
    }
    if (score.value > highScore) {
      highScore = score.value;
      newBest = true;
      SharedPreferences.getInstance().then(
        (prefs) => prefs.setInt('high_score', highScore),
      );
    }
    overlays.remove(overlayHud);
    overlays.add(overlayGameOver);
  }

  void collectCoin() {
    coins.value++;
    audio.coin();
  }

  void pauseGame() {
    if (!isPlaying || paused) return;
    pauseEngine();
    audio.pauseMusic();
    overlays.add(overlayPause);
  }

  void resumeGame() {
    if (!paused) return;
    overlays.remove(overlayPause);
    resumeEngine();
    audio.resumeMusic();
  }

  void quitToMenu() {
    overlays.remove(overlayPause);
    overlays.remove(overlayHud);
    resumeEngine();
    audio.stopMusic();
    _clearField();
    player.reset();
    _distance = 0;
    state = GameState.menu;
    overlays.add(overlayMainMenu);
  }

  void _clearField() {
    world.children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
    world.children.whereType<Coin>().forEach((c) => c.removeFromParent());
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    if (state != AppLifecycleState.resumed) pauseGame();
  }

  void handleTapDown() {
    if (paused) return;
    switch (state) {
      case GameState.menu:
        startGame();
      case GameState.playing:
        player.jump();
      case GameState.gameOver:
        // Small delay so a frantic last-second tap can't instantly restart.
        if (_sinceGameOver > 0.6) startGame();
    }
  }

  void handleTapUp() {
    if (isPlaying) player.endJump();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (state == GameState.gameOver) {
      _sinceGameOver += dt;
      return;
    }
    if (!isPlaying) return;
    speed = math.min(_maxSpeed, speed + _acceleration * dt);
    _distance += speed * dt;
    // Coins are worth 5 score each on top of distance.
    final newScore = _distance ~/ 15 + coins.value * 5;
    if (newScore ~/ 100 > score.value ~/ 100) audio.point();
    score.value = newScore;
    _untilNextSpawn -= dt;
    if (_untilNextSpawn <= 0) _spawnObstacle();
  }

  void _spawnObstacle() {
    final roll = rng.nextDouble();
    final ObstacleKind kind;
    if (speed > _birdUnlockSpeed && roll < 0.16) {
      kind = ObstacleKind.birdLow;
    } else if (speed > _highBirdUnlockSpeed && roll < 0.3) {
      kind = ObstacleKind.birdHigh;
    } else if (speed > _groupUnlockSpeed && roll > 0.84) {
      kind = ObstacleKind.cactusGroup;
    } else if (roll < 0.62) {
      kind = ObstacleKind.cactusSmall;
    } else {
      kind = ObstacleKind.cactusTall;
    }
    world.add(Obstacle(kind));
    // Spawn gaps shrink as the run speeds up, but never below a jumpable gap.
    final tightness = math.max(0.62, 1.0 - (speed - _startSpeed) / 1100);
    _untilNextSpawn = (0.9 + rng.nextDouble() * 0.7) * tightness;
    if (rng.nextDouble() < 0.55) _spawnCoinRow();
  }

  /// Drops a short row (or arc) of coins roughly centred in the gap before
  /// the next obstacle spawns.
  void _spawnCoinRow() {
    final gapDistance = _untilNextSpawn * speed;
    if (gapDistance < 260) return;
    final count = 3 + rng.nextInt(3);
    const spacing = 44.0;
    final startX =
        worldWidth + 80 + gapDistance * 0.5 - (count - 1) * spacing / 2;
    final high = rng.nextBool();
    final baseY = groundTop - (high ? 130 : 46);
    for (var i = 0; i < count; i++) {
      // High rows arc so a well-timed jump sweeps them all.
      final arc = high ? -math.sin(i / (count - 1) * math.pi) * 26 : 0.0;
      world.add(Coin(position: Vector2(startX + i * spacing, baseY + arc)));
    }
  }

  /// Sky palette keyframes over one cycle: day, sunset, night, back to day.
  /// Fields: (t, sky top, sky bottom, nightness).
  static const List<(double, Color, Color, double)> _skyKeys = [
    (0.0, Color(0xFF4FC3F7), Color(0xFFE1F5FE), 0.0),
    (0.42, Color(0xFF4FC3F7), Color(0xFFE1F5FE), 0.0),
    (0.56, Color(0xFF5C6BC0), Color(0xFFFFB74D), 0.35),
    (0.68, Color(0xFF0F1D3D), Color(0xFF2B3C68), 1.0),
    (0.88, Color(0xFF0F1D3D), Color(0xFF2B3C68), 1.0),
    (1.0, Color(0xFF4FC3F7), Color(0xFFE1F5FE), 0.0),
  ];

  double get _cycleT => (_distance % _cyclePixels) / _cyclePixels;

  ({Color top, Color bottom, double night}) get skyTheme {
    final t = _cycleT;
    for (var i = 0; i < _skyKeys.length - 1; i++) {
      final a = _skyKeys[i];
      final b = _skyKeys[i + 1];
      if (t <= b.$1) {
        final f = (t - a.$1) / (b.$1 - a.$1);
        return (
          top: Color.lerp(a.$2, b.$2, f)!,
          bottom: Color.lerp(a.$3, b.$3, f)!,
          night: a.$4 + (b.$4 - a.$4) * f,
        );
      }
    }
    return (top: _skyKeys.first.$2, bottom: _skyKeys.first.$3, night: 0);
  }

  /// 0 in daylight, 1 at full night — used to shade hills and ground.
  double get nightness => skyTheme.night;
}
