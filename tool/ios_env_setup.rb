# Ensures the iOS Runner project has no leftover per-flavor Xcode build
# configurations/schemes from the old flavor-based setup, and that the
# Runner target has a build phase to set the app's display name for the
# active environment.
#
# Environment selection is via `--dart-define=APP_ENV=<dev|staging|prod>`,
# not native Xcode flavors/configurations - see lib/config/app_env.dart and
# android/app/build.gradle.kts. The one thing that *can't* come from a
# dart-define is PRODUCT_BUNDLE_IDENTIFIER: Xcode resolves it (for code
# signing) before any build-phase script runs, so the bundle id stays fixed
# across environments. The app *display name* isn't part of signing, so it
# can be, and is, set dynamically here.
#
# Safe to re-run (e.g. after `flutter create` regenerates the ios/ project).
require 'xcodeproj'

PROJECT_PATH = File.expand_path('../ios/Runner.xcodeproj', __dir__)
SCHEME_DIR = File.join(PROJECT_PATH, 'xcshareddata/xcschemes')

project = Xcodeproj::Project.open(PROJECT_PATH)

# 1. Remove any leftover per-flavor build configurations (Debug-dev,
#    Release-staging, Profile-prod, ...) added by the old flavor setup.
per_env_config_name = /\A(Debug|Release|Profile)-(dev|staging|prod)\z/
removed = project.objects.select do |o|
  o.isa == 'XCBuildConfiguration' && o.name =~ per_env_config_name
end
removed.each(&:remove_from_project)
puts "removed #{removed.size} per-environment build configuration(s)" if removed.any?

# 2. Remove the per-flavor schemes; keep the default Runner scheme.
%w[dev staging prod].each do |env|
  scheme_file = File.join(SCHEME_DIR, "#{env}.xcscheme")
  next unless File.exist?(scheme_file)
  File.delete(scheme_file)
  puts "removed scheme: #{env}"
end

# 3. Make sure Runner has a build phase that sets CFBundleDisplayName from
#    the APP_ENV dart-define.
runner = project.targets.find { |t| t.name == 'Runner' }
raise 'Runner target not found' unless runner

phase_name = 'Set App Display Name (env)'
if runner.build_phases.any? { |p| p.respond_to?(:name) && p.name == phase_name }
  puts "build phase already present: #{phase_name}"
else
  phase = runner.new_shell_script_build_phase(phase_name)
  phase.shell_path = '/bin/sh'
  phase.shell_script = <<~SCRIPT
    set -e

    APP_ENV="prod"
    if [ -n "$DART_DEFINES" ]; then
      for encoded in $(echo "$DART_DEFINES" | tr ',' ' '); do
        decoded=$(echo "$encoded" | base64 --decode)
        case "$decoded" in
          APP_ENV=*) APP_ENV="${decoded#APP_ENV=}" ;;
        esac
      done
    fi

    case "$APP_ENV" in
      dev) DISPLAY_NAME="NF Ninja Dev" ;;
      staging) DISPLAY_NAME="NF Ninja Stg" ;;
      *) DISPLAY_NAME="Nightfall Ninja" ;;
    esac

    PLIST="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
    if [ -f "$PLIST" ]; then
      /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName ${DISPLAY_NAME}" "$PLIST"
      echo "APP_ENV=${APP_ENV} -> CFBundleDisplayName=${DISPLAY_NAME}"
    else
      echo "warning: Info.plist not found at $PLIST, skipping display name override"
    fi
  SCRIPT
  puts "added build phase: #{phase_name}"
end

project.save
puts 'done. remaining configs: ' + project.build_configurations.map(&:name).sort.uniq.join(', ')
