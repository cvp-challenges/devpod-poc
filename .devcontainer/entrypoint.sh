#!/bin/bash
set -e

echo "🚀 DevPod workspace initializing..."

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

# # Install Frontend dependencies
# echo "📋 Installing frontend dependencies..."
# cd /workspace/frontend
# yarn install --frozen-lockfile

# # Backend prebuild check
# echo "🧱 Resolving backend Maven dependencies..."
# cd /workspace/backend
# mvn -q dependency:resolve
# mvn clean install -Dmaven.test.skip=true

echo "✅ Environment ready! You can now run VS Code tasks to build and start services."
exec sleep infinity
