#!/bin/bash

# Exit on error
set -e

CURRENT_BRANCH=$(git branch --show-current)

if [ -z "$CURRENT_BRANCH" ]; then
  echo "Error: Not on any branch."
  exit 1
fi

if [ "$CURRENT_BRANCH" == "dev" ] || [ "$CURRENT_BRANCH" == "qa" ] || [ "$CURRENT_BRANCH" == "master" ]; then
    echo "Error: You are currently on $CURRENT_BRANCH. Please run this from a feature branch."
    exit 1
fi

echo "🚀 Starting merge of feature '$CURRENT_BRANCH' into dev and qa..."

# Ensure we have the latest
echo "📡 Fetching origin..."
git fetch origin

# Update dev
echo "🔄 Merging into dev..."
git checkout dev
git pull origin dev
git merge "$CURRENT_BRANCH"

# Update qa
echo "🔄 Merging into qa..."
git checkout qa
git pull origin qa
git merge "$CURRENT_BRANCH"

# Batch Push
echo "🚀 Pushing dev and qa to origin..."
git push origin dev qa

# Return
echo "🔙 Returning to $CURRENT_BRANCH..."
git checkout "$CURRENT_BRANCH"

echo "✅ Done! Merged '$CURRENT_BRANCH' to dev and qa, and pushed both."
