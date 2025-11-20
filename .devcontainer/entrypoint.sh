#!/bin/bash
set -e

echo "🚀 DevPod workspace initializing..."

# # --- Initialize environment variables ---
# if [ -f "/workspace/init-env-vars.sh" ]; then
#     echo "🔧 Running environment variable initialization..."
#     source /workspace/init-env-vars.sh
# fi

# --- Git global setup ---
git config --global credential.helper 'cache --timeout=3600' || true

cd /workspace

# --- Repo setup ---
if [ ! -d "frontend/.git" ]; then
  git clone "$FRONTEND_REPO" frontend
fi

if [ ! -d "backend/.git" ]; then
  git clone "$BACKEND_REPO" backend
fi

# ✅ Automatically mark all repos as safe
echo "🔒 Marking repositories as safe..."
find /workspace -maxdepth 3 -type d -name ".git" -print0 |
while IFS= read -r -d '' gitdir; do
  repo_dir="$(dirname "$gitdir")"
  echo "   ➕ Safe: $repo_dir"
  git config --global --add safe.directory "$repo_dir" || true
done

echo "✅ Environment ready! You can now run VS Code tasks to build and start services."
exec sleep infinity
