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

# if [ ! -d "/workspace/common" ]; then
#   mkdir -p /workspace/common
#   for item in /workspace/*; do
#     if [ -e "$item" ]; then
#       basename_item=$(basename "$item")
#       if [ "$basename_item" != "common" ]; then
#         mv "$item" /workspace/common/
#       fi
#     fi
#   done
# fi

# mkdir common
# mv .git/ common/
# mv .devcontainer/ common/
# mv postgres/ common/
# mv keycloak/ common/

if [ ! -d "/workspace/backend/.git" ] || [ -z "$(ls -A /workspace/backend 2>/dev/null)" ]; then
  rm -rf /workspace/backend
  git clone https://github.com/cvp-challenges/devpod-odos-backend.git /workspace/backend
fi

if [ ! -d "/workspace/frontend/.git" ] || [ -z "$(ls -A /workspace/frontend 2>/dev/null)" ]; then
  rm -rf /workspace/frontend
  git clone https://github.com/cvp-challenges/devpod-odos-frontend.git /workspace/frontend
fi

# Fix ownership and permissions
sudo chown -R vscode:vscode /workspace || true
sudo chmod -R 755 /workspace || true

# Ensure Git directories have proper permissions
if [ -d "/workspace/.git" ]; then
    sudo chown -R vscode:vscode /workspace/.git || true
    sudo chmod -R 755 /workspace/.git || true
fi

if [ -d "/workspace/frontend/.git" ]; then
    sudo chown -R vscode:vscode /workspace/frontend/.git || true
    sudo chmod -R 755 /workspace/frontend/.git || true
fi

if [ -d "/workspace/backend/.git" ]; then
    sudo chown -R vscode:vscode /workspace/backend/.git || true
    sudo chmod -R 755 /workspace/backend/.git || true
fi

# Configure git safe directories
git config --global --add safe.directory /workspace
git config --global --add safe.directory /workspace/backend
git config --global --add safe.directory /workspace/frontend
git config --global --add safe.directory '*'

# Configure Git user from host environment
if [ -z "$(git config --global user.name 2>/dev/null)" ]; then
    if [ -n "$HOST_GIT_USER_NAME" ] && [ "$HOST_GIT_USER_NAME" != "USER" ]; then
        git config --global user.name "$HOST_GIT_USER_NAME"
        echo "Set Git user.name to: $HOST_GIT_USER_NAME (from host)"
    else
        echo "Warning: No host Git user name found. Please run 'git config --global user.name \"Your Name\"' to set it."
    fi
fi

if [ -z "$(git config --global user.email 2>/dev/null)" ]; then
    if [ -n "$HOST_GIT_USER_EMAIL" ] && [ "$HOST_GIT_USER_EMAIL" != "EMAIL" ]; then
        git config --global user.email "$HOST_GIT_USER_EMAIL"
        echo "Set Git user.email to: $HOST_GIT_USER_EMAIL (from host)"
    else
        echo "Warning: No host Git user email found. Please run 'git config --global user.email \"your@email.com\"' to set it."
    fi
fi

# Display current Git configuration
echo "Current Git configuration:"
echo "  Name: $(git config --global user.name 2>/dev/null || echo 'Not set')"
echo "  Email: $(git config --global user.email 2>/dev/null || echo 'Not set')"

# Set Git configuration for better compatibility
git config --global core.filemode false
git config --global core.autocrlf input
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor "code --wait"
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'
git config --global diff.tool vscode
git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'

# Ensure proper Git file permissions
git config --global core.sharedRepository group
git config --global receive.denyNonFastforwards false

# Refresh Git index for all repositories
cd /workspace && git status > /dev/null 2>&1 || true
cd /workspace/backend && git status > /dev/null 2>&1 || true
cd /workspace/frontend && git status > /dev/null 2>&1 || true

echo "Development environment setup complete!"
