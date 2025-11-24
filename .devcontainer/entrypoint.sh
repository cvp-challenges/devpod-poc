#!/bin/bash
set -e

ENV=/workspace/.env

echo "🚀 DevPod workspace initializing..."

cd /workspace

# Check if .env exists
if [ ! -f $ENV ]; then
  ./init-env-vars.sh
fi

# export all env variables
export $(cat $ENV | grep -v '^#' | xargs)

# --- Git global setup ---
git config --global credential.helper 'cache --timeout=3600' || true

# --- Repo setup ---
if [ ! -d "frontend/.git" ]; then
  git clone "$FRONTEND_REPO" frontend
fi

if [ ! -d "backend/.git" ]; then
  git clone "$BACKEND_REPO" backend
fi

# ✅ Automatically mark all repos as safe
echo "🔒 Marking repositories as safe..."
find /workspace -maxdepth 3 -type d -name ".git" -print0 |
while IFS= read -r -d '' gitdir; do
  repo_dir="$(dirname "$gitdir")"
  echo "   ➕ Safe: $repo_dir"
  git config --global --add safe.directory "$repo_dir" || true
done

# Start Docker daemon
# dockerd-entrypoint.sh &

# Give Docker a few seconds to initialize
#sleep 5

# Start Docker Compose stack
# docker-compose -f ./common/services.yml up -d

echo "✅ Environment ready! You can now run VS Code tasks to build and start services."
exec sleep infinity
