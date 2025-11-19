#!/bin/bash
set -e

echo "⚙️  Bootstrapping multi-repo workspace via entrypoint..."

FRONTEND_REF="${FRONTEND_REF:-main}"
BACKEND_REF="${BACKEND_REF:-main}"

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
git config --global --add safe.directory /workspace || true
git config --global credential.helper 'cache --timeout=3600' || true

# ------------------------------------------------------------------------------
# HELPER FUNCTIONS
# ------------------------------------------------------------------------------
clone_or_update() {
  local dir=$1
  local repo=$2
  local ref=$3
  local path="/workspace/$dir"

  if [ ! -d "$path/.git" ]; then
    echo "📦 Cloning $repo into $dir"
    git clone "$repo" "$path"
  else
    echo "🔁 Updating existing repo in $dir"
    (cd "$path" && git fetch origin) || true
  fi

  echo "🔖 Checking out $ref in $dir"
  (cd "$path" && git checkout "$ref" && git pull origin "$ref" || true)
}

clone_or_update "frontend" "$FRONTEND_REPO" "$FRONTEND_REF"
clone_or_update "backend" "$BACKEND_REPO" "$BACKEND_REF"

# ------------------------------------------------------------------------------
# FRONTEND SETUP (Incremental via Yarn)
# ------------------------------------------------------------------------------
echo "📋 Ensuring frontend dependencies (Yarn)..."
FRONTEND_NODE_MODULES="/workspace/frontend/node_modules"
FRONTEND_LOCKFILE="/workspace/frontend/yarn.lock"

if [ ! -d "$FRONTEND_NODE_MODULES" ] || [ "$FRONTEND_LOCKFILE" -nt "$FRONTEND_NODE_MODULES" ]; then
  echo "📦 Installing/updating frontend dependencies with Yarn..."
  (cd /workspace/frontend && yarn install --frozen-lockfile)
else
  echo "✅ Frontend dependencies up-to-date."
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
        (cd "$backend" && mvn -q clean package -DskipTests)
        touch "$backend/target/.last-build"
      else
        echo "✅ Backend already built (Maven, no source changes)."
      fi
    fi
  elif [ -f "$backend/build.gradle" ] || [ -f "$backend/build.gradle.kts" ]; then
    if command -v gradle &>/dev/null; then
      if [ ! -f "$backend/build/.last-build" ] || find "$backend/src" -type f -newer "$backend/build/.last-build" | grep -q .; then
        echo "🧱 Building backend via Gradle..."
        (cd "$backend" && gradle -q build -x test)
        touch "$backend/build/.last-build"
      else
        echo "✅ Backend already built (Gradle, no source changes)."
      fi
    fi
  else
    echo "⚠️ No recognizable backend build system found."
  fi
}

build_backend

# ------------------------------------------------------------------------------
# STARTUP FUNCTIONS (Yarn & Spring Boot)
# ------------------------------------------------------------------------------
start_backend() {
  local backend="/workspace/backend"
  if [ -f "$backend/pom.xml" ]; then
    echo "→ Starting Spring Boot backend (Maven)"
    (cd "$backend" && mvn spring-boot:run)
  elif [ -f "$backend/build.gradle" ] || [ -f "$backend/build.gradle.kts" ]; then
    echo "→ Starting Spring Boot backend (Gradle)"
    (cd "$backend" && gradle bootRun)
  else
    echo "⚠️ Backend start skipped – no supported configuration."
  fi
}

start_frontend() {
  echo "→ Starting Next.js frontend (Yarn)"
  (cd /workspace/frontend && yarn dev)
}

# ------------------------------------------------------------------------------
# RUN SERVICES (non-blocking)
# ------------------------------------------------------------------------------
echo "🚀 Launching backend and frontend..."

start_backend &
backend_pid=$!

start_frontend &
frontend_pid=$!

# ------------------------------------------------------------------------------
# KEEP CONTAINER ALIVE EVEN IF BOTH STOP
# ------------------------------------------------------------------------------
while true; do
  if [ -n "$backend_pid" ] && ! kill -0 "$backend_pid" 2>/dev/null; then
    echo "⚠️ Backend process stopped."
    backend_pid=""
  fi

  if [ -n "$frontend_pid" ] && ! kill -0 "$frontend_pid" 2>/dev/null; then
    echo "⚠️ Frontend process stopped."
    frontend_pid=""
  fi

  sleep 30 # keep alive
done
