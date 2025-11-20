# #!/bin/bash
set -Eeuo pipefail

echo "⚙️  Setting up workspace..."

# Load local .env if present
if [ -f "/workspace/.devcontainer/.env" ]; then
  set -a
  source /workspace/.devcontainer/.env
  set +a
fi

# Ensure git works in /workspace and child dirs
git config --global --add safe.directory /workspace || true
# git config --global --add safe.directory /workspace/backend
# git config --global --add safe.directory /workspace/frontend
git config --global credential.helper 'cache --timeout=3600' || true

cd /workspace

# --- Repo setup ---
if [ ! -d "frontend/.git" ]; then
  git clone "$FRONTEND_REPO" frontend
fi

if [ ! -d "backend/.git" ]; then
  git clone "$BACKEND_REPO" backend
fi

# Install frontend deps incrementally
if [ -d "/workspace/frontend" ]; then
  if [ ! -d "/workspace/frontend/node_modules" ] || [ "/workspace/frontend/yarn.lock" -nt "/workspace/frontend/node_modules" ]; then
    echo "📋 Installing frontend deps..."
    (cd /workspace/frontend && yarn install --frozen-lockfile)
  else
    echo "✅ Frontend up to date."
  fi
fi

# Backend prebuild check
if [ -f /workspace/backend/pom.xml ]; then
  echo "🧱 Backend Maven build check..."
  (cd /workspace/backend && mvn -q dependency:resolve)
fi

echo "✅ Environment ready! You can now run VS Code tasks to start services."

# Keep container alive
exec sleep infinity
