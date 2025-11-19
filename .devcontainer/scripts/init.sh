#!/bin/sh
set -e

# DEV_CONTAINER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# ROOT_DIR="$(dirname "$DEV_CONTAINER_DIR")"
# ENV="$DEV_CONTAINER_DIR/.env"

# if [ -f $ENV ]; then
#     echo "Sourcing environment variables from $ENV..."
#      export $(grep -v '^#' $ENV | xargs)
# else
#     echo "Warning: .env file not found at $ENV"
# fi

# if [ ! -d "$ROOT_DIR/frontend" ]; then
#     echo "Cloning frontend repository from $FRONTEND_REPO_URL..."
#     git clone "$FRONTEND_REPO_URL" "$ROOT_DIR/frontend"
# else
#     echo "Frontend directory already exists, skipping clone."
# fi

# if [ ! -d "$ROOT_DIR/backend" ]; then
#     echo "Cloning backend repository from $BACKEND_REPO_URL..."
#     git clone "$BACKEND_REPO_URL" "$ROOT_DIR/backend"
# else
#     echo "Backend directory already exists, skipping clone."
# fi

# if [ -d "$ROOT_DIR/frontend" ]; then
#     echo "Installing frontend dependencies..."
#     cd "$ROOT_DIR/frontend"
#     yarn install
#     cd "$ROOT_DIR"
# fi

# if [ -d "$ROOT_DIR/backend" ]; then
#     echo "Building backend..."
#     cd "$ROOT_DIR/backend"
#     mvn install -DskipTests
# fi

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
# git config --global --add safe.directory /workspace/common
git config --global --add safe.directory /workspace/backend
git config --global --add safe.directory /workspace/frontend

echo "Development environment setup complete!"
