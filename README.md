# Nightfall Ninja

An endless runner built with Flutter and [Flame](https://flame-engine.org/). Tap to jump (hold for a higher jump), dodge cacti and birds, and collect coins as the world scrolls through a full day → sunset → night → day cycle.

## Gameplay

- **Tap** to jump, release early for a short hop or hold for a full jump.
- Obstacles (cacti, low/high birds) and coin rows spawn as you run; obstacle variety and speed ramp up the longer you survive.
- Score comes from distance travelled plus coins collected (5 pts each).
- High score and total coins persist locally via `shared_preferences`.
- The sky, hills, and ground shade dynamically between day and night as you play.

## Project structure

```
lib/
  main.dart              # App entry point, GameWidget + overlay wiring
  config/
    app_env.dart          # dev/staging/prod environment selection
  game/
    runner_game.dart      # Core FlameGame: state machine, spawning, scoring, sky cycle
    player.dart            # Player character & jump physics
    obstacle.dart          # Cactus/bird obstacles
    coin.dart               # Collectible coins
    ground.dart             # Scrolling ground
    background.dart        # Sky, clouds, parallax hills
    audio_manager.dart     # Music & SFX playback
  overlays/
    main_menu_overlay.dart
    hud_overlay.dart
    pause_overlay.dart
    game_over_overlay.dart
    sound_toggle.dart
    game_button.dart
    coin_icon.dart
assets/
  audio/                  # bgm + sfx (jump, double jump, coin, hit, point)
  icon/                   # app icon source images
```

## Environments

The app supports `dev`, `staging`, and `prod` builds, selected via the `APP_ENV` dart-define (defaults to `prod`). Non-prod builds show a colored banner. Android build flavors map to distinct `applicationIdSuffix` values (see `android/app/build.gradle.kts`).

## Getting started

```bash
flutter pub get
flutter run --dart-define=APP_ENV=dev
```

VS Code launch configurations for dev/staging/prod (debug, profile, release) are preconfigured in `.vscode/launch.json`.

## Building

Use the bundled build script instead of raw `flutter build` calls — it validates the flavor/type, cleans `build_artifacts/`, and copies the final APK/AAB there:

```bash
./build.sh <dev|staging|prod> <apk|ios|run|appbundle>

# e.g.
./build.sh prod apk
./build.sh dev run
```

With no arguments it defaults to `./build.sh dev apk`. If [FVM](https://fvm.app/) is configured (`.fvmrc` present), the script uses `fvm flutter` automatically.

## Tech stack

- [Flutter](https://flutter.dev/)
- [Flame](https://flame-engine.org/) — game engine (rendering, components, collision detection)
- `flame_audio` — music & sound effects
- `shared_preferences` — local persistence of high score / coins
