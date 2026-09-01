import 'package:flutter/material.dart';

import '../game/runner_game.dart';
import 'coin_icon.dart';
import 'game_button.dart';
import 'sound_toggle.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  final RunnerGame game;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black38,
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(child: SoundToggle(game: game)),
          ),
          Center(child: _content()),
        ],
      ),
    );
  }

  Widget _content() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'GAME OVER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 44,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
            shadows: [Shadow(color: Colors.black45, blurRadius: 12)],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Score  ${game.score.value}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (game.coins.value > 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CoinIcon(size: 16),
              const SizedBox(width: 6),
              Text(
                '${game.coins.value} collected',
                style: const TextStyle(
                  color: Color(0xFFFFD54F),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        Text(
          game.newBest ? 'New best!' : 'Best  ${game.highScore}',
          style: TextStyle(
            color: game.newBest ? const Color(0xFFFFEE58) : Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 26),
        GameButton(label: 'RUN AGAIN', onPressed: game.startGame),
      ],
    );
  }
}
