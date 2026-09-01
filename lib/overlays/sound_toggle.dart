import 'package:flutter/material.dart';

import '../game/runner_game.dart';

class SoundToggle extends StatefulWidget {
  const SoundToggle({super.key, required this.game});

  final RunnerGame game;

  @override
  State<SoundToggle> createState() => _SoundToggleState();
}

class _SoundToggleState extends State<SoundToggle> {
  @override
  Widget build(BuildContext context) {
    final enabled = widget.game.audio.enabled;
    return IconButton(
      onPressed: () => setState(widget.game.audio.toggle),
      iconSize: 32,
      color: Colors.white,
      tooltip: enabled ? 'Mute' : 'Unmute',
      icon: Icon(
        enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        shadows: const [Shadow(color: Colors.black45, blurRadius: 8)],
      ),
    );
  }
}
