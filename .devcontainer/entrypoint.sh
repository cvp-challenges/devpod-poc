#!/bin/bash
set -e

echo "🚀 Initializing Dev Container..."

# Git safe.directory setup (needed when repos cloned inside container)
git config --global --add safe.directory /workspace
git config --global --add safe.directory /workspace/frontend
git config --global --add safe.directory /workspace/backend

# Apply committer/author metadata if available
if [ -n "$GIT_COMMITTER_NAME" ]; then
  git config --global user.name "$GIT_COMMITTER_NAME"
fi
if [ -n "$GIT_COMMITTER_EMAIL" ]; then
  git config --global user.email "$GIT_COMMITTER_EMAIL"
fi

cd /workspace

# Clone repos at startup (inside container – ensures Git identity available)
if [ ! -d "frontend/.git" ]; then
  echo "📦 Cloning frontend repository..."
  git clone "$FRONTEND_REPO" frontend
fi

if [ ! -d "backend/.git" ]; then
  echo "📦 Cloning backend repository..."
  git clone "$BACKEND_REPO" backend
fi

echo "✅ Repositories ready. Container is idle."
exec sleep infinity
