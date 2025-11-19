#!/bin/bash
set -e

# --- Setup Git credential helper for HTTPS URLs ---
# This allows git to use local credentials (e.g. GitHub token or credential store)
git config --global credential.helper store || true
git config --global credential.helper 'cache --timeout=3600' || true

# --- Clone repos if needed ---
if [ ! -d "frontend" ]; then
  echo "Cloning frontend repo from $FRONTEND_REPO ..."
  git clone "$FRONTEND_REPO" frontend || {
    echo "❌ Failed to clone frontend. Check SSH/HTTPS access."
    exit 1
  }
fi

if [ ! -d "backend" ]; then
  echo "Cloning backend repo from $BACKEND_REPO ..."
  git clone "$BACKEND_REPO" backend || {
    echo "❌ Failed to clone backend. Check SSH/HTTPS access."
    exit 1
  }
fi

# --- Prepare frontend ---
#echo "Installing frontend dependencies..."
#npm install --prefix frontend

# --- Build backend if Maven wrapper present ---
#if [ -f backend/mvnw ]; then
#  echo "Building backend..."
#  (cd backend && ./mvnw clean package -DskipTests)
#fi

# --- Start both servers concurrently ---
#echo "Starting backend and frontend..."
#cat > start.sh <<'EOF'
##!/bin/bash
#trap "exit" INT TERM
#trap "kill 0" EXIT

#echo "Launching Spring Boot..."
#(cd backend && ./mvnw spring-boot:run) &

#echo "Launching Next.js..."
#(cd frontend && npm run dev) &

#wait
#EOF

#chmod +x start.sh
#./start.sh
