#!/bin/bash
set -e

INIT_FLAG="/workspace/.initialized"

if [ ! -f "$INIT_FLAG" ]; then
  echo "🚀 First-time initialization..."

  # Generate .env file
  /workspace/.devcontainer/scripts/setup-env-vars.sh

  echo "📚 Cloning repositories..."

  if [ ! -d "/workspace/frontend/.git" ]; then
    git clone -q https://github.com/cvp-challenges/devpod-odos-frontend /workspace/frontend
  fi

  if [ ! -d "/workspace/backend/.git" ]; then
    git clone -q https://github.com/cvp-challenges/devpod-odos-backend /workspace/backend
  fi

  echo "🔒 Configuring Git safe directories..."
  git config --global --add safe.directory /workspace
  git config --global --add safe.directory /workspace/frontend
  git config --global --add safe.directory /workspace/backend

  echo "🌐 Waiting for Docker..."
  until docker info >/dev/null 2>&1; do sleep 1; done

  echo "🚀 Starting shared services..."
  cd /workspace/.devcontainer/services
  docker-compose up -d

  touch "$INIT_FLAG"
  echo "✅ Initialization complete!"
fi

echo "📁 Sourcing environment variables..."
set -a
source "../../.env"
set +a

chown -R vscode:vscode /workspace/frontend /workspace/backend /workspace/.env /workspace/.initialized

exec sleep infinity
