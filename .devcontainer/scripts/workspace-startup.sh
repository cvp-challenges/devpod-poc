#!/bin/bash
set -e

echo "=== Workspace Startup Script ==="

# Create common directory and move existing files if not already done
if [ ! -d "/workspace/common" ]; then
  echo "Creating common directory and moving existing files..."
  mkdir -p /workspace/common
  
  # Move all existing files and folders to common
  for item in /workspace/*; do
    if [ -e "$item" ]; then
      basename_item=$(basename "$item")
      if [ "$basename_item" != "common" ]; then
        echo "Moving $basename_item to /workspace/common/"
        mv "$item" /workspace/common/
      fi
    done
  fi
else
  echo "Common directory already exists, skipping file move."
fi

# Configure git safe directories
echo "Configuring git safe directories..."
git config --global --add safe.directory /workspace/common

# Only clone repositories if they do not exist or are empty
if [ ! -d "/workspace/backend/.git" ] || [ -z "$(ls -A /workspace/backend 2>/dev/null)" ]; then
  echo "Cloning backend repository..."
  rm -rf /workspace/backend
  git clone https://github.com/cvp-challenges/devpod-odos-backend.git /workspace/backend
else
  echo "Backend repository already exists, skipping clone."
fi

if [ ! -d "/workspace/frontend/.git" ] || [ -z "$(ls -A /workspace/frontend 2>/dev/null)" ]; then
  echo "Cloning frontend repository..."
  rm -rf /workspace/frontend
  git clone https://github.com/cvp-challenges/devpod-odos-frontend.git /workspace/frontend
else
  echo "Frontend repository already exists, skipping clone."
fi

# Fix ownership
echo "Fixing ownership..."
chown -R vscode:vscode /workspace/common || true

echo "=== Workspace setup complete! ==="

# Wait for the container to stay alive
echo "Keeping container alive..."
tail -f /dev/null
