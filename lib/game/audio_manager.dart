import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Plays the generated chiptune sound effects and music, with a persisted
/// mute toggle. All calls are safe no-ops when audio is unavailable
/// (e.g. in widget tests).
class AudioManager {
  static const _files = [
    'jump.wav',
    'double_jump.wav',
    'point.wav',
    'coin.wav',
    'hit.wav',
    'bgm.wav',
  ];

  bool enabled = true;
  bool _loaded = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    enabled = prefs.getBool('sound_on') ?? true;
    try {
      FlameAudio.bgm.initialize();
      await FlameAudio.audioCache.loadAll(_files);
      _loaded = true;
    } catch (_) {
      // No audio backend available; the game simply plays silently.
    }
  }

  void toggle() {
    enabled = !enabled;
    if (!enabled) stopMusic();
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setBool('sound_on', enabled),
    );
  }

  void jump(int jumpNumber) =>
      _play(jumpNumber > 1 ? 'double_jump.wav' : 'jump.wav', 0.55);

  void point() => _play('point.wav', 0.5);

  void coin() => _play('coin.wav', 0.5);

  void hit() => _play('hit.wav', 0.8);

  void startMusic() {
    if (!enabled || !_loaded) return;
    try {
      FlameAudio.bgm.play('bgm.wav', volume: 0.4);
    } catch (_) {}
  }

  void stopMusic() {
    if (!_loaded) return;
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }

  void pauseMusic() {
    if (!_loaded) return;
    try {
      FlameAudio.bgm.pause();
    } catch (_) {}
  }

  void resumeMusic() {
    if (!enabled || !_loaded) return;
    try {
      FlameAudio.bgm.resume();
    } catch (_) {}
  }

  void _play(String file, double volume) {
    if (!enabled || !_loaded) return;
    try {
      FlameAudio.play(file, volume: volume);
    } catch (_) {}
  }
}
