import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'config/app_env.dart';
import 'game/runner_game.dart';
import 'overlays/game_over_overlay.dart';
import 'overlays/hud_overlay.dart';
import 'overlays/main_menu_overlay.dart';
import 'overlays/pause_overlay.dart';

/// The environment comes from the `APP_ENV` dart-define automatically
/// (`flutter run --dart-define=APP_ENV=dev`); no per-env entrypoints needed.
/// See [AppEnv.current].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  runApp(const RunnerApp());
}

class RunnerApp extends StatelessWidget {
  const RunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final env = AppEnv.current;
    return MaterialApp(
      title: 'Nightfall Ninja',
      debugShowCheckedModeBanner: false,
      home: env.showBanner
          ? Banner(
              message: env.label,
              location: BannerLocation.topEnd,
              color: env.bannerColor,
              child: const GameScreen(),
            )
          : const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final RunnerGame _game = RunnerGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _game.handleTapDown(),
        onTapUp: (_) => _game.handleTapUp(),
        onTapCancel: _game.handleTapUp,
        child: GameWidget<RunnerGame>(
          game: _game,
          overlayBuilderMap: {
            RunnerGame.overlayMainMenu: (_, game) =>
                MainMenuOverlay(game: game),
            RunnerGame.overlayHud: (_, game) => HudOverlay(game: game),
            RunnerGame.overlayGameOver: (_, game) =>
                GameOverOverlay(game: game),
            RunnerGame.overlayPause: (_, game) => PauseOverlay(game: game),
          },
        ),
      ),
    );
  }
}
