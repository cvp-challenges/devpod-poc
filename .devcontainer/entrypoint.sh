#!/bin/bash
set -e

echo "🚀 DevPod workspace initializing..."

cd /workspace

# --- Repo setup ---
if [ ! -d "frontend/.git" ]; then
  echo "📦 Cloning frontend..."
  git clone "$FRONTEND_REPO" frontend
fi

if [ ! -d "backend/.git" ]; then
  echo "📦 Cloning backend..."
  git clone "$BACKEND_REPO" backend
fi

# # --- Dependencies ---
# echo "📦 Installing dependencies..."
# npm install --prefix frontend >/dev/null

# # Optional: Build Spring Boot to speed hot reload
# if [ -f backend/mvnw ]; then
#   echo "🔨 Building backend..."
#   cd backend && ./mvnw clean package -DskipTests >/dev/null && cd ..
# fi

# # --- Run servers concurrently ---
# echo "⚙️  Starting frontend & backend..."

# cd /workspace
# exec bash -c '
#   trap "exit" INT TERM
#   trap "kill 0" EXIT
#   # (cd backend && ./mvnw spring-boot:run) &
#   # (cd frontend && npm run dev) &
#   wait
# '

tail -f /dev/null
