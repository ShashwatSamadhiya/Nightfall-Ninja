import 'package:flutter/material.dart';

import '../game/runner_game.dart';
import 'coin_icon.dart';
import 'game_button.dart';
import 'sound_toggle.dart';

class MainMenuOverlay extends StatelessWidget {
  const MainMenuOverlay({super.key, required this.game});

  final RunnerGame game;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black26,
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(child: SoundToggle(game: game)),
          ),
          Center(child: _menuContent()),
        ],
      ),
    );
  }

  Widget _menuContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'NIGHTFALL NINJA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 44,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
            shadows: [Shadow(color: Colors.black45, blurRadius: 12)],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Tap to jump — tap again in the air to double-jump',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        if (game.highScore > 0 || game.totalCoins > 0) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (game.highScore > 0)
                Text(
                  'Best: ${game.highScore}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (game.highScore > 0 && game.totalCoins > 0)
                const SizedBox(width: 20),
              if (game.totalCoins > 0) ...[
                const CoinIcon(size: 16),
                const SizedBox(width: 6),
                Text(
                  '${game.totalCoins}',
                  style: const TextStyle(
                    color: Color(0xFFFFD54F),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: 28),
        GameButton(label: 'PLAY', onPressed: game.startGame),
      ],
    );
  }
}
