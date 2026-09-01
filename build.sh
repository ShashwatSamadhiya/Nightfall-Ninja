#!/bin/bash

# Generic build script for multiple flavors
# Usage: ./build.sh [env] [apk|ios|run|appbundle]

set -e  # Stop on first error

# --- Allowed values ---
VALID_ENVS=("dev" "staging" "prod")
VALID_TYPES=("apk" "ios" "run" "appbundle")

# --- Flutter command (uses fvm when the project is configured for it) ---
if command -v fvm >/dev/null 2>&1 && [ -f .fvmrc ]; then
    FLUTTER="fvm flutter"
else
    FLUTTER="flutter"
fi

# --- Prepare workspace ---
mkdir -p ./build_artifacts        # ensures folder exists
rm -f ./build_artifacts/*         # clears old artifacts

# --- Trap Cleanup (auto-kill child processes on exit) ---
trap 'echo "🧹 Cleaning up..."; jobs -p | xargs -r kill 2>/dev/null || true' EXIT

# Function to check if a value exists in an array
function contains() {
    local value="$1"
    shift
    for item in "$@"; do
        if [[ "$item" == "$value" ]]; then
            return 0
        fi
    done
    return 1
}

# Validate argument count
if [ $# -gt 0 ]; then
    if [ $# -ne 2 ]; then
        echo "❌ Invalid number of arguments."
        echo "Usage: ./build.sh [env] [apk|ios|run|appbundle]"
        echo "Example: ./build.sh dev apk"
        exit 1
    fi

    env=$1
    BUILD_TYPE=$2

    # Validate environment
    if ! contains "$env" "${VALID_ENVS[@]}"; then
        echo "❌ Invalid environment: '$env'"
        echo "Valid environments are: ${VALID_ENVS[*]}"
        exit 1
    fi

    # Validate build type
    if ! contains "$BUILD_TYPE" "${VALID_TYPES[@]}"; then
        echo "❌ Invalid build type: '$BUILD_TYPE'"
        echo "Valid build types are: ${VALID_TYPES[*]}"
        exit 1
    fi
else
    # Default values if no arguments passed
    env="dev"
    BUILD_TYPE="apk"
    echo "⚠️  No arguments provided. Defaulting to: env=dev, build=apk"
fi

echo "===================="
echo "Building $env flavor"
echo "===================="

# The flavor reaches Dart automatically via Flutter's built-in `appFlavor`,
# so no extra --dart-define is needed.

case $BUILD_TYPE in
    apk)
        echo "📦 Building APK..."
        $FLUTTER build apk --flavor "$env"
        cp "build/app/outputs/flutter-apk/app-$env-release.apk" \
           "./build_artifacts/nightfall-ninja-$env.apk"
        ;;
    ios)
        echo "🍎 Building iOS..."
        $FLUTTER build ios --flavor "$env"
        ;;
    run)
        echo "🚀 Running app..."
        $FLUTTER run --flavor "$env"
        ;;
    appbundle)
        echo "📦 Building App Bundle..."
        $FLUTTER build appbundle --flavor "$env"
        cp "build/app/outputs/bundle/${env}Release/app-$env-release.aab" \
           "./build_artifacts/nightfall-ninja-$env.aab"
        ;;
esac

echo "✅ Build completed successfully!"
ls -lh ./build_artifacts 2>/dev/null || true
