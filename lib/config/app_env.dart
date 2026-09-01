import 'package:flutter/material.dart';

/// Build environment, selected at build/run time via
/// `--dart-define=APP_ENV=<dev|staging|prod>` (defaults to `prod` when
/// unset, e.g. plain `flutter run`, tests, web).
enum AppEnv {
  dev,
  staging,
  prod;

  /// The active environment, read once from the `APP_ENV` dart-define.
  static AppEnv current = AppEnv.fromName(
    const String.fromEnvironment('APP_ENV', defaultValue: 'prod'),
  );

  /// Maps the `APP_ENV` dart-define value to an environment. Anything
  /// unrecognized falls back to prod.
  static AppEnv fromName(String? name) => switch (name) {
    'dev' => AppEnv.dev,
    'staging' => AppEnv.staging,
    _ => AppEnv.prod,
  };

  String get label => switch (this) {
    AppEnv.dev => 'DEV',
    AppEnv.staging => 'STAGING',
    AppEnv.prod => '',
  };

  Color get bannerColor => switch (this) {
    AppEnv.dev => const Color(0xFFD32F2F),
    AppEnv.staging => const Color(0xFFF57C00),
    AppEnv.prod => Colors.transparent,
  };

  bool get showBanner => this != AppEnv.prod;
}
