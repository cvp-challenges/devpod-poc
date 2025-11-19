#!/bin/bash
set -e

echo "⚙️  Initializing multi-repo workspace..."

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------

# Default branches/tags (can also be overridden via .env)
FRONTEND_REF="${FRONTEND_REF:-main}"
BACKEND_REF="${BACKEND_REF:-main}"

# ------------------------------------------------------------------------------
# LOAD LOCAL ENV (.env file)
# ------------------------------------------------------------------------------

if [ -f ".env" ]; then
  echo "📄 Loading environment from .env"
  export $(grep -v '^#' .env | xargs)
fi

# ------------------------------------------------------------------------------
# GIT CREDENTIALS + SAFE DIRECTORY
# ------------------------------------------------------------------------------

git config --global --add safe.directory /workspace || true
git config --global credential.helper 'cache --timeout=3600' || true

# ------------------------------------------------------------------------------
# CLONE OR UPDATE REPOS
# ------------------------------------------------------------------------------

clone_or_update() {
  local dir=$1
  local repo=$2
  local ref=$3

  if [ ! -d "$dir/.git" ]; then
    echo "📦 Cloning $repo into $dir"
    git clone "$repo" "$dir"
  else
    echo "🔁 Updating existing repo in $dir"
    (cd "$dir" && git fetch origin)
  fi

  echo "🔖 Checking out $ref in $dir"
  (
    cd "$dir"
    git checkout "$ref" &&
    git pull origin "$ref" || true
  )
}

clone_or_update frontend "$FRONTEND_REPO" "$FRONTEND_REF"
clone_or_update backend "$BACKEND_REPO" "$BACKEND_REF"

# ------------------------------------------------------------------------------
# FRONTEND SETUP
# ------------------------------------------------------------------------------

echo "📋 Installing frontend dependencies..."
# npm install --prefix frontend

# ------------------------------------------------------------------------------
# BACKEND BUILD (supports mvn wrapper or system mvn)
# ------------------------------------------------------------------------------

build_backend() {
  if [ -f backend/mvnw ]; then
    echo "🧱 Building backend with Maven Wrapper..."
    # (cd backend && ./mvnw clean package -DskipTests)
  elif command -v mvn &>/dev/null && [ -f backend/pom.xml ]; then
    echo "🧱 Building backend with system Maven..."
    # (cd backend && mvn clean package -DskipTests)
  elif [ -f backend/build.gradle ] || [ -f backend/build.gradle.kts ]; then
    echo "🧱 Detected Gradle project (building)..."
    # if [ -x "$(command -v gradle)" ]; then
    #   (cd backend && gradle build -x test)
    # else
    #   echo "⚠️ Gradle not installed; build skipped."
    # fi
  else
    echo "⚠️ No recognizable build file found (no pom.xml or gradle.build). Skipping backend build."
  fi
}

build_backend

# ------------------------------------------------------------------------------
# STARTUP SCRIPT (no mvnw requirement)
# ------------------------------------------------------------------------------

echo "🚀 Preparing startup script..."
cat > start.sh <<'EOF'
#!/bin/bash
trap "exit" INT TERM
trap "kill 0" EXIT

# function to detect build system
run_backend() {
  if [ -f backend/mvnw ]; then
    echo "→ Starting backend (mvnw)"
    # (cd backend && ./mvnw spring-boot:run)
  elif command -v mvn &>/dev/null && [ -f backend/pom.xml ]; then
    echo "→ Starting backend (system Maven)"
    # (cd backend && mvn spring-boot:run)
  elif [ -f backend/build.gradle ] || [ -f backend/build.gradle.kts ]; then
    if [ -x "$(command -v gradle)" ]; then
      echo "→ Starting backend (Gradle)"
      # (cd backend && gradle bootRun)
    else
      echo "⚠️ Gradle not installed, backend not started."
    fi
  else
    echo "⚠️ No valid backend start method found."
  fi
}

echo "→ Starting Spring Boot/Gradle backend..."
run_backend &

echo "→ Starting Next.js frontend..."
# (cd frontend && npm run dev) &

wait
EOF

chmod +x start.sh
./start.sh
