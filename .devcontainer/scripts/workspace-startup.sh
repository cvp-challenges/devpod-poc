#!/bin/bash
set -e

if [ ! -d "/workspace/common" ]; then
  mkdir -p /workspace/common
  for item in /workspace/*; do
    if [ -e "$item" ]; then
      basename_item=$(basename "$item")
      if [ "$basename_item" != "common" ]; then
        mv "$item" /workspace/common/
      fi
    fi
  done
fi

if [ ! -d "/workspace/backend/.git" ] || [ -z "$(ls -A /workspace/backend 2>/dev/null)" ]; then
  rm -rf /workspace/backend
  git clone https://github.com/cvp-challenges/devpod-odos-backend.git /workspace/backend
fi

if [ ! -d "/workspace/frontend/.git" ] || [ -z "$(ls -A /workspace/frontend 2>/dev/null)" ]; then
  rm -rf /workspace/frontend
  git clone https://github.com/cvp-challenges/devpod-odos-frontend.git /workspace/frontend
fi

# Fix ownership
chown -R vscode:vscode /workspace/common /workspace/frontend /workspace/backend || true

# Configure git safe directories
git config --global --add safe.directory /workspace/common
git config --global --add safe.directory /workspace/backend
git config --global --add safe.directory /workspace/frontend

# Wait for the container to stay alive
tail -f /dev/null
