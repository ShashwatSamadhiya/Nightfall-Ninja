import 'package:flutter/material.dart';

import '../game/runner_game.dart';
import 'coin_icon.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final RunnerGame game;

  static const TextStyle _style = TextStyle(
    color: Colors.white,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: 2,
    shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: game.pauseGame,
              iconSize: 30,
              color: Colors.white,
              tooltip: 'Pause',
              icon: const Icon(
                Icons.pause_rounded,
                shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
              ),
            ),
            const SizedBox(width: 8),
            if (game.highScore > 0)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'BEST ${game.highScore}',
                  style: _style.copyWith(fontSize: 16, color: Colors.white70),
                ),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 16),
              child: ValueListenableBuilder<int>(
                valueListenable: game.coins,
                builder: (_, coins, _) => Row(
                  children: [
                    const CoinIcon(size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '$coins',
                      style: _style.copyWith(
                        fontSize: 20,
                        color: const Color(0xFFFFD54F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: ValueListenableBuilder<int>(
                valueListenable: game.score,
                builder: (_, score, _) =>
                    Text(score.toString().padLeft(5, '0'), style: _style),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
