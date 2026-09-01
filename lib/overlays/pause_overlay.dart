import 'package:flutter/material.dart';

import '../game/runner_game.dart';
import 'game_button.dart';
import 'sound_toggle.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  final RunnerGame game;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black45,
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(child: SoundToggle(game: game)),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PAUSED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 12)],
                  ),
                ),
                const SizedBox(height: 26),
                GameButton(label: 'RESUME', onPressed: game.resumeGame),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: game.quitToMenu,
                  child: const Text(
                    'MAIN MENU',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
