#!/bin/bash
set -e

echo "🚀 DevPod workspace initializing..."

cd /workspace

# --- Repo setup ---
if [ ! -d "frontend/.git" ]; then
  git clone "$FRONTEND_REPO" frontend
fi

if [ ! -d "backend/.git" ]; then
  git clone "$BACKEND_REPO" backend
fi

# Ensure git works in /workspace and child dirs
git config --global --add safe.directory /workspace
git config --global --add safe.directory /workspace/backend
git config --global --add safe.directory /workspace/frontend

# tail -f /dev/null
exec sleep infinity
