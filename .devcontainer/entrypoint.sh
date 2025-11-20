#!/bin/bash
set -e

echo "🚀 DevPod workspace initializing..."

# Ensure git works in /workspace and child dirs
git config --global --add safe.directory /workspace
git config --global --add safe.directory /workspace/backend
git config --global --add safe.directory /workspace/frontend

# Optionally apply global configs (DevPod may inject identity)
# if [ -n "$GIT_COMMITTER_NAME" ]; then
#   git config --global user.name "$GIT_COMMITTER_NAME"
# fi
# if [ -n "$GIT_COMMITTER_EMAIL" ]; then
#   git config --global user.email "$GIT_COMMITTER_EMAIL"
# fi

cd /workspace

# --- Repo setup ---
if [ ! -d "frontend/.git" ]; then
  git clone "$FRONTEND_REPO" frontend
fi

if [ ! -d "backend/.git" ]; then
  git clone "$BACKEND_REPO" backend
fi

# tail -f /dev/null
exec sleep infinity
