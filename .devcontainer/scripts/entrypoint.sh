#!/bin/bash
set -euo pipefail

USER_HOME="/home/vscode"
ENV_FILE="${USER_HOME}/.env"
WORKSPACE_ENV="/workspace/.env"
PROJECT_ROOT="$USER_HOME/projects"
INIT_FLAG="${USER_HOME}/initialized"

echo "🚀 DevPod Initialization Starting..."

if [ ! -f "$INIT_FLAG" ]; then
  echo "🚀 First-time initialization..."

  # Run env setup (this now always works)
  . $USER_HOME/scripts/setup-env-vars.sh $ENV_FILE

  ##############################
  # Clone frontend/backend if missing
  ##############################
  echo "📚 Cloning repositories..."

  [ ! -d "$PROJECT_ROOT/backend/.git" ] && \
      git clone -q https://github.com/cvp-challenges/devpod-odos-backend $PROJECT_ROOT/backend

  [ ! -d "$PROJECT_ROOT/frontend/.git" ] && \
      git clone -q https://github.com/cvp-challenges/devpod-odos-frontend $PROJECT_ROOT/frontend

  ##############################
  # Configure Git safe directories
  ##############################
  git config --global --add safe.directory $PROJECT_ROOT/backend
  git config --global --add safe.directory $PROJECT_ROOT/frontend

  ##############################
  # Wait for Docker-in-Docker
  ##############################
  echo "🐳 Waiting for Docker daemon..."
  until docker info >/dev/null 2>&1; do sleep 1; done

  ##############################
  # Start shared services
  ##############################
  echo "🚀 Starting shared services..."
  cd /workspace/.devcontainer/services
  docker-compose up -d

  ##############################
  # Mark initialization complete
  ##############################
  touch "${INIT_FLAG}"
  echo "✅ First-time initialization complete!"
fi

##############################
# Always source env
##############################
echo "📁 Sourcing environment variables..."
set -a
source "${ENV_FILE}"
set +a

echo "🐢 DevContainer Ready!"
exec sleep infinity
