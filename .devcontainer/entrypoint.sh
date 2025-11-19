#!/bin/bash
set -Eeuo pipefail

echo "⚙️  Bootstrapping multi-repo workspace via entrypoint..."

FRONTEND_REF="${FRONTEND_REF:-main}"
BACKEND_REF="${BACKEND_REF:-main}"

# ------------------------------------------------------------------------------
# UTILITY FUNCTION: never let any command failure kill the container
# ------------------------------------------------------------------------------
safe_exec() {
  "$@" || echo "⚠️ Command failed: $* (continuing)"
}

# ------------------------------------------------------------------------------
# LOAD LOCAL CONFIG (.env)
# ------------------------------------------------------------------------------
if [ -f "/workspace/.env" ]; then
  echo "📄 Loading environment variables from .env"
  set -o allexport
  source /workspace/.env
  set +o allexport
fi

# ------------------------------------------------------------------------------
# BASIC GIT CONFIGURATION
# ------------------------------------------------------------------------------
safe_exec git config --global --add safe.directory /workspace
safe_exec git config --global credential.helper 'cache --timeout=3600'

# ------------------------------------------------------------------------------
# CLONE OR UPDATE REPOSITORIES
# ------------------------------------------------------------------------------
clone_or_update() {
  local dir=$1
  local repo=$2
  local ref=$3
  local path="/workspace/$dir"

  if [ ! -d "$path/.git" ]; then
    echo "📦 Cloning $repo into $dir"
    safe_exec git clone "$repo" "$path"
  else
    echo "🔁 Updating $dir"
    safe_exec bash -c "cd '$path' && git fetch origin"
  fi

  echo "🔖 Checking out $ref in $dir"
  safe_exec bash -c "cd '$path' && git checkout '$ref' && git pull origin '$ref'"
}

clone_or_update "frontend" "$FRONTEND_REPO" "$FRONTEND_REF"
clone_or_update "backend" "$BACKEND_REPO" "$BACKEND_REF"

# ------------------------------------------------------------------------------
# FRONTEND SETUP (Yarn with persistent cache)
# ------------------------------------------------------------------------------
echo "📋 Validating frontend dependencies..."
FRONTEND_NODE_MODULES="/workspace/frontend/node_modules"
FRONTEND_LOCKFILE="/workspace/frontend/yarn.lock"

if [ ! -d "$FRONTEND_NODE_MODULES" ] || [ "$FRONTEND_LOCKFILE" -nt "$FRONTEND_NODE_MODULES" ]; then
  echo "📦 Installing/updating frontend packages with Yarn..."
  safe_exec bash -c "cd /workspace/frontend && yarn install --frozen-lockfile"
else
  echo "✅ Frontend dependencies are current."
fi

# ------------------------------------------------------------------------------
# BACKEND BUILD (Incremental)
# ------------------------------------------------------------------------------
build_backend() {
  local backend="/workspace/backend"

  if [ -f "$backend/pom.xml" ]; then
    if command -v mvn &>/dev/null; then
      if [ ! -f "$backend/target/.last-build" ] || find "$backend/src" -type f -newer "$backend/target/.last-build" | grep -q .; then
        echo "🧱 Building backend via Maven..."
        safe_exec bash -c "cd '$backend' && mvn -q clean package -DskipTests"
        touch "$backend/target/.last-build"
      else
        echo "✅ Backend build up-to-date (Maven)."
      fi
    fi
  elif [ -f "$backend/build.gradle" ] || [ -f "$backend/build.gradle.kts" ]; then
    if command -v gradle &>/dev/null; then
      if [ ! -f "$backend/build/.last-build" ] || find "$backend/src" -type f -newer "$backend/build/.last-build" | grep -q .; then
        echo "🧱 Building backend via Gradle..."
        safe_exec bash -c "cd '$backend' && gradle -q build -x test"
        touch "$backend/build/.last-build"
      else
        echo "✅ Backend build up-to-date (Gradle)."
      fi
    fi
  else
    echo "⚠️ No backend build system detected."
  fi
}

build_backend

# ------------------------------------------------------------------------------
# START SERVICES (non-blocking)
# ------------------------------------------------------------------------------
start_backend() {
  if [ -f "/workspace/backend/pom.xml" ]; then
    echo "→ Starting Spring Boot backend (Maven)"
    (cd /workspace/backend && mvn spring-boot:run)
  elif [ -f "/workspace/backend/build.gradle" ] || [ -f "/workspace/backend/build.gradle.kts" ]; then
    echo "→ Starting Spring Boot backend (Gradle)"
    (cd /workspace/backend && gradle bootRun)
  else
    echo "⚠️ Backend start skipped."
  fi
}

start_frontend() {
  echo "→ Starting Next.js frontend (Yarn)"
  (cd /workspace/frontend && yarn dev)
}

echo "🚀 Launching services in background"
(start_backend &) && backend_pid=$!
(start_frontend &) && frontend_pid=$!

# ------------------------------------------------------------------------------
# KEEP CONTAINER ALIVE PERMANENTLY (regardless of process state)
# ------------------------------------------------------------------------------
echo "🟢 Devcontainer setup complete. Keeping container alive..."

# Endless idle loop to prevent container exit
while true; do
  if [ -n "${backend_pid:-}" ] && ! kill -0 "$backend_pid" 2>/dev/null; then
    echo "⚠️ Backend process has stopped."
    backend_pid=""
  fi
  if [ -n "${frontend_pid:-}" ] && ! kill -0 "$frontend_pid" 2>/dev/null; then
    echo "⚠️ Frontend process has stopped."
    frontend_pid=""
  fi
  sleep 30
done
