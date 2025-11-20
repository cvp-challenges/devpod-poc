#!/bin/bash
set -Eeuo pipefail

echo "⚙️  Setting up workspace..."

FRONTEND_REF="${FRONTEND_REF:-main}"
BACKEND_REF="${BACKEND_REF:-main}"

# Load local .env if present
if [ -f "/workspace/.devcontainer/.env" ]; then
  source /workspace/.devcontainer/.env
fi

# Git setup
git config --global --add safe.directory /workspace || true
git config --global credential.helper 'cache --timeout=3600' || true

clone_or_update() {
  local dir="${1:-}" repo="${2:-}" ref="${3:-}" path="/workspace/$dir"

  if [ -z "$dir" ] || [ -z "$repo" ]; then
    echo "⚠️  Missing parameters for clone_or_update(): dir='$dir', repo='$repo'"
    return 0
  fi

  if [ ! -d "$path/.git" ]; then
    echo "📦 Cloning $repo into $path ..."
    git clone "$repo" "$path"
  fi

  (
    cd "$path"
    git fetch origin || true
    [ -n "$ref" ] && git checkout "$ref" || true
    git pull --ff-only || true
  )
}

clone_or_update frontend "$FRONTEND_REPO" "$FRONTEND_REF"
clone_or_update backend "$BACKEND_REPO" "$BACKEND_REF"

# Install deps incrementally
if [ ! -d "/workspace/frontend/node_modules" ] || [ "/workspace/frontend/yarn.lock" -nt "/workspace/frontend/node_modules" ]; then
  echo "📋 Installing frontend deps..."
  (cd /workspace/frontend && yarn install --frozen-lockfile)
else
  echo "✅ Frontend up to date."
fi

# Backend prebuild check
if [ -f /workspace/backend/pom.xml ]; then
  echo "🧱 Backend Maven build check..."
  (cd /workspace/backend && mvn -q dependency:resolve)
# elif [ -f /workspace/backend/build.gradle ] || [ -f /workspace/backend/build.gradle.kts ]; then
#   echo "🧱 Backend Gradle build check..."
#   (cd /workspace/backend && gradle -q dependencies > /dev/null)
fi

echo "✅ Environment ready! You can now run VS Code tasks to start services."

# Keep container alive
exec sleep infinity
